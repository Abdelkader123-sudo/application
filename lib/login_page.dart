// lib/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traceur_app/l10n/app_localizations.dart';
import 'package:traceur_app/locale_controller.dart';

import 'auth_service.dart';
import 'nouveau_client_page.dart';

/// Image de fond de la page de connexion.
/// Ajoutez le fichier dans assets/images/ (déjà déclaré dans pubspec.yaml)
/// ou remplacez le nom par une image existante (ex. Groupe.jpg).
/// Si l'image est introuvable, un dégradé vert s'affiche à la place.
const String _imageFond = 'assets/images/connexion.jpg';

/// Force du voile noir sur l'image (0 = aucune, 0.3 = léger, 0.6 = fort).
const double _opaciteVoile = 0.12;

const Color _encre = Color(0xFF18352C);
const Color _vert = Color(0xFF23845B);
const Color _vertClair = Color(0xFF2FA06F);
const Color _vertFonce = Color(0xFF0F3A2B);
const Color _secondaire = Color(0xFF708078);
const Color _rouge = Color(0xFFB33C42);
const Color _bordure = Color(0xFFE3EAE6);

class LoginPage extends StatefulWidget {
  final Widget Function() versApplication;

  const LoginPage({super.key, required this.versApplication});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _cle = GlobalKey<FormState>();
  final _numeroClient = TextEditingController();
  final _nom = TextEditingController();
  final _mdp = TextEditingController();

  String? _erreur;
  bool _envoi = false;
  bool _masquer = true;
  bool _nouveauClientVisible = false;
  int _appuis = 0;
  DateTime? _dernierAppui;

  String _traduireErreur(String message, AppLocalizations loc) {
    if (message ==
        'Connexion impossible. Vérifiez votre réseau puis réessayez.') {
      return loc.authNetworkError;
    }
    if (message == 'Certaines informations sont invalides.') {
      return loc.authInvalidInformation;
    }
    final code = RegExp(r'^Erreur serveur \((\d+)\)\.$').firstMatch(message);
    if (code != null) {
      return loc.authServerError(int.parse(code.group(1)!));
    }
    return message;
  }

  Widget _choixLangue(AppLocalizations loc) {
    final langue = Localizations.localeOf(context).languageCode;
    return PopupMenuButton<String>(
      tooltip: loc.languageSelection,
      icon: const Icon(Icons.language_rounded),
      onSelected: appLocaleController.changer,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'fr',
          child: Row(
            children: [
              Icon(langue == 'fr' ? Icons.check : Icons.language, size: 20),
              const SizedBox(width: 10),
              Text(loc.languageFrenchOption),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'ar',
          child: Row(
            children: [
              Icon(langue == 'ar' ? Icons.check : Icons.language, size: 20),
              const SizedBox(width: 10),
              Text(loc.languageArabicOption),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _numeroClient.dispose();
    _nom.dispose();
    _mdp.dispose();
    super.dispose();
  }

  void _compterAppui() {
    final maintenant = DateTime.now();
    if (_dernierAppui == null ||
        maintenant.difference(_dernierAppui!) > const Duration(seconds: 2)) {
      _appuis = 0;
    }
    _dernierAppui = maintenant;
    _appuis++;
    if (_appuis >= 5 && !_nouveauClientVisible) {
      setState(() => _nouveauClientVisible = true);
    }
  }

  Future<void> _valider() async {
    if (!_cle.currentState!.validate()) return;
    setState(() {
      _envoi = true;
      _erreur = null;
    });
    try {
      final service = AuthService.instance;
      final verificationRequise = await service.connecter(
        _numeroClient.text.trim(),
        _nom.text.trim(),
        _mdp.text,
      );
      if (verificationRequise) {
        await service.verifierEmpreinte(
          'Vérifiez votre identité pour ouvrir votre session.',
        );
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => widget.versApplication()),
        (_) => false,
      );
    } on ErreurApi catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = e.message;
        _envoi = false;
      });
      if (AuthService.instance.connecte) {
        try {
          await AuthService.instance.deconnecter();
        } on ErreurApi catch (erreur) {
          if (!mounted) return;
          setState(() => _erreur = '${_erreur!} ${erreur.message}');
        }
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = 'Vérification biométrique impossible : ${e.code}.';
        _envoi = false;
      });
      try {
        await AuthService.instance.deconnecter();
      } on ErreurApi catch (erreur) {
        if (!mounted) return;
        setState(() => _erreur = '${_erreur!} ${erreur.message}');
      }
    }
  }

