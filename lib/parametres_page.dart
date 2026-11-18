import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:traceur_app/l10n/app_localizations.dart';
import 'package:traceur_app/locale_controller.dart';

import 'auth_service.dart';
import 'fond_page.dart';
import 'native/canaux.dart';

const Color _encre = Color(0xFF18352C);
const Color _vert = Color(0xFF23845B);
const Color _texteSecondaire = Color(0xFF708078);

/// Largeur des champs de saisie (courts, alignés à gauche).
const double _largeurChamp = 85;

class _Champ {
  final String cle;
  final String unite;
  final bool entier;

  const _Champ({required this.cle, this.unite = '', this.entier = false});
}

const List<_Champ> _champs = [
  _Champ(cle: 'eps_troupeau_m', unite: 'm'),
  _Champ(cle: 'distance_alerte_m', unite: 'm'),
  _Champ(cle: 'min_animaux_troupeau', entier: true),
  _Champ(cle: 'vitesse_max', unite: 'km/h'),
  _Champ(cle: 'duree_immobilite_s', unite: 's', entier: true),
  _Champ(cle: 'delai_collier_s', unite: 's', entier: true),
];

class _SectionParametres {
  final String cle;
  final IconData icone;
  final Color couleur;
  final List<String> cles;

  const _SectionParametres({
    required this.cle,
    required this.icone,
    required this.couleur,
    required this.cles,
  });
}

const List<_SectionParametres> _sections = [
  _SectionParametres(
    cle: 'herdGrouping',
    icone: Icons.groups_2_outlined,
    couleur: Color(0xFF23845B),
    cles: ['eps_troupeau_m', 'distance_alerte_m', 'min_animaux_troupeau'],
  ),
  _SectionParametres(
    cle: 'speedAndImmobility',
    icone: Icons.speed_rounded,
    couleur: Color(0xFF4777C8),
    cles: ['vitesse_max', 'duree_immobilite_s'],
  ),
  _SectionParametres(
    cle: 'collarSignal',
    icone: Icons.sensors_rounded,
    couleur: Color(0xFFB77828),
    cles: ['delai_collier_s'],
  ),
];

class ParametresPage extends StatefulWidget {
  const ParametresPage({super.key});

  @override
  State<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends State<ParametresPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _controleurs = {
    for (final champ in _champs) champ.cle: TextEditingController(),
  };

  bool _chargement = true;
  bool _envoi = false;
  bool _chargementNotifications = true;
  bool _notificationsMessages = false;
  bool _surveillanceActive = false;
  bool _actionNotifications = false;
  int _dureeSurveillanceMinutes = 60;
  String? _erreurChargement;
  Timer? _timerEtatSurveillance;

  @override
  void initState() {
    super.initState();
    _charger();
    _chargerEtatNotifications();
    if (CanauxNatifs.disponible) {
      _timerEtatSurveillance = Timer.periodic(
        const Duration(minutes: 1),
        (_) => _actualiserEtatSurveillance(),
      );
    }
  }

  @override
  void dispose() {
    _timerEtatSurveillance?.cancel();
    for (final controleur in _controleurs.values) {
      controleur.dispose();
    }
    super.dispose();
  }

  num? _convertirValeur(String texte, _Champ champ) {
    final valeur = texte.trim().replaceAll(',', '.');

    if (champ.entier) {
      return int.tryParse(valeur);
    }

    final nombre = double.tryParse(valeur);
    if (nombre == null || !nombre.isFinite) return null;
    return nombre;
  }

  Map<String, dynamic> _lireValeurs(http.Response reponse) {
    final contenu = jsonDecode(utf8.decode(reponse.bodyBytes));

    if (contenu is! Map || contenu['valeurs'] is! Map) {
      throw const FormatException('Format de réponse inattendu.');
    }

    return Map<String, dynamic>.from(contenu['valeurs'] as Map);
  }

  String _libelleChamp(_Champ champ, AppLocalizations loc) {
    return switch (champ.cle) {
      'eps_troupeau_m' => loc.parameterGroupingDistance,
      'distance_alerte_m' => loc.parameterMaximumDistance,
      'min_animaux_troupeau' => loc.parameterMinimumHerdSize,
      'vitesse_max' => loc.parameterMaximumSpeed,
      'duree_immobilite_s' => loc.parameterImmobilityDuration,
      'delai_collier_s' => loc.parameterCollarSignalDelay,
      _ => throw StateError('Paramètre inconnu : ${champ.cle}'),
    };
  }

