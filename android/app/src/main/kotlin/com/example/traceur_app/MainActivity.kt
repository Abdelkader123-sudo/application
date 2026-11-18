package com.example.traceur_app

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.content.ContextCompat
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var permissionResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        creerCanauxNotification()
    }

    private fun creerCanauxNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(
                NotificationChannel(
                    CANAL_MESSAGES_ID,
                    getString(R.string.message_notification_channel),
                    NotificationManager.IMPORTANCE_HIGH,
                ),
            )
            manager.createNotificationChannel(
                NotificationChannel(
                    CANAL_ALERTES_ID,
                    "Alertes animaux",
                    NotificationManager.IMPORTANCE_HIGH,
                ),
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "traceur_app/notifications",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestNotificationPermission" -> demanderPermission(result)
                "getFcmRegistrationToken" -> obtenirJetonFcm(result)
                "startAlertMonitoring" -> demarrerSurveillance(call.arguments, result)
                "stopAlertMonitoring" -> {
                    stopService(Intent(this, AlertMonitoringService::class.java))
                    result.success(null)
                }
                "isAlertMonitoringActive" -> result.success(AlertMonitoringService.running)
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "traceur_app/notifications/open_events",
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                notificationEventSink = events
                pendingNotification?.let {
                    events?.success(it)
                    pendingNotification = null
                }
            }

            override fun onCancel(arguments: Any?) {
                notificationEventSink = null
            }
        })
        publierNotificationIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        publierNotificationIntent(intent)
    }

    private fun publierNotificationIntent(intent: Intent?) {
        val type = intent?.getStringExtra("notification_type")
            ?: intent?.getStringExtra("type")
            ?: return
        val donnees = mutableMapOf<String, String>("notification_type" to type)
        intent?.getStringExtra("conversation_id")?.let {
            donnees["conversation_id"] = it
        }
        publierOuGarderNotification(donnees)
    }

    private fun notificationsAutorisees(): Boolean {
        val gestionnaire = getSystemService(android.app.NotificationManager::class.java)
        return gestionnaire.areNotificationsEnabled() &&
                (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
                        ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.POST_NOTIFICATIONS,
                        ) == PackageManager.PERMISSION_GRANTED)
    }

    private fun demanderPermission(result: MethodChannel.Result) {
        if (notificationsAutorisees()) {
            result.success(true)
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(false)
            return
        }
        if (permissionResult != null) {
            result.error("permission_in_progress", "Une demande est déjà en cours.", null)
            return
        }
        permissionResult = result
        requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            REQUEST_NOTIFICATIONS,
        )
    }

    private fun obtenirJetonFcm(result: MethodChannel.Result) {
        try {
            FirebaseMessaging.getInstance().token
                .addOnSuccessListener { jeton ->
                    if (jeton.isNullOrBlank()) {
                        result.error(
                            "empty_fcm_token",
                            "Firebase n’a pas fourni de jeton FCM.",
                            null,
                        )
                    } else {
                        result.success(jeton)
                    }
                }
                .addOnFailureListener { erreur ->
                    result.error(
                        "fcm_token_unavailable",
                        erreur.localizedMessage ?: "Jeton FCM indisponible.",
                        null,
                    )
                }
        } catch (erreur: IllegalStateException) {
            result.error(
                "firebase_not_configured",
                "Firebase n’est pas configuré pour cette application.",
                null,
            )
        }
    }

    private fun demarrerSurveillance(arguments: Any?, result: MethodChannel.Result) {
        val donnees = arguments as? Map<*, *>
        val url = donnees?.get("url") as? String
        val jeton = donnees?.get("token") as? String
        val urlRenouvellement = donnees?.get("refreshUrl") as? String
        val jetonRenouvellement = donnees?.get("refreshToken") as? String
        val duree = donnees?.get("durationSeconds") as? Int
        if (url.isNullOrBlank() || jeton.isNullOrBlank() ||
            urlRenouvellement.isNullOrBlank() || jetonRenouvellement.isNullOrBlank() ||
            duree == null || duree <= 0
        ) {
            result.error("invalid_arguments", "Paramètres de surveillance invalides.", null)
            return
        }
        val dureeLimitee = duree.coerceAtMost(6 * 60 * 60)
        val intent = Intent(this, AlertMonitoringService::class.java).apply {
            putExtra(AlertMonitoringService.EXTRA_URL, url)
            putExtra(AlertMonitoringService.EXTRA_TOKEN, jeton)
            putExtra(AlertMonitoringService.EXTRA_REFRESH_URL, urlRenouvellement)
            putExtra(AlertMonitoringService.EXTRA_REFRESH_TOKEN, jetonRenouvellement)
            putExtra(AlertMonitoringService.EXTRA_DURATION, dureeLimitee)
            putExtra(
                AlertMonitoringService.EXTRA_DEADLINE,
                android.os.SystemClock.elapsedRealtime() + dureeLimitee * 1000L,
            )
            putExtra(
                AlertMonitoringService.EXTRA_TITLE,
                donnees["notificationTitle"] as? String,
            )
            putExtra(
                AlertMonitoringService.EXTRA_TEXT,
                donnees["notificationText"] as? String,
            )
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            result.success(null)
        } catch (erreur: Exception) {
            result.error(
                "monitoring_start_failed",
                erreur.localizedMessage ?: "Impossible de démarrer la surveillance.",
                null,
            )
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_NOTIFICATIONS) {
            permissionResult?.success(
                grantResults.isNotEmpty() &&
                        grantResults[0] == PackageManager.PERMISSION_GRANTED,
            )
            permissionResult = null
        }
    }

    companion object {
        private const val REQUEST_NOTIFICATIONS = 7412
        private const val CANAL_MESSAGES_ID = "traceur_messages"
        private const val CANAL_ALERTES_ID = "traceur_alertes_animaux"
        @Volatile
        private var notificationEventSink: EventChannel.EventSink? = null
        @Volatile
        private var pendingNotification: Map<String, String>? = null

        private fun publierOuGarderNotification(donnees: Map<String, String>) {
            val sink = notificationEventSink
            if (sink == null) {
                pendingNotification = donnees
            } else {
                sink.success(donnees)
            }
        }
    }
}