package com.example.traceur_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class TraceurFirebaseMessagingService : FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        // Le jeton est récupéré côté Dart via getFcmRegistrationToken.
        // Si votre serveur stocke le jeton, renvoyez-le à nouveau au prochain
        // démarrage de l'application.
        Log.d(TAG, "Nouveau jeton FCM reçu.")
    }

    override fun onMessageReceived(message: RemoteMessage) {
        val donnees = message.data
        Log.d(TAG, "Message FCM reçu. data=$donnees notification=${message.notification != null}")

        val type = donnees["type"]
        if (type == null && message.notification == null) {
            Log.w(TAG, "Message FCM ignoré : champ data 'type' absent.")
            return
        }
        val titre: String
        val texte: String
        when (type) {
            "nouveau_message" -> {
                titre = getString(R.string.message_notification_title)
                texte = getString(R.string.message_notification_body)
            }
            "alerte_animal" -> {
                titre = donnees["title"] ?: "Alerte animal"
                texte = donnees["message"] ?: "Une alerte a été détectée."
            }
            null -> {
                titre = message.notification?.title
                    ?: getString(R.string.message_notification_title)
                texte = message.notification?.body
                    ?: getString(R.string.message_notification_body)
            }
            else -> {
                Log.w(TAG, "Message FCM ignoré : type inconnu '$type'.")
                return
            }
        }
        afficherNotification(titre, texte, donnees)
    }

    private fun afficherNotification(
        titre: String,
        texte: String,
        donnees: Map<String, String>,
    ) {
        val manager = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(
                    CANAL_ID,
                    getString(R.string.message_notification_channel),
                    NotificationManager.IMPORTANCE_HIGH,
                ),
            )
        }

        val ouverture = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("notification_type", donnees["type"])
            putExtra("conversation_id", donnees["conversation_id"])
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            donnees["conversation_id"]?.hashCode() ?: 0,
            ouverture,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CANAL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setPriority(Notification.PRIORITY_HIGH)
                .setDefaults(Notification.DEFAULT_ALL)
        }
        manager.notify(
            donnees["conversation_id"]?.hashCode() ?: System.currentTimeMillis().toInt(),
            builder
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentTitle(titre)
                .setContentText(texte)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .build(),
        )
    }

    companion object {
        private const val TAG = "TraceurFCM"
        private const val CANAL_ID = "traceur_messages"
    }
}