// lib/accueil_page.dart
import 'package:flutter/material.dart';
import 'package:traceur_app/l10n/app_localizations.dart';
import 'package:traceur_app/locale_controller.dart';

import 'login_page.dart';

const Color _vertFonce = Color(0xFF0F3A2B);
const Color _vertMoyen = Color(0xFF174C38);
const Color _vert = Color(0xFF23845B);
const Color _menthe = Color(0xFF8FE3BC);
const Color _fond = Color(0xFFF3F8F5);
const Color _encre = Color(0xFF18352C);
const Color _secondaire = Color(0xFF66766E);
const Color _bordure = Color(0xFFE2EBE6);

const double _largeurMax = 520; // barre du bas
const double _largeurContenu = 1000; // contenu principal

class AccueilPage extends StatelessWidget {
  /// Écran affiché après une connexion réussie (votre page principale actuelle).
  final Widget Function() versApplication;

  const AccueilPage({super.key, required this.versApplication});

  void _commencer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginPage(versApplication: versApplication),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _fond,
      body: Column(
        children: [
          _entete(context, loc),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _largeurContenu),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 16),
                  child: _Apparition(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.roleTitle,
                          style: const TextStyle(
                            color: _encre,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: Text(
                            loc.appRoleDescription,
                            style: const TextStyle(
                              color: _secondaire,
                              fontSize: 14.5,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _fonctionsGrille(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _barreBas(context, loc),
        ],
      ),
    );
  }

  // ---- En-tête vert arrondi avec logo --------------------------------------
  Widget _entete(BuildContext context, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_vertFonce, _vertMoyen, _vert],
          stops: [0.0, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -60, right: -50, child: _cercleDeco(200, 0.07)),
          Positioned(bottom: -70, left: -60, child: _cercleDeco(190, 0.06)),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: _choixLangue(context, loc),
                    ),
                    const _Logo(),
                    const SizedBox(height: 18),
                    const Text(
                      'TRACEUR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.trackingByGps,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _menthe.withValues(alpha: 0.95),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _choixLangue(BuildContext context, AppLocalizations loc) {
    final langue = Localizations.localeOf(context).languageCode;
    return PopupMenuButton<String>(
      tooltip: loc.languageSelection,
      iconColor: Colors.white,
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

  // ---- Barre du bas : bouton Commencer fixé --------------------------------
  Widget _barreBas(BuildContext context, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: _bordure)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF183A2C).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _largeurMax),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _vert,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      onPressed: () => _commencer(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(loc.start),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: _secondaire,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        loc.authorizedAccess,
                        style: const TextStyle(
                          color: _secondaire,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---- Fonctionnalités : alignées horizontalement, sans défilement ----------
  Widget _fonctionsGrille(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final items = <(IconData, String, String)>[
      (
        Icons.location_searching_rounded,
        loc.liveLocation,
        loc.liveLocationDescription,
      ),
      (Icons.shield_outlined, loc.securityZone, loc.securityZoneDescription),
      (
        Icons.notifications_active_outlined,
        loc.instantAlerts,
        loc.instantAlertsDescription,
      ),
      (Icons.route_rounded, loc.routeHistory, loc.routeHistoryDescription),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final cartes = [for (final it in items) _fonction(it.$1, it.$2, it.$3)];

        // Large écran : les 4 cartes sur une seule ligne.
        if (c.maxWidth >= 760) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var k = 0; k < cartes.length; k++) ...[
                  if (k > 0) const SizedBox(width: 14),
                  Expanded(child: cartes[k]),
                ],
              ],
            ),
          );
        }

        // Écran étroit : 2 cartes par ligne (toujours sans défilement).
        Widget ligne(Widget a, Widget b) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: a),
              const SizedBox(width: 12),
              Expanded(child: b),
            ],
          ),
        );
        return Column(
          children: [
            ligne(cartes[0], cartes[1]),
            const SizedBox(height: 12),
            ligne(cartes[2], cartes[3]),
          ],
        );
      },
    );
  }

  Widget _fonction(IconData icone, String titre, String texte) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bordure),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10183A2C),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _vert.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icone, color: _vert, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            titre,
            style: const TextStyle(
              color: _encre,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            texte,
            style: const TextStyle(
              color: _secondaire,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cercleDeco(double taille, double opacite) => Container(
    width: taille,
    height: taille,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: opacite),
    ),
  );
}

// ---------------------------------------------------------------------------
// Logo : pastille de géolocalisation avec ondes de signal
// ---------------------------------------------------------------------------
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    Widget onde(double taille, double opacite) => Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacite),
          width: 1.4,
        ),
      ),
    );

    return SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          onde(128, 0.10),
          onde(104, 0.18),
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFD9F5E7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_on_rounded,
              color: _vert,
              size: 44,
            ),
          ),
          Positioned(
            top: 22,
            right: 20,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _menthe,
                shape: BoxShape.circle,
                border: Border.all(color: _vertMoyen, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Petite animation d'apparition (fondu + glissement)
// ---------------------------------------------------------------------------
class _Apparition extends StatelessWidget {
  final Widget child;
  const _Apparition({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 24),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
