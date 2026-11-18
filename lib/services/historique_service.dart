import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:traceur_app/services/historique_activite.dart';

import '../auth_service.dart';

const String kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://traceur-backend.onrender.com',
);

// Render (offre gratuite) peut mettre ~30-60 s à se réveiller.
const Duration _delaiRequete = Duration(seconds: 30);
const int _essaisMax = 3;
const Set<int> _statutsTransitoires = {502, 503, 504};

enum HistoriqueErreur {
  reseau,
  aucuneMesure,
  serviceIndisponible,
  requeteInvalide,
  inconnue,
}

class HistoriqueException implements Exception {
  final HistoriqueErreur type;
  final String? detail;

  const HistoriqueException(this.type, [this.detail]);

  @override
  String toString() => detail == null
      ? 'HistoriqueException($type)'
      : 'HistoriqueException($type, $detail)';
}

/// Réglage de la durée de référence, tel que renvoyé par GET /parametres.
class ReglageReference {
  const ReglageReference({required this.jours, this.min = 4, this.max = 14});

  final int jours;
  final int min;
  final int max;
}

class HistoriqueService {
  HistoriqueService({http.Client? client})
    : _client = client ?? http.Client(),
      _possedeClient = client == null;

  final http.Client _client;
  final bool _possedeClient;
  bool _ferme = false;

  /// Ferme uniquement le client créé par ce service.
  /// Un client injecté reste sous la responsabilité de son appelant.
  void close() {
    if (_possedeClient && !_ferme) {
      _client.close();
      _ferme = true;
    }
  }

  /// GET avec nouvelles tentatives : le serveur Render peut être endormi
  /// (réponse 502/503 sans CORS => « Failed to fetch » dans le navigateur).
  Future<http.Response> _getAvecReprise(Uri uri) async {
    for (var essai = 1; ; essai++) {
      if (_ferme) {
        throw const HistoriqueException(
          HistoriqueErreur.inconnue,
          'Le service a déjà été fermé.',
        );
      }
      final dernier = essai >= _essaisMax;
      try {
        final response = await _client
            .get(uri, headers: AuthService.instance.entetesAutorisation)
            .timeout(_delaiRequete);
        if (!dernier && _statutsTransitoires.contains(response.statusCode)) {
          await Future<void>.delayed(Duration(seconds: 3 * essai));
          continue;
        }
        return response;
      } on TimeoutException {
        if (dernier) {
          throw const HistoriqueException(
            HistoriqueErreur.reseau,
            'La requête a dépassé le délai autorisé.',
          );
        }
        await Future<void>.delayed(Duration(seconds: 3 * essai));
      } on http.ClientException catch (error) {
        if (dernier) {
          throw HistoriqueException(HistoriqueErreur.reseau, error.message);
        }
        await Future<void>.delayed(Duration(seconds: 3 * essai));
      }
    }
  }

  /// Construit l'exception à partir d'une réponse non-200, en gardant le
  /// message « detail » renvoyé par le serveur (visible dans la console).
  HistoriqueException _exceptionReponse(http.Response response) {
    var detail = 'HTTP ${response.statusCode}';
    try {
      final corps = jsonDecode(utf8.decode(response.bodyBytes));
      if (corps is Map && corps['detail'] != null) {
        detail = '$detail : ${corps['detail']}';
      }
    } catch (_) {}
    debugPrint('Erreur serveur : $detail');
    final base = _exceptionHttp(response.statusCode);
    return HistoriqueException(base.type, detail);
  }

