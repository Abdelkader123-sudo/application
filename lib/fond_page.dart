import 'package:flutter/material.dart';

import 'fond_controller.dart';

/// Fond de page réutilisable. Le bouton de la barre de navigation bascule entre :
///
/// - affichage atténué : l'image est recouverte d'un voile blanc (comme avant) ;
/// - affichage naturel : l'image apparaît dans ses couleurs d'origine, sans
///   voile. Un léger dégradé clair en haut garde le titre de la page lisible.
///
/// Les couleurs ne sont jamais inversées (pas de noir/blanc).
///
/// Utilisation :
///   FondPage(
///     image: 'assets/images/Alerte.png',
///     child: Scaffold(backgroundColor: Colors.transparent, ...),
///   )
class FondPage extends StatelessWidget {
  const FondPage({
    super.key,
    required this.image,
    required this.child,
  });

  final String image;
  final Widget child;

  /// Voile blanc de l'affichage atténué (même valeurs qu'avant).
  static const Color _voile = Color(0xFFF4F7F5);
  static const double _opaciteAttenue = 0.78;

  /// Voile de l'affichage naturel : 0 = couleurs pures de l'image.
  /// Mets par exemple 0.10 pour un très léger voile.
  static const double _opaciteNaturelle = 0.0;

  /// Hauteur du dégradé qui protège le titre en mode naturel.
  static const double _hauteurDegrade = 150;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: imageNaturelle,
      builder: (context, naturelle, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            // Voile blanc : fondu entre les deux affichages.
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: _voile.withValues(
                alpha: naturelle ? _opaciteNaturelle : _opaciteAttenue,
              ),
            ),
            // Dégradé clair en haut : garde le titre lisible en mode naturel.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _hauteurDegrade,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: naturelle ? 1 : 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _voile.withValues(alpha: 0.92),
                          _voile.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            child,
          ],
        );
      },
    );
  }
}

/// Panneau à poser autour d'un contenu qui se trouve directement sur le fond
/// (tableau, liste, texte). En affichage naturel, il prend un fond blanc
/// translucide pour que le texte reste toujours lisible ; en affichage atténué,
/// il reste transparent (rendu d'origine).
///
///   PanneauLisible(child: tableau)
class PanneauLisible extends StatelessWidget {
  const PanneauLisible({
    super.key,
    required this.child,
    this.rayon = 20,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double rayon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: imageNaturelle,
      builder: (context, naturelle, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: naturelle ? 0.90 : 0.0),
            borderRadius: BorderRadius.circular(rayon),
          ),
          child: child,
        );
      },
    );
  }
}