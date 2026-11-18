import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'auth_service.dart';

const String _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://traceur-backend.onrender.com',
);

String get wsUrl {
  final uri = Uri.tryParse(_apiBaseUrl);
  if (uri == null || (!uri.scheme.startsWith('http'))) {
    return 'wss://traceur-backend.onrender.com/ws';
  }
  final scheme = uri.scheme == 'http' ? 'ws' : 'wss';
  return Uri(
    scheme: scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: '${uri.path.replaceAll(RegExp(r'/$'), '')}/ws',
  ).toString();
}

/// Connexion WebSocket avec reconnexion automatique.
/// Garde en mémoire : dernières positions, alertes actives, troupeau
/// et zone de pâturage (géorepérage).
class WsService extends ChangeNotifier {
  WebSocketChannel? _canal;
  Timer? _ping;
  Timer? _reconnexion;
  bool _ferme = false;
  bool _suspendu = false;
  bool _connexionEnCours = false;
  int _essais = 0;

  bool connecte = false;
  final Map<String, Map<String, dynamic>> positions = {};

  /// Alertes ACTIVES uniquement : une alerte résolue est retirée de la liste.
  List<Map<String, dynamic>> alertes = [];
  Map<String, dynamic>? troupeau;

  /// Sommets de la zone de pâturage active : [{latitude, longitude}, ...]
  /// null = aucune zone enregistrée.
  List<Map<String, dynamic>>? pature;

  /// Nom de la zone de pâturage active.
  String? nomPature;

  /// AJOUT : « auto » (suit le grand troupeau) ou « manuel » (fixe).
  String? modePature;

  /// AJOUT : marge autour du grand troupeau (mode auto), en mètres.
  double? margePature;

  void demarrer() {
    if (connecte || _canal != null || !AuthService.instance.connecte) return;
    _ferme = false;
    _suspendu = false;
    unawaited(_connecter());
  }

  void suspendre() {
    _suspendu = true;
    _reconnexion?.cancel();
    _reconnexion = null;
    _ping?.cancel();
    _ping = null;
    final canal = _canal;
    _canal = null;
    canal?.sink.close();
    if (connecte) {
      connecte = false;
      notifyListeners();
    }
  }

  void reprendre() {
    if (_ferme || !AuthService.instance.connecte) return;
    _suspendu = false;
    _reconnexion?.cancel();
    _reconnexion = null;
    if (_canal != null) {
      final canal = _canal;
      _canal = null;
      canal?.sink.close();
    }
    unawaited(_connecter());
  }

  void arreter() {
    _ferme = true;
    _suspendu = false;
    _reconnexion?.cancel();
    _reconnexion = null;
    _ping?.cancel();
    _ping = null;
    _canal?.sink.close();
    _canal = null;
    connecte = false;
    positions.clear();
    alertes.clear();
    troupeau = null;
    _appliquerZone(null);
    notifyListeners();
  }

  /// Convertit la liste JSON des sommets en liste de Map.
  List<Map<String, dynamic>> _lireSommets(dynamic brut) =>
      (brut as List).map((c) => Map<String, dynamic>.from(c as Map)).toList();

  /// AJOUT : applique (ou efface) la zone reçue du serveur.
  void _appliquerZone(dynamic z) {
    if (z == null) {
      pature = null;
      nomPature = null;
      modePature = null;
      margePature = null;
    } else {
      pature = _lireSommets(z['coordinates']);
      nomPature = z['name'] as String?;
      modePature = z['mode'] as String?;
      margePature = (z['marge_m'] as num?)?.toDouble();
    }
  }

  Future<void> _connecter() async {
    if (_ferme ||
        _suspendu ||
        _connexionEnCours ||
        _canal != null ||
        !AuthService.instance.connecte) {
      return;
    }
    _connexionEnCours = true;
    try {
      await AuthService.instance.verifierSessionActive();
      if (_ferme || _suspendu || !AuthService.instance.connecte) return;

      final canal = WebSocketChannel.connect(Uri.parse(wsUrl));
      _canal = canal;
      canal.sink.add(jsonEncode({'token': AuthService.instance.jeton}));
      canal.stream.listen(
        _surMessage,
        onError: (_) => _surFermeture(canal),
        onDone: () => _surFermeture(canal),
        cancelOnError: true,
      );
      _ping?.cancel();
      _ping = Timer.periodic(const Duration(seconds: 25), (_) {
        try {
          canal.sink.add('ping');
        } catch (_) {}
      });
    } on ErreurApi catch (erreur) {
      debugPrint('Vérification de session WebSocket impossible : $erreur');
      _planifierReconnexion();
    } finally {
      _connexionEnCours = false;
      if (!_ferme &&
          !_suspendu &&
          _canal == null &&
          _reconnexion == null &&
          AuthService.instance.connecte) {
        _planifierReconnexion();
      }
    }
  }

  void _surMessage(dynamic brut) {
    final texte = brut as String;

    final msg = jsonDecode(texte) as Map<String, dynamic>;
    connecte = true;
    _essais = 0;
    switch (msg['type']) {
      case 'etat':
        positions
          ..clear()
          ..addEntries(
            (msg['positions'] as List).map(
              (p) => MapEntry(
                p['animal_id'] as String,
                Map<String, dynamic>.from(p),
              ),
            ),
          );
        alertes = (msg['alertes_actives'] as List)
            .map((a) => Map<String, dynamic>.from(a))
            .toList();
        troupeau = msg['troupeau'] as Map<String, dynamic>?;
        _appliquerZone(msg['pature']);
        break;

      case 'troupeau':
        troupeau = Map<String, dynamic>.from(msg['data']);
        break;

      case 'position':
        final p = Map<String, dynamic>.from(msg['data']);
        positions[p['animal_id']] = p;
        break;

      case 'alerte':
        alertes.insert(0, Map<String, dynamic>.from(msg['data']));
        if (alertes.length > 50) alertes = alertes.sublist(0, 50);
        break;

      case 'alerte_resolue':
        final d = msg['data'];
        alertes.removeWhere(
          (a) => a['animal_id'] == d['animal_id'] && a['type'] == d['type'],
        );
        break;

      case 'pature':
        // data == null : zone supprimée côté serveur
        _appliquerZone(msg['data']);
        break;
    }

    notifyListeners();
  }

  void _surFermeture(WebSocketChannel canal) {
    if (!identical(_canal, canal)) return;
    _canal = null;
    _ping?.cancel();
    _ping = null;
    if (connecte) {
      connecte = false;
      notifyListeners();
    }
    _planifierReconnexion();
  }

  void _planifierReconnexion() {
    if (_ferme || _suspendu || !AuthService.instance.connecte) return;
    _essais++;
    final attente = Duration(seconds: (_essais * 2).clamp(2, 30));
    _reconnexion?.cancel();
    _reconnexion = Timer(attente, () {
      _reconnexion = null;
      unawaited(_connecter());
    });
  }

  @override
  void dispose() {
    arreter();
    super.dispose();
  }
}