  /// Deux modes :
  ///  - [heures] : les dernières heures (défaut 168 = 7 jours) ;
  ///  - [debut] + [fin] : plage de dates, [debut] inclus et [fin] EXCLUE.
  ///    Si les deux sont fournis, [heures] est ignoré.
  Future<HistoriqueActivite> charger(
    String animalId, {
    int heures = 168,
    DateTime? debut,
    DateTime? fin,
  }) async {
    if (_ferme) {
      throw const HistoriqueException(
        HistoriqueErreur.inconnue,
        'Le service a déjà été fermé.',
      );
    }

    final id = animalId.trim();
    if (id.isEmpty || heures <= 0) {
      throw const HistoriqueException(
        HistoriqueErreur.requeteInvalide,
        'Un identifiant et une période positive sont requis.',
      );
    }
    if ((debut == null) != (fin == null)) {
      throw const HistoriqueException(
        HistoriqueErreur.requeteInvalide,
        'La date de début et la date de fin vont ensemble.',
      );
    }
    if (debut != null && fin != null && !fin.isAfter(debut)) {
      throw const HistoriqueException(
        HistoriqueErreur.requeteInvalide,
        'La date de fin doit être postérieure à la date de début.',
      );
    }

    final uri = _construireUri(id, heures, debut, fin);
    final response = await _getAvecReprise(uri);

    if (response.statusCode != 200) {
      throw _exceptionReponse(response);
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map) {
        throw const FormatException('Un objet JSON était attendu.');
      }
      final json = <String, dynamic>{};
      for (final entry in decoded.entries) {
        if (entry.key is! String) {
          throw const FormatException('Une clé JSON n’est pas une chaîne.');
        }
        json[entry.key as String] = entry.value;
      }
      return HistoriqueActivite.fromJson(json);
    } on FormatException catch (error) {
      throw HistoriqueException(HistoriqueErreur.inconnue, error.message);
    } on TypeError catch (error) {
      throw HistoriqueException(HistoriqueErreur.inconnue, error.toString());
    }
  }

  /// GET /parametres -> valeurs.reference_jours et bornes.reference_jours.
  Future<ReglageReference> lireReferenceJours() async {
    if (_ferme) {
      throw const HistoriqueException(
        HistoriqueErreur.inconnue,
        'Le service a déjà été fermé.',
      );
    }
    final response = await _getAvecReprise(_uriParametres());

    if (response.statusCode != 200) {
      throw _exceptionReponse(response);
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map) {
        throw const FormatException('Un objet JSON était attendu.');
      }
      final valeurs = decoded['valeurs'];
      final jours = valeurs is Map ? valeurs['reference_jours'] : null;
      if (jours is! num) {
        throw const FormatException('reference_jours absent.');
      }
      final bornes = decoded['bornes'];
      final b = bornes is Map ? bornes['reference_jours'] : null;
      final min = (b is List && b.length == 2 && b[0] is num)
          ? (b[0] as num).toInt()
          : 4;
      final max = (b is List && b.length == 2 && b[1] is num)
          ? (b[1] as num).toInt()
          : 14;
      return ReglageReference(jours: jours.toInt(), min: min, max: max);
    } on FormatException catch (error) {
      throw HistoriqueException(HistoriqueErreur.inconnue, error.message);
    }
  }

  /// PUT /parametres {"reference_jours": jours}. Une réponse 422 devient
  /// HistoriqueErreur.requeteInvalide.
  Future<void> modifierReferenceJours(int jours) async {
    if (_ferme) {
      throw const HistoriqueException(
        HistoriqueErreur.inconnue,
        'Le service a déjà été fermé.',
      );
    }
    final http.Response response;
    try {
      response = await _client
          .put(
            _uriParametres(),
            headers: AuthService.instance.entetesAutorisation,
            body: jsonEncode({'reference_jours': jours}),
          )
          .timeout(_delaiRequete);
    } on TimeoutException {
      throw const HistoriqueException(
        HistoriqueErreur.reseau,
        'La requête a dépassé le délai autorisé.',
      );
    } on http.ClientException catch (error) {
      throw HistoriqueException(HistoriqueErreur.reseau, error.message);
    }

    if (response.statusCode != 200) {
      throw _exceptionReponse(response);
    }
  }

  Uri _baseValide() {
    final base = Uri.tryParse(kBaseUrl.trim());
    if (base == null ||
        !base.hasAuthority ||
        (base.scheme != 'https' && base.scheme != 'http')) {
      throw const HistoriqueException(
        HistoriqueErreur.inconnue,
        'La configuration de l’URL de l’API est invalide.',
      );
    }
    return base;
  }

  Uri _uriParametres() {
    final base = _baseValide();
    final segments =
        base.pathSegments.where((segment) => segment.isNotEmpty).toList()
          ..add('parametres');
    return base.replace(pathSegments: segments);
  }

  /// Date au format AAAA-MM-JJ attendu par l'API (jour calendaire local).
  static String _jour(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Uri _construireUri(
    String animalId,
    int heures,
    DateTime? debut,
    DateTime? fin,
  ) {
    final base = _baseValide();

    final segments = base.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    segments.addAll(['ia', 'historique', animalId]);

    final params = (debut != null && fin != null)
        ? {'debut': _jour(debut), 'fin': _jour(fin)}
        : {'heures': heures.toString()};

    return base.replace(pathSegments: segments, queryParameters: params);
  }

  HistoriqueException _exceptionHttp(int statusCode) {
    switch (statusCode) {
      case 400:
      case 422:
        return const HistoriqueException(HistoriqueErreur.requeteInvalide);
      case 404:
        return const HistoriqueException(HistoriqueErreur.aucuneMesure);
      case 408:
      case 504:
        return const HistoriqueException(HistoriqueErreur.reseau);
      case 429:
      case 500:
      case 502:
      case 503:
        return HistoriqueException(
          HistoriqueErreur.serviceIndisponible,
          'HTTP $statusCode',
        );
      default:
        return HistoriqueException(
          HistoriqueErreur.inconnue,
          'HTTP $statusCode',
        );
    }
  }
}
