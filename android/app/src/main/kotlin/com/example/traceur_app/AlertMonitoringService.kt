package com.example.traceur_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.SystemClock
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors

class AlertMonitoringService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private val executor = Executors.newSingleThreadExecutor()
    private val alertesNotifiees = mutableSetOf<String>()
    private var urlAlertes: String? = null
    private var urlRenouvellement: String? = null
    private var jeton: String? = null
    private var jetonRenouvellement: String? = null
    private var titreNotification: String? = null
    private var texteNotification: String? = null
    private var echeance = 0L
    private var wakeLock: PowerManager.WakeLock? = null

    override fun onCreate() {
        super.onCreate()
        creerCanaux()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val url = intent?.getStringExtra(EXTRA_URL)
        val token = intent?.getStringExtra(EXTRA_TOKEN)
        val refreshUrl = intent?.getStringExtra(EXTRA_REFRESH_URL)
        val refreshToken = intent?.getStringExtra(EXTRA_REFRESH_TOKEN)
        val duree = intent?.getIntExtra(EXTRA_DURATION, 0) ?: 0
        if (url.isNullOrBlank() || token.isNullOrBlank() ||
            refreshUrl.isNullOrBlank() || refreshToken.isNullOrBlank() || duree <= 0
        ) {
            stopSelf(startId)
            return START_NOT_STICKY
        }
        val uri = Uri.parse(url)
        val uriRenouvellement = Uri.parse(refreshUrl)
        if (uri.host.isNullOrBlank() || uri.scheme !in listOf("https", "http") ||
            uriRenouvellement.host.isNullOrBlank() ||
            uriRenouvellement.scheme !in listOf("https", "http")
        ) {
            stopSelf(startId)
            return START_NOT_STICKY
        }

        urlAlertes = url
        urlRenouvellement = refreshUrl
        jeton = token
        jetonRenouvellement = refreshToken
        val dureeSecondes = duree.coerceAtMost(DUREE_MAX_SECONDES)
        echeance = intent?.getLongExtra(
            EXTRA_DEADLINE,
            SystemClock.elapsedRealtime() + dureeSecondes * 1000L,
        ) ?: SystemClock.elapsedRealtime() + dureeSecondes * 1000L
        titreNotification = intent?.getStringExtra(EXTRA_TITLE)
        texteNotification = intent?.getStringExtra(EXTRA_TEXT)
        running = true
        startForeground(ID_NOTIFICATION_SERVICE, construireNotificationService())
        prendreWakeLock(dureeSecondes * 1000L)
        verifierAlertes()
        return START_REDELIVER_INTENT
    }

    private fun prendreWakeLock(dureeMs: Long) {
        try {
            wakeLock?.let { if (it.isHeld) it.release() }
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = pm.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "traceur:alert_monitoring",
            ).apply {
                setReferenceCounted(false)
                acquire(dureeMs)
            }
        } catch (erreur: Exception) {
            Log.e(TAG, "Impossible d'obtenir le WakeLock.", erreur)
        }
    }

    private fun relacherWakeLock() {
        try {
            wakeLock?.let { if (it.isHeld) it.release() }
        } catch (erreur: Exception) {
            Log.e(TAG, "Impossible de relâcher le WakeLock.", erreur)
        }
        wakeLock = null
    }

    private fun verifierAlertes() {
        if (SystemClock.elapsedRealtime() >= echeance) {
            stopSelf()
            return
        }
        executor.execute {
            try {
                val alertes = lireAlertes()
                Log.d(TAG, "Alertes reçues : ${alertes.size}")
                handler.post {
                    alertes.forEach(::notifierAlerteNouvelle)
                    actualiserNotificationService(null)
                    programmerProchaineVerification()
                }
            } catch (erreur: Exception) {
                Log.e(TAG, "Échec de la vérification des alertes.", erreur)
                handler.post {
                    actualiserNotificationService(getString(R.string.monitoring_retry))
                    programmerProchaineVerification()
                }
            }
        }
    }

    private fun programmerProchaineVerification() {
        if (SystemClock.elapsedRealtime() >= echeance) {
            stopSelf()
        } else {
            handler.postDelayed(::verifierAlertes, INTERVALLE_VERIFICATION_MS)
        }
    }

    private fun lireAlertes(): List<JSONObject> {
        var connexion = creerConnexionAlertes()
        try {
            var code = connexion.responseCode
            if (code == HttpURLConnection.HTTP_UNAUTHORIZED) {
                connexion.disconnect()
                renouvelerJeton()
                connexion = creerConnexionAlertes()
                code = connexion.responseCode
            }
            if (code !in 200..299) {
                throw IllegalStateException("Le serveur a répondu avec le code $code.")
            }
            val corps = connexion.inputStream.bufferedReader().use { it.readText() }
            val tableau = JSONArray(corps)
            return (0 until tableau.length()).mapNotNull { index ->
                tableau.optJSONObject(index)
            }
        } finally {
            connexion.disconnect()
        }
    }

    private fun creerConnexionAlertes(): HttpURLConnection {
        val connexion = URL(urlAlertes ?: throw IllegalStateException("URL absente."))
            .openConnection() as HttpURLConnection
        connexion.requestMethod = "GET"
        connexion.connectTimeout = 15_000
        connexion.readTimeout = 15_000
        val token = jeton ?: throw IllegalStateException("Jeton absent.")
        connexion.setRequestProperty("Authorization", "Bearer $token")
        connexion.setRequestProperty("Accept", "application/json")
        return connexion
    }

    private fun renouvelerJeton() {
        val connexion = URL(
            urlRenouvellement
                ?: throw IllegalStateException("URL de renouvellement absente."),
        ).openConnection() as HttpURLConnection
        try {
            connexion.requestMethod = "POST"
            connexion.connectTimeout = 15_000
            connexion.readTimeout = 15_000
            connexion.doOutput = true
            connexion.setRequestProperty("Content-Type", "application/json")
            connexion.setRequestProperty("Accept", "application/json")
            val refreshToken = jetonRenouvellement
                ?: throw IllegalStateException("Jeton de renouvellement absent.")
            connexion.outputStream.bufferedWriter().use { writer ->
                writer.write(JSONObject().put("refresh_token", refreshToken).toString())
            }
            val code = connexion.responseCode
            if (code !in 200..299) {
                throw IllegalStateException(
                    "Le renouvellement de session a échoué (code $code).",
                )
            }
            val corps = connexion.inputStream.bufferedReader().use { it.readText() }
            val reponse = JSONObject(corps)
            jeton = reponse.optString("token").takeIf { it.isNotBlank() }
                ?: throw IllegalStateException("Le serveur n’a pas renouvelé le jeton.")
            jetonRenouvellement =
                reponse.optString("refresh_token").takeIf { it.isNotBlank() }
                    ?: throw IllegalStateException(
                        "Le serveur n’a pas renouvelé le jeton de session.",
                    )
        } finally {
            connexion.disconnect()
        }
    }

    private fun notifierAlerteNouvelle(alerte: JSONObject) {
        val animal = alerte.optString("animal_id", getString(R.string.unknown_animal))
        val type = alerte.optString("type", "")
        val timestamp = alerte.optString("timestamp", "")
        val cle = "$animal|$type|$timestamp"
        if (!alertesNotifiees.add(cle)) return
        if (alertesNotifiees.size > MAX_ALERTES_MEMORISEES) {
            val anciennes = alertesNotifiees.iterator()
            if (anciennes.hasNext()) {
                anciennes.next()
                anciennes.remove()
            }
        }
        val message = alerte.optString("message").ifBlank {
            getString(R.string.monitoring_alert_detected)
        }
        val notification = construireNotification(
            getString(R.string.monitoring_alert_title),
            "$animal : $message",
            cle.hashCode(),
            canal = CANAL_ALERTES_ID,
        )
        getSystemService(NotificationManager::class.java)
            .notify(cle.hashCode(), notification)
    }

    private fun actualiserNotificationService(erreur: String?) {
        val notification = construireNotificationService(erreur)
        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(ID_NOTIFICATION_SERVICE, notification)
    }

    private fun construireNotificationService(erreur: String? = null): Notification {
        val texte = erreur ?: texteNotification ?: getString(R.string.monitoring_running)
        return construireNotification(
            titreNotification ?: getString(R.string.monitoring_title),
            texte,
            ID_NOTIFICATION_SERVICE,
            canal = CANAL_ID,
            ongoing = true,
        )
    }

    private fun construireNotification(
        titre: String,
        texte: String,
        id: Int,
        canal: String,
        ongoing: Boolean = false,
    ): Notification {
        val ouverture = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("notification_type", "animal_alert")
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            id,
            ouverture,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, canal)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this).apply {
                if (!ongoing) {
                    setPriority(Notification.PRIORITY_HIGH)
                    setDefaults(Notification.DEFAULT_ALL)
                }
            }
        }
        return builder
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle(titre)
            .setContentText(texte)
            .setStyle(Notification.BigTextStyle().bigText(texte))
            .setContentIntent(pendingIntent)
            .setAutoCancel(!ongoing)
            .setOngoing(ongoing)
            .build()
    }

    private fun creerCanaux() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(
                NotificationChannel(
                    CANAL_ID,
                    getString(R.string.monitoring_channel),
                    NotificationManager.IMPORTANCE_LOW,
                ),
            )
            manager.createNotificationChannel(
                NotificationChannel(
                    CANAL_ALERTES_ID,
                    "Alertes animaux",
                    NotificationManager.IMPORTANCE_HIGH,
                ).apply {
                    enableVibration(true)
                },
            )
        }
    }

    override fun onTimeout(startId: Int, fgsType: Int) {
        stopSelf(startId)
    }

    override fun onDestroy() {
        running = false
        handler.removeCallbacksAndMessages(null)
        executor.shutdownNow()
        relacherWakeLock()
        stopForeground(true)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        const val EXTRA_URL = "url"
        const val EXTRA_TOKEN = "token"
        const val EXTRA_REFRESH_URL = "refreshUrl"
        const val EXTRA_REFRESH_TOKEN = "refreshToken"
        const val EXTRA_DURATION = "durationSeconds"
        const val EXTRA_TITLE = "notificationTitle"
        const val EXTRA_TEXT = "notificationText"
        const val EXTRA_DEADLINE = "deadlineElapsedRealtime"
        @Volatile
        var running = false
            private set

        private const val TAG = "TraceurAlertMonitor"
        private const val CANAL_ID = "traceur_alert_monitoring"
        private const val CANAL_ALERTES_ID = "traceur_alertes_animaux"
        private const val ID_NOTIFICATION_SERVICE = 1001
        private const val INTERVALLE_VERIFICATION_MS = 30_000L
        private const val DUREE_MAX_SECONDES = 6 * 60 * 60
        private const val MAX_ALERTES_MEMORISEES = 200
    }
}