  // ---- Champ de saisie : libellé au-dessus, indication dans le champ -------
  InputDecoration _deco(String indication, IconData icone, {Widget? suffixe}) {
    OutlineInputBorder bord(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      hintText: indication,
      hintStyle: TextStyle(
        color: _secondaire.withValues(alpha: 0.75),
        fontSize: 14.5,
      ),
      prefixIcon: Icon(icone, color: _vert, size: 21),
      suffixIcon: suffixe,
      filled: true,
      fillColor: const Color(0xFFF5F9F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
      border: bord(_bordure),
      enabledBorder: bord(_bordure),
      focusedBorder: bord(_vert, 1.8),
      errorBorder: bord(_rouge),
      focusedErrorBorder: bord(_rouge, 1.8),
    );
  }

  Widget _champ(String etiquette, Widget champ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: Text(
            etiquette,
            style: const TextStyle(
              color: _encre,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        champ,
      ],
    );
  }

  // ---- Fond : image + voile léger ------------------------------------------
  Widget _fond() {
    final degrade = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_vertFonce, Color(0xFF174C38), _vert],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _imageFond,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => degrade,
        ),
        // Voile très léger et neutre : l'image reste bien visible.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: _opaciteVoile + 0.10),
                Colors.black.withValues(alpha: _opaciteVoile),
                Colors.black.withValues(alpha: _opaciteVoile + 0.10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [_choixLangue(loc)],
      ),
      body: Listener(
        onPointerUp: (_) => _compterAppui(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _fond(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.97),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.28),
                            blurRadius: 44,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: _corps(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Logo avec halo ------------------------------------------------------
  Widget _logo() {
    return Center(
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _vert.withValues(alpha: 0.08),
          border: Border.all(color: _vert.withValues(alpha: 0.16)),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [_vertClair, _vert],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _vert.withValues(alpha: 0.38),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(Icons.location_on_rounded, color: Colors.white, size: 34),
        ),
      ),
    );
  }

  Widget _corps() {
    final loc = AppLocalizations.of(context)!;
    return Form(
      key: _cle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _logo(),
          const SizedBox(height: 18),
          Text(
            loc.authWelcome,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _encre,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.authLoginDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _secondaire,
              height: 1.5,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 26),
          _champ(
            'Code ferme',
            TextFormField(
              controller: _numeroClient,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final numero = v?.trim() ?? '';
                if (numero.isNotEmpty && !RegExp(r'^\d{8}$').hasMatch(numero)) {
                  return 'Saisissez les 8 chiffres de votre code ferme.';
                }
                return null;
              },
              decoration: _deco('Ex. 01234567', Icons.business_outlined),
            ),
          ),
          const SizedBox(height: 16),
          _champ(
            loc.authName,
            TextFormField(
              controller: _nom,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              decoration: _deco(
                loc.authEnterName,
                Icons.person_outline_rounded,
              ),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return loc.authNameRequired;
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          _champ(
            loc.authPassword,
            TextFormField(
              controller: _mdp,
              obscureText: _masquer,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _valider(),
              autofillHints: [AutofillHints.password],
              decoration: _deco(
                '••••••••',
                Icons.lock_outline_rounded,
                suffixe: IconButton(
                  tooltip: _masquer
                      ? loc.authShowPassword
                      : loc.authHidePassword,
                  icon: Icon(
                    _masquer
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _secondaire,
                    size: 21,
                  ),
                  onPressed: () => setState(() => _masquer = !_masquer),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return loc.authPasswordRequired;
                }
                return null;
              },
            ),
          ),
          if (_erreur != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _rouge.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: _rouge, size: 19),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _traduireErreur(_erreur!, loc),
                      style: const TextStyle(color: _rouge, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 26),
          // Bouton avec dégradé et ombre colorée
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: _envoi
                    ? [
                        _vert.withValues(alpha: 0.6),
                        _vert.withValues(alpha: 0.6),
                      ]
                    : const [_vertClair, _vert],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: _envoi
                  ? null
                  : [
                      BoxShadow(
                        color: _vert.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              onPressed: _envoi ? null : _valider,
              child: _envoi
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(loc.login),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: _bordure),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 15,
                color: _secondaire,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  loc.authorizedAccess,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _secondaire, fontSize: 12),
                ),
              ),
            ],
          ),
          if (_nouveauClientVisible) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _envoi
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NouveauClientPage(
                          versApplication: widget.versApplication,
                        ),
                      ),
                    ),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Nouveau client'),
            ),
          ],
        ],
      ),
    );
  }
}
