# traceur_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Messagerie

La page Messages utilise le même backend et le même jeton JWT que la connexion.
Les conversations et les messages sont enregistrés dans MongoDB par le backend
FastAPI. Les endpoints protégés sont :

- `GET /messagerie/utilisateurs` : interlocuteurs disponibles ;
- `GET /messagerie/conversations` : conversations de l’utilisateur connecté ;
- `POST /messagerie/conversations/direct` : ouvrir ou retrouver une discussion privée ;
- `POST /messagerie/conversations/groupe` : créer un groupe ;
- `GET /messagerie/conversations/{id}/messages` et `POST` sur cette route :
  lire et envoyer les messages ;
- `POST /messagerie/conversations/{id}/membres` : ajouter des participants à un groupe.

Les nouveaux échanges apparaissent dans le chat grâce à une actualisation périodique.
Déployer le backend avant de publier une version de l’application qui utilise ces routes.

## Notifications Android

Les contrôles de notifications se trouvent dans **Réglages**. La surveillance
des alertes démarre à la demande de l’utilisateur, vérifie
`GET /alertes?actives=true&limite=100` toutes les 30 secondes et s’arrête après
la durée sélectionnée (30 minutes à 6 heures) ou à la demande. Elle utilise un
foreground service Android et nécessite une connexion Internet ainsi que
l’autorisation de notifications. Le service peut continuer lorsque l’application
quitte l’écran et renouvelle sa session si le jeton d’accès expire. Android peut
toutefois interrompre un service après un arrêt forcé de l’application, un
redémarrage du téléphone ou certaines restrictions d’économie d’énergie.

La connexion temps réel (WebSocket) est, elle, suspendue lorsque l’application
passe en arrière-plan puis rétablie à son retour. Un état « déconnecté » temporaire
dans l’application ne signifie donc pas que la session utilisateur a été effacée.

Les appels natifs passent par `lib/native/canaux.dart` :

- `traceur_app/notifications` : permission, jeton d’enregistrement FCM,
  démarrage/arrêt et état de la surveillance ;
- `traceur_app/notifications/open_events` : ouverture de l’onglet Alertes ou
  Messages après un appui sur une notification.

Les notifications de messages sont envoyées par Firebase Cloud Messaging. Le
backend garde les jetons d’enregistrement FCM dans le champ historique
`utilisateurs.fcm_installation_ids` via les endpoints authentifiés `POST` et
`DELETE /messagerie/installation-fcm`. Le texte du message n’est jamais inclus
dans la notification. Les envois contiennent un bloc `notification` qu’Android
affiche en arrière-plan ou lorsque l’application n’est plus ouverte, ainsi que
des données pour ouvrir la conversation après un appui. En premier plan,
l’application affiche la notification via son service Android.
L’application resynchronise le jeton FCM avec le backend au retour au premier
plan. Si le backend signale qu’un jeton est « non enregistré », vérifiez aussi
que le `project_id` du compte de service Firebase du backend correspond au
projet indiqué dans `android/app/google-services.json`.
Déployez aussi le backend modifié : le jeton FCM doit y être envoyé comme
jeton (`token`), et non comme identifiant d’installation (`fid`).

Pour activer les notifications réelles :

1. Créez un projet Firebase et ajoutez-y une application Android dont le
   package est `com.example.traceur_app`.
2. Téléchargez `google-services.json` dans `android/app/` (ce fichier est
   ignoré par Git) et activez Firebase Cloud Messaging dans le projet.
3. Dans les variables d’environnement Render du backend, ajoutez
   `FIREBASE_SERVICE_ACCOUNT_JSON` avec le contenu JSON d’un compte de service
   Firebase. Ne placez pas cette clé privée dans le dépôt, l’application ou le
   chat.
4. Redéployez le backend puis reconstruisez l’application Android.

Sans les deux configurations Firebase, la surveillance native reste disponible,
mais l’inscription aux notifications de messages indique explicitement que
Firebase n’est pas configuré.

## Création d’un espace client

Sur l’écran de connexion, touchez cinq fois rapidement pour afficher le bouton
**Nouveau client**. L’inscription nécessite un code d’activation à usage unique.
Le formulaire peut le scanner depuis le QR fourni par l’administrateur ou
permettre de saisir le code manuellement. La vérification d’empreinte ne fait
pas partie de la création d’un nouvel espace. Les comptes existants qui ont déjà
enregistré la biométrie peuvent continuer à la demander à la connexion. Le numéro
client attribué doit être conservé pour identifier l’espace et l’associer aux
appareils MQTT. Il est facultatif à la connexion tant que les identifiants
désignent un seul compte ; il devient nécessaire si plusieurs espaces ont le
même nom et mot de passe.

Avant l’inscription, l’administrateur du backend doit définir le secret
`CLIENT_ENROLLMENT_ADMIN_KEY` dans l’environnement du serveur. L’administrateur
ouvre ensuite `https://<backend>/admin/codes-activation`, saisit cette clé dans
la page protégée et génère un QR à usage unique (un jour par défaut, durée
modifiable jusqu’à 365 jours). Cette clé reste côté opérateur ; elle ne doit
jamais être intégrée à l’application mobile. Le backend ne conserve que le
hachage du code d’activation.

Après une inscription ou une connexion, l’application conserve la session dans
le stockage sécurisé du téléphone et la restaure au prochain lancement. Le
backend renouvelle les jetons d’accès ; **Se déconnecter** révoque la session
pour obliger à saisir de nouveau les identifiants. Déployer le backend avant
de publier cette version mobile.

Les données métier, utilisateurs, conversations, animaux et alertes sont
filtrés par l’espace client connecté. Pour rattacher un nouvel animal reçu par
MQTT avant qu’il existe dans la base, le message du collier doit inclure son
`numero_client`; `ferme` peut aussi être envoyé pour préciser sa ferme. Les
anciennes données sont rattachées au premier super administrateur existant lors
de l’initialisation du backend.