  String _descriptionChamp(_Champ champ, AppLocalizations loc) {
    return switch (champ.cle) {
      'eps_troupeau_m' => loc.parameterGroupingDistanceDescription,
      'distance_alerte_m' => loc.parameterMaximumDistanceDescription,
      'min_animaux_troupeau' => loc.parameterMinimumHerdSizeDescription,
      'vitesse_max' => loc.parameterMaximumSpeedDescription,
      'duree_immobilite_s' => loc.parameterImmobilityDurationDescription,
      'delai_collier_s' => loc.parameterCollarSignalDelayDescription,
      _ => throw StateError('Paramètre inconnu : ${champ.cle}'),
    };
  }

  String _titreSection(_SectionParametres section, AppLocalizations loc) {
    return switch (section.cle) {
      'herdGrouping' => loc.herdGroupingSection,
      'speedAndImmobility' => loc.speedAndImmobilitySection,
      'collarSignal' => loc.collarSignalSection,
      _ => throw StateError('Section inconnue : ${section.cle}'),
    };
  }

  String _descriptionSection(_SectionParametres section, AppLocalizations loc) {
    return switch (section.cle) {
      'herdGrouping' => loc.herdGroupingSectionDescription,
      'speedAndImmobility' => loc.speedAndImmobilitySectionDescription,
      'collarSignal' => loc.collarSignalSectionDescription,
      _ => throw StateError('Section inconnue : ${section.cle}'),
    };
  }

  void _remplir(Map<String, dynamic> valeurs) {
    for (final champ in _champs) {
      final valeur = valeurs[champ.cle];
      if (valeur != null) {
        _controleurs[champ.cle]!.text = valeur.toString();
      }
    }
  }

  String _detailErreur(http.Response reponse) {
    try {
      final contenu = jsonDecode(utf8.decode(reponse.bodyBytes));
      if (contenu is Map) {
        final detail = contenu['detail'] ?? contenu['message'];
        if (detail != null) return detail.toString();
      }
    } catch (_) {
      // Le serveur n’a pas renvoyé de message JSON exploitable.
    }

    return AppLocalizations.of(context)!
        .settingsServerError(reponse.statusCode);
  }

