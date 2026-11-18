import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CanauxNatifs {
  CanauxNatifs._();

  static const MethodChannel _methodes = MethodChannel(
    'traceur_app/notifications',
  );
  static const EventChannel _evenementsNotification = EventChannel(
    'traceur_app/notifications/open_events',
  );

  static bool get disponible =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<T?> _appeler<T>(
    String methode, [
    Map<String, Object?>? arguments,
  ]) async {
    try {
      return await _methodes.invokeMethod<T>(methode, arguments);
    } on MissingPluginException catch (erreur) {
      throw PlatformException(
        code: 'notifications_channel_unavailable',
        message:
            'Le canal natif des notifications est indisponible. '
            'Vérifiez que l’application Android a été reconstruite et réinstallée.',
        details: erreur.message,
      );
    }
  }

  static Stream<Map<String, Object?>> get ouverturesNotifications =>
      _evenementsNotification
          .receiveBroadcastStream()
          .where((event) {
            return event is Map;
          })
          .map((event) => Map<String, Object?>.from(event as Map));

  static Future<bool> demanderPermissionNotifications() async {
    if (!disponible) return false;
    return await _appeler<bool>('requestNotificationPermission') ?? false;
  }

  static Future<String> obtenirJetonFcm() async {
    final jeton = await _appeler<String>('getFcmRegistrationToken');
    if (jeton == null || jeton.isEmpty) {
      throw PlatformException(
        code: 'empty_fcm_token',
        message: 'Firebase n’a pas fourni de jeton FCM.',
      );
    }
    return jeton;
  }

  static Future<void> demarrerSurveillance({
    required String urlAlertes,
    required String jeton,
    required String urlRenouvellement,
    required String jetonRenouvellement,
    required int dureeSecondes,
    required String titreNotification,
    required String texteNotification,
  }) async {
    if (!disponible) {
      throw PlatformException(
        code: 'unsupported_platform',
        message: 'La surveillance des alertes est disponible sur Android.',
      );
    }
    await _appeler<void>('startAlertMonitoring', {
      'url': urlAlertes,
      'token': jeton,
      'refreshUrl': urlRenouvellement,
      'refreshToken': jetonRenouvellement,
      'durationSeconds': dureeSecondes,
      'notificationTitle': titreNotification,
      'notificationText': texteNotification,
    });
  }

  static Future<void> arreterSurveillance() async {
    if (!disponible) return;
    await _appeler<void>('stopAlertMonitoring');
  }

  static Future<bool> surveillanceActive() async {
    if (!disponible) return false;
    return await _appeler<bool>('isAlertMonitoringActive') ?? false;
  }
}
