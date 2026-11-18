import 'package:flutter/material.dart';

/// Affichage de l'image de fond, partagé par toutes les pages.
///   false : image atténuée par un voile blanc (affichage d'origine)
///   true  : image dans ses couleurs d'origine, sans voile
final ValueNotifier<bool> imageNaturelle = ValueNotifier(false);