  Future<void> _charger() async {
    if (mounted) {
      setState(() {
        _chargement = true;
        _erreurChargement = null;
      });
    }

    try {
      final service = AuthService.instance;
      final reponse = await http
          .get(
            service.uriApi('/parametres'),
            headers: service.entetesAutorisation,
          )
          .timeout(const Duration(seconds: 30));

      if (reponse.statusCode < 200 || reponse.statusCode >= 300) {
        throw Exception(_detailErreur(reponse));
      }

      _remplir(_lireValeurs(reponse));
    } catch (_) {
      if (mounted) {
        setState(() {
          _erreurChargement = AppLocalizations.of(context)!.settingsLoadError;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _chargement = false);
      }
    }
  }

  void _afficherMessage(String texte, {bool erreur = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: erreur
              ? const Color(0xFFB33C42)
              : const Color(0xFF246B4C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(
                erreur ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(texte)),
            ],
          ),
        ),
      );
  }

  Future<void> _chargerEtatNotifications() async {
    try {
      if (!CanauxNatifs.disponible) return;
      final messages = await AuthService.instance
          .chargerEtatNotificationsMessages();
      final surveillance = await CanauxNatifs.surveillanceActive();
      if (mounted) {
        setState(() {
          _notificationsMessages = messages;
          _surveillanceActive = surveillance;
        });
      }
    } on PlatformException {
      if (mounted) {
        _afficherMessage(
          AppLocalizations.of(context)!.monitoringOperationError,
          erreur: true,
        );
      }
    } finally {
      if (mounted) setState(() => _chargementNotifications = false);
    }
  }

  Future<void> _actualiserEtatSurveillance() async {
    try {
      final surveillance = await CanauxNatifs.surveillanceActive();
      if (mounted && surveillance != _surveillanceActive) {
        setState(() => _surveillanceActive = surveillance);
      }
    } on PlatformException catch (erreur) {
      debugPrint('État de surveillance indisponible : ${erreur.message}');
    }
  }

  Future<void> _changerNotificationsMessages(bool actives) async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _actionNotifications = true);
    try {
      if (actives) {
        await AuthService.instance.activerNotificationsMessages();
      } else {
        await AuthService.instance.desactiverNotificationsMessages();
      }
      if (mounted) {
        setState(() => _notificationsMessages = actives);
        _afficherMessage(
          actives
              ? loc.messagesNotificationsEnabled
              : loc.messagesNotificationsDisabled,
        );
      }
    } on ErreurApi catch (erreur) {
      _afficherMessage(erreur.message, erreur: true);
    } on PlatformException catch (erreur) {
      _afficherMessage(
        erreur.message ?? loc.monitoringOperationError,
        erreur: true,
      );
    } finally {
      if (mounted) setState(() => _actionNotifications = false);
    }
  }

  Future<void> _basculerSurveillance() async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _actionNotifications = true);
    try {
      if (_surveillanceActive) {
        await CanauxNatifs.arreterSurveillance();
        if (mounted) setState(() => _surveillanceActive = false);
        return;
      }

      final autorise = await CanauxNatifs.demanderPermissionNotifications();
      if (!autorise) {
        _afficherMessage(loc.monitoringPermissionDenied, erreur: true);
        return;
      }
      final auth = AuthService.instance;
      await auth.verifierSessionPourSurveillance();
      final jeton = auth.jeton;
      final jetonRenouvellement = auth.jetonRenouvellement;
      if (jeton == null || jetonRenouvellement == null) {
        throw const ErreurApi('La session utilisateur est indisponible.');
      }
      await CanauxNatifs.demarrerSurveillance(
        urlAlertes: auth.uriApi('/alertes?actives=true&limite=100').toString(),
        jeton: jeton,
        urlRenouvellement: auth.uriApi('/auth/renouveler').toString(),
        jetonRenouvellement: jetonRenouvellement,
        dureeSecondes: _dureeSurveillanceMinutes * 60,
        titreNotification: loc.monitoringActive,
        texteNotification: loc.monitoringRunningDescription,
      );
      if (mounted) setState(() => _surveillanceActive = true);
    } on ErreurApi catch (erreur) {
      _afficherMessage(erreur.message, erreur: true);
    } on PlatformException catch (erreur) {
      _afficherMessage(
        erreur.message ?? loc.monitoringOperationError,
        erreur: true,
      );
    } finally {
      if (mounted) setState(() => _actionNotifications = false);
    }
  }

  String _libelleDuree(int minutes, AppLocalizations loc) {
    if (minutes < 60) return loc.notificationDurationMinutes(minutes);
    return loc.notificationDurationHours(minutes ~/ 60);
  }

  Widget _construireNotifications(AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EEEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080D2B1D),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, color: _vert),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.notificationsTitle,
                  style: const TextStyle(
                    color: _encre,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            loc.notificationsDescription,
            style: const TextStyle(
              color: _texteSecondaire,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _surveillanceActive
                          ? loc.monitoringActive
                          : loc.monitoringInactive,
                      style: const TextStyle(
                        color: _encre,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      loc.monitoringDurationLabel,
                      style: const TextStyle(
                        color: _texteSecondaire,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownButton<int>(
                value: _dureeSurveillanceMinutes,
                onChanged: _actionNotifications || _surveillanceActive
                    ? null
                    : (valeur) {
                        if (valeur != null) {
                          setState(() => _dureeSurveillanceMinutes = valeur);
                        }
                      },
                items: [
                  for (final minutes in [30, 60, 120, 240, 360])
                    DropdownMenuItem(
                      value: minutes,
                      child: Text(_libelleDuree(minutes, loc)),
                    ),
                ],
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _chargementNotifications || _actionNotifications
                  ? null
                  : _basculerSurveillance,
              icon: _actionNotifications
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _surveillanceActive
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                    ),
              label: Text(
                _surveillanceActive ? loc.monitoringStop : loc.monitoringStart,
              ),
            ),
          ),
          const Divider(height: 22),
          Material(
            color: Colors.white,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                loc.messagesNotifications,
                style: const TextStyle(
                  color: _encre,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                loc.messagesNotificationsDescription,
                style: const TextStyle(color: _texteSecondaire, fontSize: 12),
              ),
              value: _notificationsMessages,
              onChanged: _chargementNotifications || _actionNotifications
                  ? null
                  : _changerNotificationsMessages,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enregistrer() async {
    final loc = AppLocalizations.of(context)!;
    final formulaire = _formKey.currentState;
    if (formulaire == null || !formulaire.validate()) return;

    final corps = <String, dynamic>{};

    for (final champ in _champs) {
      final texte = _controleurs[champ.cle]!.text;
      final valeur = _convertirValeur(texte, champ);

      if (valeur == null) {
        _afficherMessage(
          loc.settingsInvalidValue(_libelleChamp(champ, loc)),
          erreur: true,
        );
        return;
      }

      corps[champ.cle] = valeur;
    }

    setState(() => _envoi = true);

    try {
      final service = AuthService.instance;
      final reponse = await http
          .put(
            service.uriApi('/parametres'),
            headers: service.entetesAutorisation,
            body: jsonEncode(corps),
          )
          .timeout(const Duration(seconds: 30));

      if (reponse.statusCode >= 200 && reponse.statusCode < 300) {
        _afficherMessage(loc.settingsSaveSuccess);
      } else {
        _afficherMessage(_detailErreur(reponse), erreur: true);
      }
    } catch (_) {
      _afficherMessage(loc.settingsSaveError, erreur: true);
    } finally {
      if (mounted) {
        setState(() => _envoi = false);
      }
    }
  }

  Widget _construireChargement() {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _vert),
          SizedBox(height: 18),
          Text(
            loc.loadingParameters,
            style: const TextStyle(color: _texteSecondaire),
          ),
        ],
      ),
    );
  }

  Widget _construireErreur() {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEB),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 34,
                color: Color(0xFFB33C42),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loc.loadingImpossible,
              style: TextStyle(
                color: _encre,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _erreurChargement ?? loc.settingsUnexpectedError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _texteSecondaire, height: 1.5),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _charger,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(loc.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireEntete() {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E5F43), Color(0xFF23845B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _vert.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    loc.configuration.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  loc.herdMonitoring,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.herdMonitoringDescription,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    loc.availableParameters(_champs.length),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireChamp(_Champ champ) {
    final loc = AppLocalizations.of(context)!;
    OutlineInputBorder bord(Color couleur, [double epaisseur = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: couleur, width: epaisseur),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _libelleChamp(champ, loc),
            style: const TextStyle(
              color: _encre,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _descriptionChamp(champ, loc),
            style: const TextStyle(
              color: _texteSecondaire,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: _largeurChamp,
            child: TextFormField(
              controller: _controleurs[champ.cle],
              keyboardType: TextInputType.numberWithOptions(
                decimal: !champ.entier,
              ),
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                suffixText: champ.unite.isEmpty ? null : champ.unite,
                filled: true,
                fillColor: const Color(0xFFF8FAF9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: bord(const Color(0xFFE2E9E5)),
                enabledBorder: bord(const Color(0xFFE2E9E5)),
                focusedBorder: bord(_vert, 1.6),
                errorBorder: bord(const Color(0xFFB33C42)),
                focusedErrorBorder: bord(const Color(0xFFB33C42), 1.6),
              ),
              validator: (texte) {
                if (texte == null || texte.trim().isEmpty) {
                  return loc.requiredField;
                }

                if (_convertirValeur(texte, champ) == null) {
                  return champ.entier
                      ? loc.integerRequired
                      : loc.numberRequired;
                }

                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireSection(_SectionParametres section) {
    final loc = AppLocalizations.of(context)!;
    final champsSection = _champs
        .where((champ) => section.cles.contains(champ.cle))
        .toList();

    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EEEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080D2B1D),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: section.couleur.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(section.icone, color: section.couleur),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titreSection(section, loc),
                        style: const TextStyle(
                          color: _encre,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _descriptionSection(section, loc),
                        style: const TextStyle(
                          color: _texteSecondaire,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          for (final champ in champsSection) _construireChamp(champ),
        ],
      ),
    );
  }

  Widget _construireLangue(AppLocalizations loc) {
    final code = Localizations.localeOf(context).languageCode;
    final selection = <String>{code == 'ar' ? 'ar' : 'fr'};

    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EEEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.settingsLanguageSection,
            style: const TextStyle(
              color: _encre,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.languageToggleHint,
            style: const TextStyle(color: _texteSecondaire, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment<String>(
                value: 'fr',
                label: Text(loc.languageFrenchOption),
              ),
              ButtonSegment<String>(
                value: 'ar',
                label: Text(loc.languageArabicOption),
              ),
            ],
            selected: selection,
            onSelectionChanged: (valeurs) {
              final code = valeurs.first;
              appLocaleController.changer(code);
            },
          ),
        ],
      ),
    );
  }

  Widget _construireContenu() {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              _construireEntete(),
              if (CanauxNatifs.disponible) _construireNotifications(loc),
              _construireLangue(loc),
              for (final section in _sections) _construireSection(section),
              const SizedBox(height: 22),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _envoi ? null : _enregistrer,
                  icon: _envoi
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_envoi ? loc.settingsSaving : loc.saveParameters),
                  style: FilledButton.styleFrom(
                    backgroundColor: _vert,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.settingsChangesApplied,
                textAlign: TextAlign.center,
                style: TextStyle(color: _texteSecondaire, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return FondPage(
      image: 'assets/images/parametre.jpg',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: _encre,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 76,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.settingsTitle,
                style: const TextStyle(
                  color: _encre,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                loc.herdMonitoringDescription,
                style: const TextStyle(
                  color: _texteSecondaire,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        body: _chargement
            ? _construireChargement()
            : _erreurChargement != null
            ? _construireErreur()
            : _construireContenu(),
      ),
    );
  }
}
