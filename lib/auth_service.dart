// lib/auth_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'native/canaux.dart';

const String _apiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://traceur-backend.onrender.com',
);
const String _cleJeton = 'session_token';
const String _cleJetonRenouvellement = 'session_refresh_token';
const String _cleUtilisateur = 'session_user';
const String _cleNotificationsMessages = 'notifications_messages_actives';
const String _cleInstallationFcm = 'notifications_fcm_installation';

class ErreurApi implements Exception {
  final String message;
  const ErreurApi(this.message);
  @override
  String toString() => message;
}

class Utilisateur {
  final String id;
  final String nom;
  final String prenom;
  final int? age;
  final String residence;
  final String telephone;
  final String role; // utilisateur | admin | superadmin
  final String numeroClient;
  final bool biometrieActivee;

  const Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.age,
    required this.residence,
    required this.telephone,
    required this.role,
    required this.numeroClient,
    required this.biometrieActivee,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> j) => Utilisateur(
    id: '${j['id']}',
    nom: '${j['nom'] ?? ''}',
    prenom: '${j['prenom'] ?? ''}',
    age: j['age'] is num ? (j['age'] as num).toInt() : null,
    residence: '${j['residence'] ?? ''}',
    telephone: '${j['telephone'] ?? ''}',
    role: '${j['role'] ?? 'utilisateur'}',
    numeroClient: '${j['numero_client'] ?? ''}',
    biometrieActivee: j['biometrie_activee'] == true,
  );

  String get nomComplet => prenom.isEmpty ? nom : '$prenom $nom';

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'age': age,
    'residence': residence,
    'telephone': telephone,
    'role': role,
    'numero_client': numeroClient,
    'biometrie_activee': biometrieActivee,
  };
}

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  String? _token;
  String? _refreshToken;
  Utilisateur? _utilisateur;
  final LocalAuthentication _authentificationLocale = LocalAuthentication();
  final FlutterSecureStorage _stockage = const FlutterSecureStorage();
  Future<bool>? _renouvellementEnCours;
  Future<void>? _synchronisationNotificationsEnCours;
  bool _notificationsMessagesActives = false;

  Utilisateur? get utilisateur => _utilisateur;
  String? get jeton => _token;
  bool get connecte => _token != null && _utilisateur != null;
  bool get estSuperAdmin => _utilisateur?.role == 'superadmin';
  bool get estAdmin => _utilisateur?.role == 'admin' || estSuperAdmin;
  bool get notificationsMessagesActives => _notificationsMessagesActives;
  String? get jetonRenouvellement => _refreshToken;

  Map<String, String> get entetesAutorisation => _entetes;

  Uri uriApi(String chemin) => _uri(chemin);

  Future<void> activerNotificationsMessages() async {
    if (!connecte) {
      throw const ErreurApi('Connectez-vous pour activer les notifications.');
    }
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw const ErreurApi(
        'Les notifications de messages sont disponibles sur Android.',
      );
    }

    final autorise = await CanauxNatifs.demanderPermissionNotifications();
    if (!autorise) {
      throw const ErreurApi(
        'Autorisez les notifications dans les réglages Android pour continuer.',
      );
    }
    final identifiant = await CanauxNatifs.obtenirJetonFcm();
    await _stockage.write(key: _cleInstallationFcm, value: identifiant);
    try {
      await _enregistrerInstallationFcm(identifiant);
      await _stockage.write(key: _cleNotificationsMessages, value: 'true');
      _notificationsMessagesActives = true;
    } catch (_) {
      await _stockage.delete(key: _cleInstallationFcm);
      rethrow;
    }
  }

  Future<void> desactiverNotificationsMessages() async {
    final identifiant = await _stockage.read(key: _cleInstallationFcm);
    if (identifiant != null && connecte) {
      await _supprimerInstallationFcm(identifiant);
    }
    await _stockage.delete(key: _cleNotificationsMessages);
    await _stockage.delete(key: _cleInstallationFcm);
    _notificationsMessagesActives = false;
  }

  Future<bool> chargerEtatNotificationsMessages() async {
    _notificationsMessagesActives =
        await _stockage.read(key: _cleNotificationsMessages) == 'true';
    return _notificationsMessagesActives;
  }

  Future<void> verifierSessionPourSurveillance() async {
    await _requete(
      () => http.get(_uri('/alertes?actives=true&limite=1'), headers: _entetes),
    );
    if (_token == null) {
      throw const ErreurApi('Votre session doit être renouvelée.');
    }
  }

  Future<void> verifierSessionActive() async {
    if (!connecte) {
      throw const ErreurApi('Votre session doit être renouvelée.');
    }
    await _requete(() => http.get(_uri('/auth/moi'), headers: _entetes));
    if (!connecte) {
      throw const ErreurApi('Votre session doit être renouvelée.');
    }
  }

  Future<void> _enregistrerInstallationFcm(String identifiant) async {
    await _requete(
      () => http.post(
        _uri('/messagerie/installation-fcm'),
        headers: _entetes,
        body: jsonEncode({'identifiant': identifiant}),
      ),
    );
    await _stockage.write(key: _cleInstallationFcm, value: identifiant);
  }

  Future<void> _supprimerInstallationFcm(String identifiant) async {
    await _requete(
      () => http.delete(
        _uri('/messagerie/installation-fcm'),
        headers: _entetes,
        body: jsonEncode({'identifiant': identifiant}),
      ),
    );
  }

  Future<void> synchroniserNotificationsMessages() async {
    final enCours = _synchronisationNotificationsEnCours;
    if (enCours != null) {
      await enCours;
      return;
    }

    final synchronisation = _synchroniserNotificationsMessages();
    _synchronisationNotificationsEnCours = synchronisation;
    try {
      await synchronisation;
    } finally {
      if (identical(_synchronisationNotificationsEnCours, synchronisation)) {
        _synchronisationNotificationsEnCours = null;
      }
    }
  }

  Future<void> _synchroniserNotificationsMessages() async {
    final active = await _stockage.read(key: _cleNotificationsMessages);
    _notificationsMessagesActives = active == 'true';
    if (!_notificationsMessagesActives ||
        !connecte ||
        kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      if (!await CanauxNatifs.demanderPermissionNotifications()) {
        final ancienneInstallation = await _stockage.read(
          key: _cleInstallationFcm,
        );
        if (ancienneInstallation != null) {
          await _supprimerInstallationFcm(ancienneInstallation);
        }
        await _stockage.delete(key: _cleInstallationFcm);
        await _stockage.delete(key: _cleNotificationsMessages);
        _notificationsMessagesActives = false;
        return;
      }
      await _enregistrerInstallationFcm(await CanauxNatifs.obtenirJetonFcm());
    } on PlatformException catch (erreur) {
      debugPrint('Synchronisation FCM impossible : ${erreur.message}');
    } on ErreurApi catch (erreur) {
      debugPrint('Synchronisation FCM impossible : ${erreur.message}');
    }
  }

  Future<dynamic> requeteApi(Future<http.Response> Function() envoi) =>
      _requete(envoi);

  Future<http.Response> _envoyer(Future<http.Response> Function() envoi) async {
    try {
      // 60 s : le serveur gratuit Render peut mettre du temps à se réveiller
      return await envoi().timeout(const Duration(seconds: 60));
    } catch (_) {
      throw const ErreurApi(
        'Connexion impossible. Vérifiez votre réseau puis réessayez.',
      );
    }
  }

  dynamic _decoder(http.Response r) {
    dynamic corps;
    if (r.body.isNotEmpty) {
      try {
        corps = jsonDecode(utf8.decode(r.bodyBytes));
      } catch (_) {}
    }
    return corps;
  }

  ErreurApi _erreurReponse(http.Response r, dynamic corps) {
    final detail = corps is Map ? corps['detail'] : null;
    return ErreurApi(
      detail is String
          ? detail
          : r.statusCode == 422
          ? 'Certaines informations sont invalides.'
          : 'Erreur serveur (${r.statusCode}).',
    );
  }

  Future<dynamic> _requete(Future<http.Response> Function() envoi) async {
    var r = await _envoyer(envoi);
    if (r.statusCode == 401 && _refreshToken != null) {
      if (!await _renouvelerSession()) {
        throw const ErreurApi('Votre session a expiré. Reconnectez-vous.');
      }
      r = await _envoyer(envoi);
    }

    final corps = _decoder(r);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      if (r.statusCode == 401 && connecte) {
        await _effacerSessionLocale();
      }
      throw _erreurReponse(r, corps);
    }
    return corps;
  }

  Map<String, String> get _entetes => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Uri _uri(String chemin) => Uri.parse('$_apiBase$chemin');

  Future<void> _ouvrirSession(dynamic corps) async {
    if (corps is! Map ||
        corps['token'] is! String ||
        corps['refresh_token'] is! String ||
        corps['utilisateur'] is! Map) {
      throw const ErreurApi(
        'Le serveur ne fournit pas les informations de session persistante. '
        'Mettez le backend à jour.',
      );
    }
    final token = corps['token'] as String;
    final refreshToken = corps['refresh_token'] as String;
    final utilisateur = Utilisateur.fromJson(
      Map<String, dynamic>.from(corps['utilisateur'] as Map),
    );
    await _sauvegarderSession(token, refreshToken, utilisateur);
    _token = token;
    _refreshToken = refreshToken;
    _utilisateur = utilisateur;
    notifyListeners();
  }

  Future<void> restaurerSession() async {
    final valeurs = await Future.wait([
      _stockage.read(key: _cleJeton),
      _stockage.read(key: _cleJetonRenouvellement),
      _stockage.read(key: _cleUtilisateur),
    ]);
    final token = valeurs[0];
    final refreshToken = valeurs[1];
    final jsonUtilisateur = valeurs[2];
    if (token == null || refreshToken == null || jsonUtilisateur == null) {
      await _effacerSessionLocale();
      return;
    }

    try {
      final utilisateur = Utilisateur.fromJson(
        Map<String, dynamic>.from(jsonDecode(jsonUtilisateur) as Map),
      );
      _token = token;
      _refreshToken = refreshToken;
      _utilisateur = utilisateur;
      notifyListeners();
      unawaited(synchroniserNotificationsMessages());
    } on FormatException {
      await _effacerSessionLocale();
    } on TypeError {
      await _effacerSessionLocale();
    }
  }

  Future<void> _sauvegarderSession(
    String token,
    String refreshToken,
    Utilisateur utilisateur,
  ) async {
    try {
      await _stockage.write(key: _cleJetonRenouvellement, value: refreshToken);
      await _stockage.write(
        key: _cleUtilisateur,
        value: jsonEncode(utilisateur.toJson()),
      );
      await _stockage.write(key: _cleJeton, value: token);
    } on PlatformException {
      throw const ErreurApi(
        'Impossible de protéger la session sur cet appareil.',
      );
    }
  }

  Future<void> _effacerSessionLocale() async {
    final etaitConnecte = connecte;
    try {
      await _stockage.delete(key: _cleJeton);
      await _stockage.delete(key: _cleJetonRenouvellement);
      await _stockage.delete(key: _cleUtilisateur);
      await _stockage.delete(key: _cleNotificationsMessages);
      await _stockage.delete(key: _cleInstallationFcm);
    } on PlatformException {
      _token = null;
      _refreshToken = null;
      _utilisateur = null;
      _notificationsMessagesActives = false;
      if (etaitConnecte) notifyListeners();
      throw const ErreurApi(
        'Impossible de supprimer la session sécurisée de cet appareil.',
      );
    }
    _token = null;
    _refreshToken = null;
    _utilisateur = null;
    if (etaitConnecte) notifyListeners();
  }

  Future<bool> _renouvelerSession() async {
    final enCours = _renouvellementEnCours;
    if (enCours != null) return enCours;
    final futur = _effectuerRenouvellement();
    _renouvellementEnCours = futur;
    try {
      return await futur;
    } finally {
      _renouvellementEnCours = null;
    }
  }

  Future<bool> _effectuerRenouvellement() async {
    final refreshToken = _refreshToken;
    if (refreshToken == null) return false;
    final r = await _envoyer(
      () => http.post(
        _uri('/auth/renouveler'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      ),
    );
    final corps = _decoder(r);
    if (r.statusCode == 401) {
      await _effacerSessionLocale();
      return false;
    }
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw _erreurReponse(r, corps);
    }
    await _ouvrirSession(corps);
    return true;
  }

  Future<void> verifierEmpreinte(String raison) async {
    try {
      final biometries = await _authentificationLocale.getAvailableBiometrics();
      if (!biometries.contains(BiometricType.fingerprint)) {
        throw const ErreurApi(
          'Aucune empreinte digitale utilisable n’est configurée sur cet appareil.',
        );
      }
      final valide = await _authentificationLocale.authenticate(
        localizedReason: raison,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      if (!valide) {
        throw const ErreurApi(
          'Vérification de l’empreinte annulée ou refusée.',
        );
      }
    } on LocalAuthException catch (e) {
      throw ErreurApi('Échec de la vérification biométrique : ${e.code.name}.');
    }
  }

  Future<void> creerNouveauClient({
    required String codeActivation,
    required String nom,
    required String motDePasse,
  }) async {
    final c = await _requete(
      () => http.post(
        _uri('/auth/nouveau-client'),
        headers: _entetes,
        body: jsonEncode({
          'code_activation': codeActivation,
          'nom': nom,
          'mot_de_passe': motDePasse,
          'ferme': 'Ferme principale',
        }),
      ),
    );
    await _ouvrirSession(c);
  }

  Future<bool> connecter(
    String numeroClient,
    String nom,
    String motDePasse,
  ) async {
    final c = await _requete(
      () => http.post(
        _uri('/auth/connexion'),
        headers: _entetes,
        body: jsonEncode({
          'numero_client': numeroClient,
          'nom': nom,
          'mot_de_passe': motDePasse,
        }),
      ),
    );
    await _ouvrirSession(c);
    return c['verification_biometrique_requise'] == true;
  }

  Future<void> deconnecter() async {
    var refreshToken = _refreshToken;
    String? erreurNotifications;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await CanauxNatifs.arreterSurveillance();
      } on PlatformException catch (erreur) {
        erreurNotifications = erreur.message;
      }
    }
    final identifiantFcm = await _stockage.read(key: _cleInstallationFcm);
    if (identifiantFcm != null && connecte) {
      try {
        await _supprimerInstallationFcm(identifiantFcm);
      } on ErreurApi catch (erreur) {
        erreurNotifications ??= erreur.message;
      }
      refreshToken = _refreshToken;
    }
    await _effacerSessionLocale();
    if (refreshToken != null) {
      final http.Response reponse;
      try {
        reponse = await http
            .post(
              _uri('/auth/deconnexion'),
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({'refresh_token': refreshToken}),
            )
            .timeout(const Duration(seconds: 10));
      } on TimeoutException {
        throw const ErreurApi(
          'Session supprimée sur cet appareil, mais le serveur n’a pas confirmé '
          'la révocation.',
        );
      } on http.ClientException {
        throw const ErreurApi(
          'Session supprimée sur cet appareil, mais le serveur n’a pas confirmé '
          'la révocation.',
        );
      }
      if (reponse.statusCode != 401 &&
          (reponse.statusCode < 200 || reponse.statusCode >= 300)) {
        throw _erreurReponse(reponse, _decoder(reponse));
      }
    }
    if (erreurNotifications != null) {
      throw ErreurApi(
        'Session fermée, mais la désactivation des notifications a échoué : '
        '$erreurNotifications',
      );
    }
  }

  Future<List<Utilisateur>> listerUtilisateurs() async {
    // Le paramètre « t » change à chaque appel : évite une réponse en cache.
    final c = await _requete(
      () => http.get(
        Uri.parse(
          '$_apiBase/utilisateurs?t=${DateTime.now().millisecondsSinceEpoch}',
        ),
        headers: _entetes,
      ),
    );
    return (c as List)
        .map((e) => Utilisateur.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Crée un compte et renvoie l'utilisateur créé. Si le serveur ne renvoie
  /// pas son identifiant, un identifiant provisoire est utilisé (tirer la
  /// liste vers le bas pour recharger la vraie liste).
  Future<Utilisateur> ajouterUtilisateur({
    required String nom,
    required String prenom,
    required int age,
    required String residence,
    required String telephone,
    required String cin,
    required String role,
  }) async {
    final c = await _requete(
      () => http.post(
        _uri('/utilisateurs'),
        headers: _entetes,
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'age': age,
          'residence': residence,
          'telephone': telephone,
          'cin': cin,
          'role': role,
        }),
      ),
    );

    if (c is Map) {
      final m = Map<String, dynamic>.from(c);
      final j = m['utilisateur'] is Map
          ? Map<String, dynamic>.from(m['utilisateur'] as Map)
          : m;
      if (j['id'] != null) return Utilisateur.fromJson(j);
    }

    return Utilisateur(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      nom: nom,
      prenom: prenom,
      age: age,
      residence: residence,
      telephone: telephone,
      role: role,
      numeroClient: _utilisateur?.numeroClient ?? '',
      biometrieActivee: false,
    );
  }

  Future<void> supprimerUtilisateur(String id) async {
    await _requete(
      () => http.delete(_uri('/utilisateurs/$id'), headers: _entetes),
    );
  }
}
