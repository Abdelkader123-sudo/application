// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Traceur GPS';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'العربية';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSelection => 'Choisir la langue';

  @override
  String get manageUsers => 'Gestion des utilisateurs';

  @override
  String get usersTitle => 'Utilisateurs';

  @override
  String get usersAdministrators => 'Administrateurs';

  @override
  String get usersAdministrator => 'Administrateur';

  @override
  String get usersAdminRole => 'Admin';

  @override
  String get usersAdd => 'Ajouter';

  @override
  String get usersDelete => 'Supprimer';

  @override
  String get usersDeleteTitle => 'Supprimer ce compte ?';

  @override
  String usersDeleteMessage(Object name) {
    return '$name ne pourra plus se connecter.';
  }

  @override
  String get usersEmpty =>
      'Aucun utilisateur pour le moment.\nAppuyez sur « Ajouter » pour créer le premier.';

  @override
  String get usersNoAdministrators => 'Aucun administrateur.';

  @override
  String get usersNoUsers => 'Aucun utilisateur.';

  @override
  String get usersActions => 'Actions';

  @override
  String get usersNewUser => 'Nouvel utilisateur';

  @override
  String get usersRole => 'Rôle';

  @override
  String get usersFirstName => 'Prénom';

  @override
  String get usersLoginNameHint => 'Utilisé pour se connecter';

  @override
  String get usersAgeLabel => 'Âge';

  @override
  String usersAge(int age) {
    return '$age ans';
  }

  @override
  String get usersResidence => 'Lieu de résidence';

  @override
  String get usersPhone => 'Numéro de téléphone';

  @override
  String get usersCinPassword => 'CIN (mot de passe)';

  @override
  String get usersCinHint => '8 chiffres : il servira de mot de passe';

  @override
  String get usersRequiredField => 'Champ obligatoire.';

  @override
  String get usersAgeRequired => 'Âge obligatoire.';

  @override
  String get usersAgeRange => 'Entre 0 et 120.';

  @override
  String get usersPhoneInvalid => 'Numéro invalide.';

  @override
  String get usersCinInvalid => 'Le CIN doit contenir 8 chiffres.';

  @override
  String get usersSaving => 'Enregistrement…';

  @override
  String get mapTab => 'Carte';

  @override
  String get herdsTab => 'Troupeaux';

  @override
  String get alertsTab => 'Alertes';

  @override
  String get animalsTab => 'Animaux';

  @override
  String get historyTab => 'Historique';

  @override
  String get settingsTab => 'Réglages';

  @override
  String get account => 'Compte';

  @override
  String get toggleBackgroundImage => 'Atténuer l’image de fond';

  @override
  String get showBackgroundImage => 'Afficher l’image en couleurs';

  @override
  String get disconnect => 'Se déconnecter';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'Inscription';

  @override
  String get start => 'Commencer';

  @override
  String get authorizedAccess => 'Accès réservé aux comptes autorisés';

  @override
  String get authConnecting => 'Connexion au serveur…';

  @override
  String get authWelcome => 'Bienvenue';

  @override
  String get authCreateMainAccount => 'Créer le compte principal';

  @override
  String get authFirstAccountDescription =>
      'Aucun compte n’existe encore. Ce compte sera le super administrateur : il pourra ajouter les administrateurs et les utilisateurs.';

  @override
  String get authLoginDescription =>
      'Connectez-vous pour accéder au suivi de votre troupeau.';

  @override
  String get authName => 'Nom';

  @override
  String get authEnterName => 'Entrez votre nom';

  @override
  String get authNameRequired => 'Le nom est obligatoire.';

  @override
  String get authMinNameLength => 'Au moins 2 caractères.';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authPasswordRequired => 'Le mot de passe est obligatoire.';

  @override
  String get authMinPasswordLength => 'Au moins 8 caractères.';

  @override
  String get authConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authPasswordsMismatch => 'Les mots de passe diffèrent.';

  @override
  String get authShowPassword => 'Afficher';

  @override
  String get authHidePassword => 'Masquer';

  @override
  String get authCreateAccount => 'Créer le compte';

  @override
  String get authNetworkError =>
      'Connexion impossible. Vérifiez votre réseau puis réessayez.';

  @override
  String get authInvalidInformation => 'Certaines informations sont invalides.';

  @override
  String authServerError(int statusCode) {
    return 'Erreur serveur ($statusCode).';
  }

  @override
  String get roleTitle => 'Le rôle de l\'application';

  @override
  String get appRoleDescription =>
      'Traceur vous permet de localiser vos animaux en temps réel, de surveiller leurs déplacements et d\'être alerté dès qu\'un animal quitte la zone autorisée.';

  @override
  String get trackingByGps => 'SUIVI DU TROUPEAU PAR GPS';

  @override
  String get configuration => 'CONFIGURATION';

  @override
  String get liveLocation => 'Localisation en direct';

  @override
  String get liveLocationDescription =>
      'Visualisez la position de chaque animal sur la carte, en temps réel.';

  @override
  String get securityZone => 'Zone de sécurité';

  @override
  String get securityZoneDescription =>
      'Définissez un périmètre autour du pâturage pour garder le troupeau sous contrôle.';

  @override
  String get instantAlerts => 'Alertes instantanées';

  @override
  String get instantAlertsDescription =>
      'Soyez prévenu immédiatement en cas de sortie de zone ou d\'anomalie.';

  @override
  String get routeHistory => 'Historique des trajets';

  @override
  String get routeHistoryDescription =>
      'Consultez les déplacements passés pour mieux comprendre le comportement du troupeau.';

  @override
  String get herdMonitoring => 'Surveillance du troupeau';

  @override
  String get herdMonitoringDescription =>
      'Personnalisez les seuils et les alertes selon vos besoins.';

  @override
  String availableParameters(Object count) {
    return '$count paramètres disponibles';
  }

  @override
  String get loadingParameters => 'Chargement des paramètres…';

  @override
  String get loadingImpossible => 'Chargement impossible';

  @override
  String get retry => 'Réessayer';

  @override
  String get saveParameters => 'Enregistrer les paramètres';

  @override
  String get settingsLanguageSection => 'Langue';

  @override
  String get languageToggleHint => 'Choisissez votre langue préférée';

  @override
  String get parameterGroupingDistance => 'Distance de regroupement';

  @override
  String get parameterGroupingDistanceDescription =>
      'Deux animaux plus proches que cette distance sont dans le même groupe.';

  @override
  String get parameterMaximumDistance => 'Éloignement maximal';

  @override
  String get parameterMaximumDistanceDescription =>
      'Au-delà de cette distance du troupeau, l’animal est considéré comme isolé.';

  @override
  String get parameterMinimumHerdSize => 'Taille minimale du troupeau';

  @override
  String get parameterMinimumHerdSizeDescription =>
      'Nombre minimum d’animaux pour former un troupeau.';

  @override
  String get parameterMaximumSpeed => 'Vitesse maximale';

  @override
  String get parameterMaximumSpeedDescription =>
      'Au-dessus de cette vitesse, un dépassement est détecté.';

  @override
  String get parameterImmobilityDuration => 'Durée d’immobilité';

  @override
  String get parameterImmobilityDurationDescription =>
      'Temps sans déplacement avant de déclencher une alerte.';

  @override
  String get parameterCollarSignalDelay => 'Délai sans signal du collier';

  @override
  String get parameterCollarSignalDelayDescription =>
      'Temps sans nouvelle donnée avant de déclencher une alerte.';

  @override
  String get herdGroupingSection => 'Regroupement du troupeau';

  @override
  String get herdGroupingSectionDescription =>
      'Comment les animaux sont regroupés et suivis.';

  @override
  String get speedAndImmobilitySection => 'Vitesse et immobilité';

  @override
  String get speedAndImmobilitySectionDescription =>
      'Seuils de vitesse et de repos des animaux.';

  @override
  String get collarSignalSection => 'Signal du collier';

  @override
  String get collarSignalSectionDescription =>
      'Surveillance du signal envoyé par le collier.';

  @override
  String get settingsLoadError =>
      'Impossible de charger les paramètres. Vérifiez votre connexion, puis réessayez.';

  @override
  String get settingsSaveSuccess => 'Les paramètres ont bien été enregistrés.';

  @override
  String get settingsSaveError =>
      'Enregistrement impossible. Vérifiez votre connexion puis réessayez.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsDescription =>
      'Recevez les alertes du troupeau et les nouveaux messages.';

  @override
  String get monitoringDurationLabel => 'Durée de surveillance';

  @override
  String get monitoringStart => 'Activer la surveillance';

  @override
  String get monitoringStop => 'Arrêter la surveillance';

  @override
  String get monitoringActive => 'Surveillance active';

  @override
  String get monitoringInactive => 'Surveillance inactive';

  @override
  String get monitoringRunningDescription =>
      'Les alertes sont vérifiées toutes les 30 secondes, pendant la durée choisie. Une connexion Internet est nécessaire.';

  @override
  String get monitoringPermissionDenied =>
      'Autorisez les notifications dans Android pour recevoir les alertes.';

  @override
  String get monitoringOperationError =>
      'Impossible de modifier la surveillance des alertes.';

  @override
  String get messagesNotifications => 'Notifications de messages';

  @override
  String get messagesNotificationsDescription =>
      'Alertez-moi à l’arrivée d’un nouveau message, même si l’application est fermée.';

  @override
  String get messagesNotificationsEnabled =>
      'Notifications de messages activées.';

  @override
  String get messagesNotificationsDisabled =>
      'Notifications de messages désactivées.';

  @override
  String get notificationsPermissionRequired =>
      'Autorisez les notifications dans les réglages Android pour continuer.';

  @override
  String notificationDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String notificationDurationHours(int hours) {
    return '$hours h';
  }

  @override
  String get settingsUnexpectedError => 'Une erreur est survenue.';

  @override
  String settingsServerError(int statusCode) {
    return 'Le serveur a répondu avec le code $statusCode.';
  }

  @override
  String settingsInvalidValue(Object label) {
    return '$label : saisissez une valeur valide.';
  }

  @override
  String get requiredField => 'Obligatoire.';

  @override
  String get integerRequired => 'Nombre entier requis.';

  @override
  String get numberRequired => 'Nombre requis.';

  @override
  String get settingsSaving => 'Enregistrement…';

  @override
  String get settingsChangesApplied =>
      'Les changements sont appliqués après leur enregistrement.';

  @override
  String get languageFrenchOption => 'Français';

  @override
  String get languageArabicOption => 'العربية';

  @override
  String get close => 'Fermer';

  @override
  String countAlerts(Object count) {
    return '$count en alerte';
  }

  @override
  String get searchAnimalsAndCoordinates =>
      'Rechercher un animal ou des coordonnées';

  @override
  String zoneLabel(Object name) {
    return 'Zone : $name';
  }

  @override
  String get unknownZone => 'pâturage';

  @override
  String get positionLive => 'Position en direct';

  @override
  String get collarNoSignal => 'Collier sans signal';

  @override
  String get alertActive => 'Alerte active';

  @override
  String get herdGroupLabel => 'Grand troupeau';

  @override
  String smallHerdLabel(Object number) {
    return 'Petit troupeau $number';
  }

  @override
  String isolatedCow(Object id) {
    return 'Vache isolée · $id';
  }

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get languageSection => 'Langue';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String countAnimals(Object count) {
    return '$count animaux';
  }

  @override
  String get onlineStatus => 'En ligne';

  @override
  String get offlineStatus => 'Hors ligne';

  @override
  String get alertsTitle => 'Alertes';

  @override
  String get alertsMonitoring => 'Surveillance du troupeau';

  @override
  String get alertsToHandle => 'Alertes à traiter';

  @override
  String get alertsToHandleMessage =>
      'Les alertes se mettent à jour en direct.';

  @override
  String get active => 'Actif';

  @override
  String get information => 'Information';

  @override
  String get alertSection => 'Alertes';

  @override
  String get infoSection => 'Information';

  @override
  String get noAlertsActive => 'Aucune alerte active';

  @override
  String get noAlertsMessage =>
      'Votre troupeau est sous surveillance. Les nouvelles alertes apparaîtront ici.';

  @override
  String get connectionInterrupted => 'Connexion interrompue';

  @override
  String get connectionInterruptedMessage =>
      'La connexion est interrompue. Les alertes apparaîtront lorsque la connexion sera rétablie.';

  @override
  String get animalLeftHerd => 'Cet animal s\'est éloigné du reste du troupeau';

  @override
  String get animalOutsidePasture => 'Cet animal est sorti du pâturage';

  @override
  String animalAtDistanceFromLimit(Object distance) {
    return 'Il se trouve à $distance m de la limite.';
  }

  @override
  String get animalInactive =>
      'Cet animal n\'a presque pas bougé depuis longtemps. Vérifiez qu\'il n\'est pas blessé ou malade.';

  @override
  String get abnormalMovement =>
      'Cet animal se déplace plus vite ou plus loin que d\'habitude.';

  @override
  String get collarSilent =>
      'Le collier n\'envoie plus de signal. Vérifiez la batterie ou la couverture réseau.';

  @override
  String get abnormalBehavior =>
      'Le comportement de cet animal a changé par rapport à ses habitudes.';

  @override
  String get noDetailProvided => 'Aucun détail fourni.';

  @override
  String get dateUnavailable => 'Date non disponible';

  @override
  String get lstmPageTitle => 'Mouvements agités';

  @override
  String get lstmPageSubtitle => 'Détectés automatiquement';

  @override
  String get lstmEventTitle => 'Mouvement agité';

  @override
  String get lstmExpectedPosition => 'Position attendue';

  @override
  String get lstmActualPosition => 'Position réelle';

  @override
  String lstmDistanceLabel(Object distance) {
    return 'Écart : $distance';
  }

  @override
  String lstmMeters(int distance) {
    return '$distance m';
  }

  @override
  String lstmKilometers(Object distance) {
    return '$distance km';
  }

  @override
  String lstmMovementDescription(Object distance) {
    return 'D’après ses habitudes, l’animal devait se trouver au point bleu. Il est en réalité au point rouge, à environ $distance.';
  }

  @override
  String get lstmAdviceStrong =>
      'Ce déplacement est très inhabituel : nous vous conseillons de vérifier l’animal.';

  @override
  String get lstmAdviceMarked =>
      'Ce déplacement est inhabituel : une vérification est conseillée.';

  @override
  String get lstmAdviceModerate =>
      'Ce déplacement est un peu inhabituel : à surveiller.';

  @override
  String get lstmLegacyPositionUnavailable =>
      'Les positions de cette ancienne alerte ne sont pas disponibles. Les prochaines alertes afficheront la carte.';

  @override
  String lstmTodayAt(Object time) {
    return 'Aujourd’hui à $time';
  }

  @override
  String lstmYesterdayAt(Object time) {
    return 'Hier à $time';
  }

  @override
  String lstmDateAt(Object day, Object month, int year, Object time) {
    return '$day/$month/$year à $time';
  }

  @override
  String get lstmLoadError =>
      'Impossible de charger les données. Vérifiez la connexion puis réessayez.';

  @override
  String get lstmNoEvents => 'Aucun mouvement agité';

  @override
  String get lstmNoEventsMessage =>
      'Tout semble normal. Les nouvelles alertes apparaîtront ici.';

  @override
  String get startedAt => 'Début ·';

  @override
  String get viewActivityHistory => 'Voir l\'historique d\'activité';

  @override
  String get animalNotIdentified => 'Animal non identifié';

  @override
  String get unknownAlert => 'Alerte';

  @override
  String get animalSeparatedFromGroup =>
      'animal est actuellement séparé du groupe';

  @override
  String get animalsSeparatedFromGroup =>
      'animaux sont actuellement séparés du groupe';

  @override
  String get alertTypeOutOfZone => 'Animal éloigné du troupeau';

  @override
  String get alertTypeOutsidePasture => 'Animal sorti du pâturage';

  @override
  String get alertTypeInactive => 'Animal immobile depuis longtemps';

  @override
  String get alertTypeUnusualMovement => 'Déplacement anormal';

  @override
  String get alertTypeCollarSilent => 'Collier sans signal';

  @override
  String get alertTypeUnusualBehavior => 'Comportement inhabituel';

  @override
  String get herdOverviewTitle => 'Vue d’ensemble des groupes';

  @override
  String get waitingForData => 'En attente des données';

  @override
  String get groupsWillAppearHere =>
      'Les groupes apparaîtront ici dès réception des premières données.';

  @override
  String get herdDataIncomplete => 'Données de troupeau incomplètes';

  @override
  String get grandHerdNotYetDisplayed =>
      'Le grand troupeau ne peut pas encore être affiché. Vérifiez les données reçues.';

  @override
  String get noHerdDetected => 'Pas encore de troupeau détecté';

  @override
  String get groupAppearsWhenEnoughAnimals =>
      'Un groupe apparaîtra lorsqu’il y aura suffisamment d’animaux actifs.';

  @override
  String get zoomIn => 'Zoom avant';

  @override
  String get zoomOut => 'Zoom arrière';

  @override
  String get centerPasture => 'Centrer sur la zone de pâturage';

  @override
  String get centerAnimals => 'Centrer sur les animaux';

  @override
  String get waitingForFirstPositions => 'En attente des premières positions…';

  @override
  String get trackingConnectionInterrupted => 'Connexion au suivi interrompue';

  @override
  String get noPositionsAvailable =>
      'Aucune position disponible pour le moment';

  @override
  String get noPastureRecorded => 'Aucune zone de pâturage enregistrée';

  @override
  String noAnimalMatches(Object query) {
    return 'Aucun animal ne correspond à « $query »';
  }

  @override
  String get enterCoordinatesFormat =>
      'Saisissez les coordonnées sous la forme 36.80, 10.18';

  @override
  String get invalidCoordinatesExample =>
      'Coordonnées invalides. Exemple : 36.80, 10.18';

  @override
  String get pastureName => 'Pâturage';

  @override
  String get mainPastureName => 'Pâturage principal';

  @override
  String get automaticModeLabel => 'auto';

  @override
  String get noGroupsDetected => 'aucun groupe détecté';

  @override
  String groupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groupes',
      one: '$count groupe',
      zero: 'aucun groupe',
    );
    return '$_temp0';
  }

  @override
  String get detectedGroups => 'GROUPES DÉTECTÉS';

  @override
  String get liveTrackedAnimals => 'Animaux suivis en direct';

  @override
  String get animalInAlert => 'Animal en alerte';

  @override
  String get alertSuffix => 'alerte';

  @override
  String get pastureZone => 'Zone de pâturage';

  @override
  String get distanceToMainHerd => 'Trait : distance au grand troupeau';

  @override
  String animalsInGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count animaux',
      one: '1 animal',
      zero: '0 animal',
    );
    return '$_temp0';
  }

  @override
  String animalsOutsideZone(int count, Object ids) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# animaux hors de la zone : $ids',
      one: '# animal hors de la zone : $ids',
    );
    return '$_temp0';
  }

  @override
  String get openStreetMapAttribution => '© les contributeurs d’OpenStreetMap';

  @override
  String get herdTracking => 'SUIVI DU TROUPEAU';

  @override
  String get currentComposition => 'Composition actuelle';

  @override
  String get herdCompositionDescription =>
      'Retrouvez les groupes et les animaux isolés.';

  @override
  String get isolatedGroups => 'Groupes isolés';

  @override
  String get animalsAlone => 'Animaux seuls';

  @override
  String get animalsInGroupLabel => 'Animaux dans le groupe';

  @override
  String get otherGroups => 'Autres groupes';

  @override
  String get noOtherGroups => 'Aucun autre groupe détecté pour le moment.';

  @override
  String get isolatedAnimal => 'Animal isolé';

  @override
  String get smallHerd => 'Petit troupeau';

  @override
  String get distanceUnavailable => 'Distance indisponible';

  @override
  String distanceFromMainHerd(Object distance) {
    return 'À $distance m du grand troupeau';
  }

  @override
  String get thresholdExceeded => 'Seuil dépassé';

  @override
  String get belowThreshold => 'Sous le seuil';

  @override
  String get animalIdsUnavailable => 'Identifiants des animaux indisponibles.';

  @override
  String get myHerd => 'Mon troupeau';

  @override
  String get animalTrackingLive => 'Suivi des animaux en direct';

  @override
  String get trackedAnimals => 'Animaux suivis';

  @override
  String get searchAnimalsGroupsTypes =>
      'Rechercher un animal, un groupe ou un type';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get cardsView => 'Cartes';

  @override
  String get tableView => 'Tableau';

  @override
  String get animalsHeading => 'ANIMAUX';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '$count résultat',
    );
    return '$_temp0';
  }

  @override
  String get identifier => 'Identifiant';

  @override
  String get group => 'Groupe';

  @override
  String get type => 'Type';

  @override
  String get sex => 'Sexe';

  @override
  String get age => 'Âge';

  @override
  String get weight => 'Poids';

  @override
  String get gps => 'GPS';

  @override
  String get lastMeasurement => 'Dernière mesure';

  @override
  String get action => 'Action';

  @override
  String get edit => 'Modifier';

  @override
  String get editInformation => 'Modifier les informations';

  @override
  String get unknownGroup => 'Groupe inconnu';

  @override
  String get addAnimalDetails => 'Ajouter âge, type, poids et sexe';

  @override
  String animalInfoSaved(Object id) {
    return 'Informations de $id enregistrées';
  }

  @override
  String get animalInfoUnavailable => 'Informations des animaux indisponibles.';

  @override
  String get now => 'À l’instant';

  @override
  String timeAgo(Object count, Object unit) {
    return 'Il y a $count $unit';
  }

  @override
  String get secondsShort => 's';

  @override
  String get minutesShort => 'min';

  @override
  String get hoursShort => 'h';

  @override
  String get daysShort => 'j';

  @override
  String get gpsUnavailable => 'GPS indisponible';

  @override
  String get animalFeatures => 'Caractéristiques de l’animal';

  @override
  String get typeAndBreed => 'Type / race';

  @override
  String get currentValue => 'Valeur actuelle';

  @override
  String get female => 'Femelle';

  @override
  String get male => 'Mâle';

  @override
  String get yearsUnit => 'ans';

  @override
  String get monthsUnit => 'mois';

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ans',
      one: '$count an',
    );
    return '$_temp0';
  }

  @override
  String ageMonths(Object count) {
    return '$count mois';
  }

  @override
  String get invalidNumber => 'Nombre invalide';

  @override
  String get ageRangeError => 'Entre 0 et 40 ans';

  @override
  String get weightRangeError => 'Entre 1 et 1500 kg';

  @override
  String get saveFailed => 'Enregistrement impossible.';

  @override
  String get waitingPositions => 'En attente des positions…';

  @override
  String get trackingOffline => 'Suivi hors ligne';

  @override
  String get noAnimalFound => 'Aucun animal trouvé';

  @override
  String get animalsAppearOnGps =>
      'Les animaux apparaîtront ici dès la prochaine mise à jour GPS.';

  @override
  String get connectionInterruptedAnimals =>
      'La connexion est interrompue. Les positions réapparaîtront à la reconnexion.';

  @override
  String get tryDifferentSearch =>
      'Essayez un autre identifiant, groupe ou type.';

  @override
  String get resetSearch => 'Réinitialiser la recherche';

  @override
  String get speciesCattle => 'Vaches';

  @override
  String get speciesSheep => 'Moutons';

  @override
  String get speciesHorses => 'Chevaux';

  @override
  String get breedHolstein => 'Prim’Holstein (Pie-noire)';

  @override
  String get breedBrownSwiss => 'Brune des Alpes (Brune)';

  @override
  String get breedTarentaise => 'Tarentaise (Tarasconnaise)';

  @override
  String get breedMontbeliarde => 'Montbéliarde';

  @override
  String get breedNormande => 'Normande';

  @override
  String get breedRedPied => 'Pie Rouge';

  @override
  String get breedJersey => 'Jersiaise';

  @override
  String get breedAtlasBrown => 'Brune de l’Atlas (vache locale / « Arbi »)';

  @override
  String get breedCapBonBlonde => 'Blonde du Cap-Bon';

  @override
  String get breedCrossbred => 'Races croisées';

  @override
  String get breedBarbarine => 'Barbarine (« Arbi »)';

  @override
  String get breedFineTail => 'Queue Fine de l’Ouest (« Gharbi »)';

  @override
  String get breedThibar => 'Noire de Thibar';

  @override
  String get breedSiciloSarde => 'Sicilo-Sarde';

  @override
  String get breedCherki => 'Cherki (hybride)';

  @override
  String get breedBarb => 'Barbe (Barbe tunisien)';

  @override
  String get breedArabian => 'Pur-Sang Arabe';

  @override
  String get breedArabBarb => 'Arabe-Barbe';

  @override
  String get breedMogodsPony => 'Poney des Mogods';

  @override
  String get breedThoroughbred => 'Pur-Sang (Anglais)';

  @override
  String get historyTitle => 'Historique d’activité';

  @override
  String get recentAnimalActivity => 'Suivi récent de vos animaux';

  @override
  String get searchAnimalId => 'Rechercher par ID (ex : cow01)';

  @override
  String get clear => 'Effacer';

  @override
  String get yourAnimals => 'Vos animaux';

  @override
  String get selectAnimalForActivity =>
      'Sélectionnez un animal pour consulter son activité.';

  @override
  String get viewActivityForSevenDays => 'Voir l’activité sur 7 jours';

  @override
  String get noHistoryAnimals => 'Aucun animal disponible pour l’historique.';

  @override
  String get noSearchResults => 'Aucun résultat';

  @override
  String get noAnimalToDisplay => 'Aucun animal à afficher';

  @override
  String noAnimalMatchesSearch(Object query) {
    return 'Aucun animal ne correspond à « $query ».';
  }

  @override
  String get lstmAnalysisTitle => 'Analyse d’activité par LSTM';

  @override
  String get purposeOfPage => 'À quoi sert cette page ?';

  @override
  String get lstmExplanation =>
      'Cette page rassemble l’historique d’activité de chaque animal. Les données du collier (position GPS et mouvements) sont analysées par un modèle LSTM, un réseau de neurones conçu pour comprendre des séquences dans le temps : il ne regarde pas une mesure isolée, mais la façon dont le comportement évolue d’heure en heure.';

  @override
  String get collection => 'Collecte';

  @override
  String get collarSendsMovement =>
      'Le collier envoie régulièrement la position et les mouvements de l’animal.';

  @override
  String get lstmAnalysis => 'Analyse LSTM';

  @override
  String get modelStudiesData =>
      'Le modèle étudie l’enchaînement des données pour reconnaître l’activité : repos, marche, course…';

  @override
  String get result => 'Résultat';

  @override
  String get historyHighlightsBehavior =>
      'L’historique met en évidence les comportements inhabituels pour vous permettre de réagir plus tôt.';

  @override
  String get historyAnalysisTooltip => 'Analyse LSTM : mouvements agités';

  @override
  String get aiAnalysis => 'Analyse IA';

  @override
  String get historyPeriod => 'Période à consulter';

  @override
  String get historyPeriodHint =>
      'Choisissez le nombre de derniers jours à afficher';

  @override
  String get dayShort => 'j';

  @override
  String dayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '$count jour',
    );
    return '$_temp0';
  }

  @override
  String get loadingHistory => 'Chargement de l’historique…';

  @override
  String get errorOccurred => 'Une erreur est survenue.';

  @override
  String get noMeasurementForAnimal =>
      'Aucune mesure disponible pour cet animal.';

  @override
  String get analysisServiceUnavailable =>
      'Le service d’analyse est momentanément indisponible.';

  @override
  String get historyNetworkError =>
      'Impossible de joindre le serveur. Vérifiez votre connexion, ou réessayez plus tard : le service d’analyse peut être en erreur pour cet animal.';

  @override
  String get invalidHistoryPeriod => 'La période demandée est invalide.';

  @override
  String get historyLoadError => 'Une erreur est survenue lors du chargement.';

  @override
  String get historyUnavailable => 'Historique indisponible';

  @override
  String get insufficientAiReference => 'Référence IA insuffisante';

  @override
  String get insufficientHistoryExplanation =>
      'Le modèle n’a pas assez de points de référence pour calculer un rythme habituel.';

  @override
  String get activityChartTitle => 'Activité de l’animal';

  @override
  String get noDataYet => 'Pas encore de données';

  @override
  String get noActivityForAnimal =>
      'Aucune activité à afficher pour cet animal.';

  @override
  String get noActivityData => 'Aucune donnée d’activité à afficher.';

  @override
  String get normalActivity => 'Normal';

  @override
  String get calmerThanUsual => 'Plus calme que d’habitude';

  @override
  String get moreActiveThanUsual => 'Plus actif que d’habitude';

  @override
  String get usualRhythmAi => 'Rythme habituel (IA)';

  @override
  String get noMeasurement => 'Aucune';

  @override
  String get calm => 'Calme';

  @override
  String get measured => 'Mesuré';

  @override
  String get partial => 'Partiel';

  @override
  String get noMeasurementThisDay => 'aucune mesure ce jour-là';

  @override
  String get usualActivity => 'activité normale';

  @override
  String get noReferenceForComparison =>
      'pas encore de référence pour comparer';

  @override
  String incompleteDayNoEvaluation(Object hours) {
    return 'journée incomplète ($hours h de mesures) : pas d’évaluation';
  }

  @override
  String get calmerThanUsualLong => 'plus calme que d’habitude';

  @override
  String get moreActiveThanUsualLong => 'plus actif que d’habitude';

  @override
  String get daysMondayShort => 'lun.';

  @override
  String get daysTuesdayShort => 'mar.';

  @override
  String get daysWednesdayShort => 'mer.';

  @override
  String get daysThursdayShort => 'jeu.';

  @override
  String get daysFridayShort => 'ven.';

  @override
  String get daysSaturdayShort => 'sam.';

  @override
  String get daysSundayShort => 'dim.';

  @override
  String usualStepsTooltip(Object steps) {
    return 'Habituel : $steps pas';
  }

  @override
  String stepCount(Object steps) {
    return '$steps pas';
  }

  @override
  String get historyIncompleteDay => 'Données manquantes';

  @override
  String get messengerTab => 'Messages';

  @override
  String get messengerTitle => 'Messagerie';

  @override
  String get messengerSearch => 'Rechercher une conversation';

  @override
  String get messengerAll => 'Tout';

  @override
  String get messengerPrivate => 'Privés';

  @override
  String get messengerGroups => 'Groupes';

  @override
  String get messengerNewConversation => 'Nouvelle conversation';

  @override
  String get messengerNewDiscussion => 'Nouvelle discussion';

  @override
  String get messengerCreateGroup => 'Créer un groupe';

  @override
  String get messengerChoosePeople => 'Choisir les participants';

  @override
  String get messengerGroupName => 'Nom du groupe';

  @override
  String get messengerMembers => 'participants';

  @override
  String get messengerNoConversations => 'Aucune conversation pour le moment.';

  @override
  String get messengerNoUsers => 'Aucun autre utilisateur n’est disponible.';

  @override
  String get messengerLoadingError =>
      'Impossible de charger les conversations.';

  @override
  String get messengerRetry => 'Réessayer';

  @override
  String get messengerMessageHint => 'Écrire un message…';

  @override
  String get messengerSend => 'Envoyer';

  @override
  String get messengerNoMessages => 'Envoyez le premier message.';

  @override
  String get messengerYou => 'Vous';

  @override
  String get messengerCancel => 'Annuler';

  @override
  String get messengerCreate => 'Créer';

  @override
  String get messengerContinue => 'Continuer';

  @override
  String get messengerSelectOne => 'Sélectionnez au moins un utilisateur.';

  @override
  String get messengerGroupNameRequired => 'Saisissez le nom du groupe.';

  @override
  String get messengerAddMembers => 'Ajouter des participants';

  @override
  String get messengerGroupCreated => 'Groupe créé';

  @override
  String get messengerConnectionError =>
      'La messagerie est momentanément indisponible.';

  @override
  String get messengerMessageError => 'Le message n’a pas pu être envoyé.';

  @override
  String get messengerToday => 'Aujourd’hui';
}
