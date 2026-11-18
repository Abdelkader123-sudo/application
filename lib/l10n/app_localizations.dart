import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Traceur GPS'**
  String get appTitle;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageArabic.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @languageSelection.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue'**
  String get languageSelection;

  /// No description provided for @manageUsers.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des utilisateurs'**
  String get manageUsers;

  /// No description provided for @usersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get usersTitle;

  /// No description provided for @usersAdministrators.
  ///
  /// In fr, this message translates to:
  /// **'Administrateurs'**
  String get usersAdministrators;

  /// No description provided for @usersAdministrator.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get usersAdministrator;

  /// No description provided for @usersAdminRole.
  ///
  /// In fr, this message translates to:
  /// **'Admin'**
  String get usersAdminRole;

  /// No description provided for @usersAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get usersAdd;

  /// No description provided for @usersDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get usersDelete;

  /// No description provided for @usersDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce compte ?'**
  String get usersDeleteTitle;

  /// No description provided for @usersDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'{name} ne pourra plus se connecter.'**
  String usersDeleteMessage(Object name);

  /// No description provided for @usersEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur pour le moment.\nAppuyez sur « Ajouter » pour créer le premier.'**
  String get usersEmpty;

  /// No description provided for @usersNoAdministrators.
  ///
  /// In fr, this message translates to:
  /// **'Aucun administrateur.'**
  String get usersNoAdministrators;

  /// No description provided for @usersNoUsers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur.'**
  String get usersNoUsers;

  /// No description provided for @usersActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get usersActions;

  /// No description provided for @usersNewUser.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel utilisateur'**
  String get usersNewUser;

  /// No description provided for @usersRole.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get usersRole;

  /// No description provided for @usersFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get usersFirstName;

  /// No description provided for @usersLoginNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Utilisé pour se connecter'**
  String get usersLoginNameHint;

  /// No description provided for @usersAgeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Âge'**
  String get usersAgeLabel;

  /// No description provided for @usersAge.
  ///
  /// In fr, this message translates to:
  /// **'{age} ans'**
  String usersAge(int age);

  /// No description provided for @usersResidence.
  ///
  /// In fr, this message translates to:
  /// **'Lieu de résidence'**
  String get usersResidence;

  /// No description provided for @usersPhone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get usersPhone;

  /// No description provided for @usersCinPassword.
  ///
  /// In fr, this message translates to:
  /// **'CIN (mot de passe)'**
  String get usersCinPassword;

  /// No description provided for @usersCinHint.
  ///
  /// In fr, this message translates to:
  /// **'8 chiffres : il servira de mot de passe'**
  String get usersCinHint;

  /// No description provided for @usersRequiredField.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire.'**
  String get usersRequiredField;

  /// No description provided for @usersAgeRequired.
  ///
  /// In fr, this message translates to:
  /// **'Âge obligatoire.'**
  String get usersAgeRequired;

  /// No description provided for @usersAgeRange.
  ///
  /// In fr, this message translates to:
  /// **'Entre 0 et 120.'**
  String get usersAgeRange;

  /// No description provided for @usersPhoneInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide.'**
  String get usersPhoneInvalid;

  /// No description provided for @usersCinInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Le CIN doit contenir 8 chiffres.'**
  String get usersCinInvalid;

  /// No description provided for @usersSaving.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement…'**
  String get usersSaving;

  /// No description provided for @mapTab.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get mapTab;

  /// No description provided for @herdsTab.
  ///
  /// In fr, this message translates to:
  /// **'Troupeaux'**
  String get herdsTab;

  /// No description provided for @alertsTab.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get alertsTab;

  /// No description provided for @animalsTab.
  ///
  /// In fr, this message translates to:
  /// **'Animaux'**
  String get animalsTab;

  /// No description provided for @historyTab.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get historyTab;

  /// No description provided for @settingsTab.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTab;

  /// No description provided for @account.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get account;

  /// No description provided for @toggleBackgroundImage.
  ///
  /// In fr, this message translates to:
  /// **'Atténuer l’image de fond'**
  String get toggleBackgroundImage;

  /// No description provided for @showBackgroundImage.
  ///
  /// In fr, this message translates to:
  /// **'Afficher l’image en couleurs'**
  String get showBackgroundImage;

  /// No description provided for @disconnect.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get disconnect;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get register;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get start;

  /// No description provided for @authorizedAccess.
  ///
  /// In fr, this message translates to:
  /// **'Accès réservé aux comptes autorisés'**
  String get authorizedAccess;

  /// No description provided for @authConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au serveur…'**
  String get authConnecting;

  /// No description provided for @authWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get authWelcome;

  /// No description provided for @authCreateMainAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer le compte principal'**
  String get authCreateMainAccount;

  /// No description provided for @authFirstAccountDescription.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte n’existe encore. Ce compte sera le super administrateur : il pourra ajouter les administrateurs et les utilisateurs.'**
  String get authFirstAccountDescription;

  /// No description provided for @authLoginDescription.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour accéder au suivi de votre troupeau.'**
  String get authLoginDescription;

  /// No description provided for @authName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get authName;

  /// No description provided for @authEnterName.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre nom'**
  String get authEnterName;

  /// No description provided for @authNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est obligatoire.'**
  String get authNameRequired;

  /// No description provided for @authMinNameLength.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 2 caractères.'**
  String get authMinNameLength;

  /// No description provided for @authPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPassword;

  /// No description provided for @authPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe est obligatoire.'**
  String get authPasswordRequired;

  /// No description provided for @authMinPasswordLength.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 8 caractères.'**
  String get authMinPasswordLength;

  /// No description provided for @authConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get authConfirmPassword;

  /// No description provided for @authPasswordsMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe diffèrent.'**
  String get authPasswordsMismatch;

  /// No description provided for @authShowPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer'**
  String get authHidePassword;

  /// No description provided for @authCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer le compte'**
  String get authCreateAccount;

  /// No description provided for @authNetworkError.
  ///
  /// In fr, this message translates to:
  /// **'Connexion impossible. Vérifiez votre réseau puis réessayez.'**
  String get authNetworkError;

  /// No description provided for @authInvalidInformation.
  ///
  /// In fr, this message translates to:
  /// **'Certaines informations sont invalides.'**
  String get authInvalidInformation;

  /// No description provided for @authServerError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur serveur ({statusCode}).'**
  String authServerError(int statusCode);

  /// No description provided for @roleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Le rôle de l\'application'**
  String get roleTitle;

  /// No description provided for @appRoleDescription.
  ///
  /// In fr, this message translates to:
  /// **'Traceur vous permet de localiser vos animaux en temps réel, de surveiller leurs déplacements et d\'être alerté dès qu\'un animal quitte la zone autorisée.'**
  String get appRoleDescription;

  /// No description provided for @trackingByGps.
  ///
  /// In fr, this message translates to:
  /// **'SUIVI DU TROUPEAU PAR GPS'**
  String get trackingByGps;

  /// No description provided for @configuration.
  ///
  /// In fr, this message translates to:
  /// **'CONFIGURATION'**
  String get configuration;

  /// No description provided for @liveLocation.
  ///
  /// In fr, this message translates to:
  /// **'Localisation en direct'**
  String get liveLocation;

  /// No description provided for @liveLocationDescription.
  ///
  /// In fr, this message translates to:
  /// **'Visualisez la position de chaque animal sur la carte, en temps réel.'**
  String get liveLocationDescription;

  /// No description provided for @securityZone.
  ///
  /// In fr, this message translates to:
  /// **'Zone de sécurité'**
  String get securityZone;

  /// No description provided for @securityZoneDescription.
  ///
  /// In fr, this message translates to:
  /// **'Définissez un périmètre autour du pâturage pour garder le troupeau sous contrôle.'**
  String get securityZoneDescription;

  /// No description provided for @instantAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes instantanées'**
  String get instantAlerts;

  /// No description provided for @instantAlertsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Soyez prévenu immédiatement en cas de sortie de zone ou d\'anomalie.'**
  String get instantAlertsDescription;

  /// No description provided for @routeHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique des trajets'**
  String get routeHistory;

  /// No description provided for @routeHistoryDescription.
  ///
  /// In fr, this message translates to:
  /// **'Consultez les déplacements passés pour mieux comprendre le comportement du troupeau.'**
  String get routeHistoryDescription;

  /// No description provided for @herdMonitoring.
  ///
  /// In fr, this message translates to:
  /// **'Surveillance du troupeau'**
  String get herdMonitoring;

  /// No description provided for @herdMonitoringDescription.
  ///
  /// In fr, this message translates to:
  /// **'Personnalisez les seuils et les alertes selon vos besoins.'**
  String get herdMonitoringDescription;

  /// No description provided for @availableParameters.
  ///
  /// In fr, this message translates to:
  /// **'{count} paramètres disponibles'**
  String availableParameters(Object count);

  /// No description provided for @loadingParameters.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des paramètres…'**
  String get loadingParameters;

  /// No description provided for @loadingImpossible.
  ///
  /// In fr, this message translates to:
  /// **'Chargement impossible'**
  String get loadingImpossible;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @saveParameters.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les paramètres'**
  String get saveParameters;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguageSection;

  /// No description provided for @languageToggleHint.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre langue préférée'**
  String get languageToggleHint;

  /// No description provided for @parameterGroupingDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance de regroupement'**
  String get parameterGroupingDistance;

  /// No description provided for @parameterGroupingDistanceDescription.
  ///
  /// In fr, this message translates to:
  /// **'Deux animaux plus proches que cette distance sont dans le même groupe.'**
  String get parameterGroupingDistanceDescription;

  /// No description provided for @parameterMaximumDistance.
  ///
  /// In fr, this message translates to:
  /// **'Éloignement maximal'**
  String get parameterMaximumDistance;

  /// No description provided for @parameterMaximumDistanceDescription.
  ///
  /// In fr, this message translates to:
  /// **'Au-delà de cette distance du troupeau, l’animal est considéré comme isolé.'**
  String get parameterMaximumDistanceDescription;

  /// No description provided for @parameterMinimumHerdSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille minimale du troupeau'**
  String get parameterMinimumHerdSize;

  /// No description provided for @parameterMinimumHerdSizeDescription.
  ///
  /// In fr, this message translates to:
  /// **'Nombre minimum d’animaux pour former un troupeau.'**
  String get parameterMinimumHerdSizeDescription;

  /// No description provided for @parameterMaximumSpeed.
  ///
  /// In fr, this message translates to:
  /// **'Vitesse maximale'**
  String get parameterMaximumSpeed;

  /// No description provided for @parameterMaximumSpeedDescription.
  ///
  /// In fr, this message translates to:
  /// **'Au-dessus de cette vitesse, un dépassement est détecté.'**
  String get parameterMaximumSpeedDescription;

  /// No description provided for @parameterImmobilityDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée d’immobilité'**
  String get parameterImmobilityDuration;

  /// No description provided for @parameterImmobilityDurationDescription.
  ///
  /// In fr, this message translates to:
  /// **'Temps sans déplacement avant de déclencher une alerte.'**
  String get parameterImmobilityDurationDescription;

  /// No description provided for @parameterCollarSignalDelay.
  ///
  /// In fr, this message translates to:
  /// **'Délai sans signal du collier'**
  String get parameterCollarSignalDelay;

  /// No description provided for @parameterCollarSignalDelayDescription.
  ///
  /// In fr, this message translates to:
  /// **'Temps sans nouvelle donnée avant de déclencher une alerte.'**
  String get parameterCollarSignalDelayDescription;

  /// No description provided for @herdGroupingSection.
  ///
  /// In fr, this message translates to:
  /// **'Regroupement du troupeau'**
  String get herdGroupingSection;

  /// No description provided for @herdGroupingSectionDescription.
  ///
  /// In fr, this message translates to:
  /// **'Comment les animaux sont regroupés et suivis.'**
  String get herdGroupingSectionDescription;

  /// No description provided for @speedAndImmobilitySection.
  ///
  /// In fr, this message translates to:
  /// **'Vitesse et immobilité'**
  String get speedAndImmobilitySection;

  /// No description provided for @speedAndImmobilitySectionDescription.
  ///
  /// In fr, this message translates to:
  /// **'Seuils de vitesse et de repos des animaux.'**
  String get speedAndImmobilitySectionDescription;

  /// No description provided for @collarSignalSection.
  ///
  /// In fr, this message translates to:
  /// **'Signal du collier'**
  String get collarSignalSection;

  /// No description provided for @collarSignalSectionDescription.
  ///
  /// In fr, this message translates to:
  /// **'Surveillance du signal envoyé par le collier.'**
  String get collarSignalSectionDescription;

  /// No description provided for @settingsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les paramètres. Vérifiez votre connexion, puis réessayez.'**
  String get settingsLoadError;

  /// No description provided for @settingsSaveSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Les paramètres ont bien été enregistrés.'**
  String get settingsSaveSuccess;

  /// No description provided for @settingsSaveError.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement impossible. Vérifiez votre connexion puis réessayez.'**
  String get settingsSaveError;

  /// No description provided for @notificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Recevez les alertes du troupeau et les nouveaux messages.'**
  String get notificationsDescription;

  /// No description provided for @monitoringDurationLabel.
  ///
  /// In fr, this message translates to:
  /// **'Durée de surveillance'**
  String get monitoringDurationLabel;

  /// No description provided for @monitoringStart.
  ///
  /// In fr, this message translates to:
  /// **'Activer la surveillance'**
  String get monitoringStart;

  /// No description provided for @monitoringStop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter la surveillance'**
  String get monitoringStop;

  /// No description provided for @monitoringActive.
  ///
  /// In fr, this message translates to:
  /// **'Surveillance active'**
  String get monitoringActive;

  /// No description provided for @monitoringInactive.
  ///
  /// In fr, this message translates to:
  /// **'Surveillance inactive'**
  String get monitoringInactive;

  /// No description provided for @monitoringRunningDescription.
  ///
  /// In fr, this message translates to:
  /// **'Les alertes sont vérifiées toutes les 30 secondes, pendant la durée choisie. Une connexion Internet est nécessaire.'**
  String get monitoringRunningDescription;

  /// No description provided for @monitoringPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Autorisez les notifications dans Android pour recevoir les alertes.'**
  String get monitoringPermissionDenied;

  /// No description provided for @monitoringOperationError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de modifier la surveillance des alertes.'**
  String get monitoringOperationError;

  /// No description provided for @messagesNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications de messages'**
  String get messagesNotifications;

  /// No description provided for @messagesNotificationsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Alertez-moi à l’arrivée d’un nouveau message, même si l’application est fermée.'**
  String get messagesNotificationsDescription;

  /// No description provided for @messagesNotificationsEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Notifications de messages activées.'**
  String get messagesNotificationsEnabled;

  /// No description provided for @messagesNotificationsDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Notifications de messages désactivées.'**
  String get messagesNotificationsDisabled;

  /// No description provided for @notificationsPermissionRequired.
  ///
  /// In fr, this message translates to:
  /// **'Autorisez les notifications dans les réglages Android pour continuer.'**
  String get notificationsPermissionRequired;

  /// No description provided for @notificationDurationMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min'**
  String notificationDurationMinutes(int minutes);

  /// No description provided for @notificationDurationHours.
  ///
  /// In fr, this message translates to:
  /// **'{hours} h'**
  String notificationDurationHours(int hours);

  /// No description provided for @settingsUnexpectedError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue.'**
  String get settingsUnexpectedError;

  /// No description provided for @settingsServerError.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur a répondu avec le code {statusCode}.'**
  String settingsServerError(int statusCode);

  /// No description provided for @settingsInvalidValue.
  ///
  /// In fr, this message translates to:
  /// **'{label} : saisissez une valeur valide.'**
  String settingsInvalidValue(Object label);

  /// No description provided for @requiredField.
  ///
  /// In fr, this message translates to:
  /// **'Obligatoire.'**
  String get requiredField;

  /// No description provided for @integerRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nombre entier requis.'**
  String get integerRequired;

  /// No description provided for @numberRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nombre requis.'**
  String get numberRequired;

  /// No description provided for @settingsSaving.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement…'**
  String get settingsSaving;

  /// No description provided for @settingsChangesApplied.
  ///
  /// In fr, this message translates to:
  /// **'Les changements sont appliqués après leur enregistrement.'**
  String get settingsChangesApplied;

  /// No description provided for @languageFrenchOption.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrenchOption;

  /// No description provided for @languageArabicOption.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get languageArabicOption;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @countAlerts.
  ///
  /// In fr, this message translates to:
  /// **'{count} en alerte'**
  String countAlerts(Object count);

  /// No description provided for @searchAnimalsAndCoordinates.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un animal ou des coordonnées'**
  String get searchAnimalsAndCoordinates;

  /// No description provided for @zoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Zone : {name}'**
  String zoneLabel(Object name);

  /// No description provided for @unknownZone.
  ///
  /// In fr, this message translates to:
  /// **'pâturage'**
  String get unknownZone;

  /// No description provided for @positionLive.
  ///
  /// In fr, this message translates to:
  /// **'Position en direct'**
  String get positionLive;

  /// No description provided for @collarNoSignal.
  ///
  /// In fr, this message translates to:
  /// **'Collier sans signal'**
  String get collarNoSignal;

  /// No description provided for @alertActive.
  ///
  /// In fr, this message translates to:
  /// **'Alerte active'**
  String get alertActive;

  /// No description provided for @herdGroupLabel.
  ///
  /// In fr, this message translates to:
  /// **'Grand troupeau'**
  String get herdGroupLabel;

  /// No description provided for @smallHerdLabel.
  ///
  /// In fr, this message translates to:
  /// **'Petit troupeau {number}'**
  String smallHerdLabel(Object number);

  /// No description provided for @isolatedCow.
  ///
  /// In fr, this message translates to:
  /// **'Vache isolée · {id}'**
  String isolatedCow(Object id);

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @languageSection.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageSection;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @countAnimals.
  ///
  /// In fr, this message translates to:
  /// **'{count} animaux'**
  String countAnimals(Object count);

  /// No description provided for @onlineStatus.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get onlineStatus;

  /// No description provided for @offlineStatus.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get offlineStatus;

  /// No description provided for @alertsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get alertsTitle;

  /// No description provided for @alertsMonitoring.
  ///
  /// In fr, this message translates to:
  /// **'Surveillance du troupeau'**
  String get alertsMonitoring;

  /// No description provided for @alertsToHandle.
  ///
  /// In fr, this message translates to:
  /// **'Alertes à traiter'**
  String get alertsToHandle;

  /// No description provided for @alertsToHandleMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les alertes se mettent à jour en direct.'**
  String get alertsToHandleMessage;

  /// No description provided for @active.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get active;

  /// No description provided for @information.
  ///
  /// In fr, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @alertSection.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get alertSection;

  /// No description provided for @infoSection.
  ///
  /// In fr, this message translates to:
  /// **'Information'**
  String get infoSection;

  /// No description provided for @noAlertsActive.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte active'**
  String get noAlertsActive;

  /// No description provided for @noAlertsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre troupeau est sous surveillance. Les nouvelles alertes apparaîtront ici.'**
  String get noAlertsMessage;

  /// No description provided for @connectionInterrupted.
  ///
  /// In fr, this message translates to:
  /// **'Connexion interrompue'**
  String get connectionInterrupted;

  /// No description provided for @connectionInterruptedMessage.
  ///
  /// In fr, this message translates to:
  /// **'La connexion est interrompue. Les alertes apparaîtront lorsque la connexion sera rétablie.'**
  String get connectionInterruptedMessage;

  /// No description provided for @animalLeftHerd.
  ///
  /// In fr, this message translates to:
  /// **'Cet animal s\'est éloigné du reste du troupeau'**
  String get animalLeftHerd;

  /// No description provided for @animalOutsidePasture.
  ///
  /// In fr, this message translates to:
  /// **'Cet animal est sorti du pâturage'**
  String get animalOutsidePasture;

  /// No description provided for @animalAtDistanceFromLimit.
  ///
  /// In fr, this message translates to:
  /// **'Il se trouve à {distance} m de la limite.'**
  String animalAtDistanceFromLimit(Object distance);

  /// No description provided for @animalInactive.
  ///
  /// In fr, this message translates to:
  /// **'Cet animal n\'a presque pas bougé depuis longtemps. Vérifiez qu\'il n\'est pas blessé ou malade.'**
  String get animalInactive;

  /// No description provided for @abnormalMovement.
  ///
  /// In fr, this message translates to:
  /// **'Cet animal se déplace plus vite ou plus loin que d\'habitude.'**
  String get abnormalMovement;

  /// No description provided for @collarSilent.
  ///
  /// In fr, this message translates to:
  /// **'Le collier n\'envoie plus de signal. Vérifiez la batterie ou la couverture réseau.'**
  String get collarSilent;

  /// No description provided for @abnormalBehavior.
  ///
  /// In fr, this message translates to:
  /// **'Le comportement de cet animal a changé par rapport à ses habitudes.'**
  String get abnormalBehavior;

  /// No description provided for @noDetailProvided.
  ///
  /// In fr, this message translates to:
  /// **'Aucun détail fourni.'**
  String get noDetailProvided;

  /// No description provided for @dateUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Date non disponible'**
  String get dateUnavailable;

  /// No description provided for @lstmPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mouvements agités'**
  String get lstmPageTitle;

  /// No description provided for @lstmPageSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Détectés automatiquement'**
  String get lstmPageSubtitle;

  /// No description provided for @lstmEventTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mouvement agité'**
  String get lstmEventTitle;

  /// No description provided for @lstmExpectedPosition.
  ///
  /// In fr, this message translates to:
  /// **'Position attendue'**
  String get lstmExpectedPosition;

  /// No description provided for @lstmActualPosition.
  ///
  /// In fr, this message translates to:
  /// **'Position réelle'**
  String get lstmActualPosition;

  /// No description provided for @lstmDistanceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Écart : {distance}'**
  String lstmDistanceLabel(Object distance);

  /// No description provided for @lstmMeters.
  ///
  /// In fr, this message translates to:
  /// **'{distance} m'**
  String lstmMeters(int distance);

  /// No description provided for @lstmKilometers.
  ///
  /// In fr, this message translates to:
  /// **'{distance} km'**
  String lstmKilometers(Object distance);

  /// No description provided for @lstmMovementDescription.
  ///
  /// In fr, this message translates to:
  /// **'D’après ses habitudes, l’animal devait se trouver au point bleu. Il est en réalité au point rouge, à environ {distance}.'**
  String lstmMovementDescription(Object distance);

  /// No description provided for @lstmAdviceStrong.
  ///
  /// In fr, this message translates to:
  /// **'Ce déplacement est très inhabituel : nous vous conseillons de vérifier l’animal.'**
  String get lstmAdviceStrong;

  /// No description provided for @lstmAdviceMarked.
  ///
  /// In fr, this message translates to:
  /// **'Ce déplacement est inhabituel : une vérification est conseillée.'**
  String get lstmAdviceMarked;

  /// No description provided for @lstmAdviceModerate.
  ///
  /// In fr, this message translates to:
  /// **'Ce déplacement est un peu inhabituel : à surveiller.'**
  String get lstmAdviceModerate;

  /// No description provided for @lstmLegacyPositionUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Les positions de cette ancienne alerte ne sont pas disponibles. Les prochaines alertes afficheront la carte.'**
  String get lstmLegacyPositionUnavailable;

  /// No description provided for @lstmTodayAt.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd’hui à {time}'**
  String lstmTodayAt(Object time);

  /// No description provided for @lstmYesterdayAt.
  ///
  /// In fr, this message translates to:
  /// **'Hier à {time}'**
  String lstmYesterdayAt(Object time);

  /// No description provided for @lstmDateAt.
  ///
  /// In fr, this message translates to:
  /// **'{day}/{month}/{year} à {time}'**
  String lstmDateAt(Object day, Object month, int year, Object time);

  /// No description provided for @lstmLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les données. Vérifiez la connexion puis réessayez.'**
  String get lstmLoadError;

  /// No description provided for @lstmNoEvents.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mouvement agité'**
  String get lstmNoEvents;

  /// No description provided for @lstmNoEventsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Tout semble normal. Les nouvelles alertes apparaîtront ici.'**
  String get lstmNoEventsMessage;

  /// No description provided for @startedAt.
  ///
  /// In fr, this message translates to:
  /// **'Début ·'**
  String get startedAt;

  /// No description provided for @viewActivityHistory.
  ///
  /// In fr, this message translates to:
  /// **'Voir l\'historique d\'activité'**
  String get viewActivityHistory;

  /// No description provided for @animalNotIdentified.
  ///
  /// In fr, this message translates to:
  /// **'Animal non identifié'**
  String get animalNotIdentified;

  /// No description provided for @unknownAlert.
  ///
  /// In fr, this message translates to:
  /// **'Alerte'**
  String get unknownAlert;

  /// No description provided for @animalSeparatedFromGroup.
  ///
  /// In fr, this message translates to:
  /// **'animal est actuellement séparé du groupe'**
  String get animalSeparatedFromGroup;

  /// No description provided for @animalsSeparatedFromGroup.
  ///
  /// In fr, this message translates to:
  /// **'animaux sont actuellement séparés du groupe'**
  String get animalsSeparatedFromGroup;

  /// No description provided for @alertTypeOutOfZone.
  ///
  /// In fr, this message translates to:
  /// **'Animal éloigné du troupeau'**
  String get alertTypeOutOfZone;

  /// No description provided for @alertTypeOutsidePasture.
  ///
  /// In fr, this message translates to:
  /// **'Animal sorti du pâturage'**
  String get alertTypeOutsidePasture;

  /// No description provided for @alertTypeInactive.
  ///
  /// In fr, this message translates to:
  /// **'Animal immobile depuis longtemps'**
  String get alertTypeInactive;

  /// No description provided for @alertTypeUnusualMovement.
  ///
  /// In fr, this message translates to:
  /// **'Déplacement anormal'**
  String get alertTypeUnusualMovement;

  /// No description provided for @alertTypeCollarSilent.
  ///
  /// In fr, this message translates to:
  /// **'Collier sans signal'**
  String get alertTypeCollarSilent;

  /// No description provided for @alertTypeUnusualBehavior.
  ///
  /// In fr, this message translates to:
  /// **'Comportement inhabituel'**
  String get alertTypeUnusualBehavior;

  /// No description provided for @herdOverviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vue d’ensemble des groupes'**
  String get herdOverviewTitle;

  /// No description provided for @waitingForData.
  ///
  /// In fr, this message translates to:
  /// **'En attente des données'**
  String get waitingForData;

  /// No description provided for @groupsWillAppearHere.
  ///
  /// In fr, this message translates to:
  /// **'Les groupes apparaîtront ici dès réception des premières données.'**
  String get groupsWillAppearHere;

  /// No description provided for @herdDataIncomplete.
  ///
  /// In fr, this message translates to:
  /// **'Données de troupeau incomplètes'**
  String get herdDataIncomplete;

  /// No description provided for @grandHerdNotYetDisplayed.
  ///
  /// In fr, this message translates to:
  /// **'Le grand troupeau ne peut pas encore être affiché. Vérifiez les données reçues.'**
  String get grandHerdNotYetDisplayed;

  /// No description provided for @noHerdDetected.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de troupeau détecté'**
  String get noHerdDetected;

  /// No description provided for @groupAppearsWhenEnoughAnimals.
  ///
  /// In fr, this message translates to:
  /// **'Un groupe apparaîtra lorsqu’il y aura suffisamment d’animaux actifs.'**
  String get groupAppearsWhenEnoughAnimals;

  /// No description provided for @zoomIn.
  ///
  /// In fr, this message translates to:
  /// **'Zoom avant'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In fr, this message translates to:
  /// **'Zoom arrière'**
  String get zoomOut;

  /// No description provided for @centerPasture.
  ///
  /// In fr, this message translates to:
  /// **'Centrer sur la zone de pâturage'**
  String get centerPasture;

  /// No description provided for @centerAnimals.
  ///
  /// In fr, this message translates to:
  /// **'Centrer sur les animaux'**
  String get centerAnimals;

  /// No description provided for @waitingForFirstPositions.
  ///
  /// In fr, this message translates to:
  /// **'En attente des premières positions…'**
  String get waitingForFirstPositions;

  /// No description provided for @trackingConnectionInterrupted.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au suivi interrompue'**
  String get trackingConnectionInterrupted;

  /// No description provided for @noPositionsAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucune position disponible pour le moment'**
  String get noPositionsAvailable;

  /// No description provided for @noPastureRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Aucune zone de pâturage enregistrée'**
  String get noPastureRecorded;

  /// No description provided for @noAnimalMatches.
  ///
  /// In fr, this message translates to:
  /// **'Aucun animal ne correspond à « {query} »'**
  String noAnimalMatches(Object query);

  /// No description provided for @enterCoordinatesFormat.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez les coordonnées sous la forme 36.80, 10.18'**
  String get enterCoordinatesFormat;

  /// No description provided for @invalidCoordinatesExample.
  ///
  /// In fr, this message translates to:
  /// **'Coordonnées invalides. Exemple : 36.80, 10.18'**
  String get invalidCoordinatesExample;

  /// No description provided for @pastureName.
  ///
  /// In fr, this message translates to:
  /// **'Pâturage'**
  String get pastureName;

  /// No description provided for @mainPastureName.
  ///
  /// In fr, this message translates to:
  /// **'Pâturage principal'**
  String get mainPastureName;

  /// No description provided for @automaticModeLabel.
  ///
  /// In fr, this message translates to:
  /// **'auto'**
  String get automaticModeLabel;

  /// No description provided for @noGroupsDetected.
  ///
  /// In fr, this message translates to:
  /// **'aucun groupe détecté'**
  String get noGroupsDetected;

  /// No description provided for @groupCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucun groupe} one{{count} groupe} other{{count} groupes}}'**
  String groupCount(int count);

  /// No description provided for @detectedGroups.
  ///
  /// In fr, this message translates to:
  /// **'GROUPES DÉTECTÉS'**
  String get detectedGroups;

  /// No description provided for @liveTrackedAnimals.
  ///
  /// In fr, this message translates to:
  /// **'Animaux suivis en direct'**
  String get liveTrackedAnimals;

  /// No description provided for @animalInAlert.
  ///
  /// In fr, this message translates to:
  /// **'Animal en alerte'**
  String get animalInAlert;

  /// No description provided for @alertSuffix.
  ///
  /// In fr, this message translates to:
  /// **'alerte'**
  String get alertSuffix;

  /// No description provided for @pastureZone.
  ///
  /// In fr, this message translates to:
  /// **'Zone de pâturage'**
  String get pastureZone;

  /// No description provided for @distanceToMainHerd.
  ///
  /// In fr, this message translates to:
  /// **'Trait : distance au grand troupeau'**
  String get distanceToMainHerd;

  /// No description provided for @animalsInGroup.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 animal} one{1 animal} other{{count} animaux}}'**
  String animalsInGroup(int count);

  /// No description provided for @animalsOutsideZone.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{# animal hors de la zone : {ids}} other{# animaux hors de la zone : {ids}}}'**
  String animalsOutsideZone(int count, Object ids);

  /// No description provided for @openStreetMapAttribution.
  ///
  /// In fr, this message translates to:
  /// **'© les contributeurs d’OpenStreetMap'**
  String get openStreetMapAttribution;

  /// No description provided for @herdTracking.
  ///
  /// In fr, this message translates to:
  /// **'SUIVI DU TROUPEAU'**
  String get herdTracking;

  /// No description provided for @currentComposition.
  ///
  /// In fr, this message translates to:
  /// **'Composition actuelle'**
  String get currentComposition;

  /// No description provided for @herdCompositionDescription.
  ///
  /// In fr, this message translates to:
  /// **'Retrouvez les groupes et les animaux isolés.'**
  String get herdCompositionDescription;

  /// No description provided for @isolatedGroups.
  ///
  /// In fr, this message translates to:
  /// **'Groupes isolés'**
  String get isolatedGroups;

  /// No description provided for @animalsAlone.
  ///
  /// In fr, this message translates to:
  /// **'Animaux seuls'**
  String get animalsAlone;

  /// No description provided for @animalsInGroupLabel.
  ///
  /// In fr, this message translates to:
  /// **'Animaux dans le groupe'**
  String get animalsInGroupLabel;

  /// No description provided for @otherGroups.
  ///
  /// In fr, this message translates to:
  /// **'Autres groupes'**
  String get otherGroups;

  /// No description provided for @noOtherGroups.
  ///
  /// In fr, this message translates to:
  /// **'Aucun autre groupe détecté pour le moment.'**
  String get noOtherGroups;

  /// No description provided for @isolatedAnimal.
  ///
  /// In fr, this message translates to:
  /// **'Animal isolé'**
  String get isolatedAnimal;

  /// No description provided for @smallHerd.
  ///
  /// In fr, this message translates to:
  /// **'Petit troupeau'**
  String get smallHerd;

  /// No description provided for @distanceUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Distance indisponible'**
  String get distanceUnavailable;

  /// No description provided for @distanceFromMainHerd.
  ///
  /// In fr, this message translates to:
  /// **'À {distance} m du grand troupeau'**
  String distanceFromMainHerd(Object distance);

  /// No description provided for @thresholdExceeded.
  ///
  /// In fr, this message translates to:
  /// **'Seuil dépassé'**
  String get thresholdExceeded;

  /// No description provided for @belowThreshold.
  ///
  /// In fr, this message translates to:
  /// **'Sous le seuil'**
  String get belowThreshold;

  /// No description provided for @animalIdsUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants des animaux indisponibles.'**
  String get animalIdsUnavailable;

  /// No description provided for @myHerd.
  ///
  /// In fr, this message translates to:
  /// **'Mon troupeau'**
  String get myHerd;

  /// No description provided for @animalTrackingLive.
  ///
  /// In fr, this message translates to:
  /// **'Suivi des animaux en direct'**
  String get animalTrackingLive;

  /// No description provided for @trackedAnimals.
  ///
  /// In fr, this message translates to:
  /// **'Animaux suivis'**
  String get trackedAnimals;

  /// No description provided for @searchAnimalsGroupsTypes.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un animal, un groupe ou un type'**
  String get searchAnimalsGroupsTypes;

  /// No description provided for @clearSearch.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la recherche'**
  String get clearSearch;

  /// No description provided for @cardsView.
  ///
  /// In fr, this message translates to:
  /// **'Cartes'**
  String get cardsView;

  /// No description provided for @tableView.
  ///
  /// In fr, this message translates to:
  /// **'Tableau'**
  String get tableView;

  /// No description provided for @animalsHeading.
  ///
  /// In fr, this message translates to:
  /// **'ANIMAUX'**
  String get animalsHeading;

  /// No description provided for @resultCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} résultat} other{{count} résultats}}'**
  String resultCount(int count);

  /// No description provided for @identifier.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant'**
  String get identifier;

  /// No description provided for @group.
  ///
  /// In fr, this message translates to:
  /// **'Groupe'**
  String get group;

  /// No description provided for @type.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @sex.
  ///
  /// In fr, this message translates to:
  /// **'Sexe'**
  String get sex;

  /// No description provided for @age.
  ///
  /// In fr, this message translates to:
  /// **'Âge'**
  String get age;

  /// No description provided for @weight.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get weight;

  /// No description provided for @gps.
  ///
  /// In fr, this message translates to:
  /// **'GPS'**
  String get gps;

  /// No description provided for @lastMeasurement.
  ///
  /// In fr, this message translates to:
  /// **'Dernière mesure'**
  String get lastMeasurement;

  /// No description provided for @action.
  ///
  /// In fr, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @editInformation.
  ///
  /// In fr, this message translates to:
  /// **'Modifier les informations'**
  String get editInformation;

  /// No description provided for @unknownGroup.
  ///
  /// In fr, this message translates to:
  /// **'Groupe inconnu'**
  String get unknownGroup;

  /// No description provided for @addAnimalDetails.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter âge, type, poids et sexe'**
  String get addAnimalDetails;

  /// No description provided for @animalInfoSaved.
  ///
  /// In fr, this message translates to:
  /// **'Informations de {id} enregistrées'**
  String animalInfoSaved(Object id);

  /// No description provided for @animalInfoUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Informations des animaux indisponibles.'**
  String get animalInfoUnavailable;

  /// No description provided for @now.
  ///
  /// In fr, this message translates to:
  /// **'À l’instant'**
  String get now;

  /// No description provided for @timeAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {count} {unit}'**
  String timeAgo(Object count, Object unit);

  /// No description provided for @secondsShort.
  ///
  /// In fr, this message translates to:
  /// **'s'**
  String get secondsShort;

  /// No description provided for @minutesShort.
  ///
  /// In fr, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @hoursShort.
  ///
  /// In fr, this message translates to:
  /// **'h'**
  String get hoursShort;

  /// No description provided for @daysShort.
  ///
  /// In fr, this message translates to:
  /// **'j'**
  String get daysShort;

  /// No description provided for @gpsUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'GPS indisponible'**
  String get gpsUnavailable;

  /// No description provided for @animalFeatures.
  ///
  /// In fr, this message translates to:
  /// **'Caractéristiques de l’animal'**
  String get animalFeatures;

  /// No description provided for @typeAndBreed.
  ///
  /// In fr, this message translates to:
  /// **'Type / race'**
  String get typeAndBreed;

  /// No description provided for @currentValue.
  ///
  /// In fr, this message translates to:
  /// **'Valeur actuelle'**
  String get currentValue;

  /// No description provided for @female.
  ///
  /// In fr, this message translates to:
  /// **'Femelle'**
  String get female;

  /// No description provided for @male.
  ///
  /// In fr, this message translates to:
  /// **'Mâle'**
  String get male;

  /// No description provided for @yearsUnit.
  ///
  /// In fr, this message translates to:
  /// **'ans'**
  String get yearsUnit;

  /// No description provided for @monthsUnit.
  ///
  /// In fr, this message translates to:
  /// **'mois'**
  String get monthsUnit;

  /// No description provided for @ageYears.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} an} other{{count} ans}}'**
  String ageYears(int count);

  /// No description provided for @ageMonths.
  ///
  /// In fr, this message translates to:
  /// **'{count} mois'**
  String ageMonths(Object count);

  /// No description provided for @invalidNumber.
  ///
  /// In fr, this message translates to:
  /// **'Nombre invalide'**
  String get invalidNumber;

  /// No description provided for @ageRangeError.
  ///
  /// In fr, this message translates to:
  /// **'Entre 0 et 40 ans'**
  String get ageRangeError;

  /// No description provided for @weightRangeError.
  ///
  /// In fr, this message translates to:
  /// **'Entre 1 et 1500 kg'**
  String get weightRangeError;

  /// No description provided for @saveFailed.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement impossible.'**
  String get saveFailed;

  /// No description provided for @waitingPositions.
  ///
  /// In fr, this message translates to:
  /// **'En attente des positions…'**
  String get waitingPositions;

  /// No description provided for @trackingOffline.
  ///
  /// In fr, this message translates to:
  /// **'Suivi hors ligne'**
  String get trackingOffline;

  /// No description provided for @noAnimalFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun animal trouvé'**
  String get noAnimalFound;

  /// No description provided for @animalsAppearOnGps.
  ///
  /// In fr, this message translates to:
  /// **'Les animaux apparaîtront ici dès la prochaine mise à jour GPS.'**
  String get animalsAppearOnGps;

  /// No description provided for @connectionInterruptedAnimals.
  ///
  /// In fr, this message translates to:
  /// **'La connexion est interrompue. Les positions réapparaîtront à la reconnexion.'**
  String get connectionInterruptedAnimals;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In fr, this message translates to:
  /// **'Essayez un autre identifiant, groupe ou type.'**
  String get tryDifferentSearch;

  /// No description provided for @resetSearch.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser la recherche'**
  String get resetSearch;

  /// No description provided for @speciesCattle.
  ///
  /// In fr, this message translates to:
  /// **'Vaches'**
  String get speciesCattle;

  /// No description provided for @speciesSheep.
  ///
  /// In fr, this message translates to:
  /// **'Moutons'**
  String get speciesSheep;

  /// No description provided for @speciesHorses.
  ///
  /// In fr, this message translates to:
  /// **'Chevaux'**
  String get speciesHorses;

  /// No description provided for @breedHolstein.
  ///
  /// In fr, this message translates to:
  /// **'Prim’Holstein (Pie-noire)'**
  String get breedHolstein;

  /// No description provided for @breedBrownSwiss.
  ///
  /// In fr, this message translates to:
  /// **'Brune des Alpes (Brune)'**
  String get breedBrownSwiss;

  /// No description provided for @breedTarentaise.
  ///
  /// In fr, this message translates to:
  /// **'Tarentaise (Tarasconnaise)'**
  String get breedTarentaise;

  /// No description provided for @breedMontbeliarde.
  ///
  /// In fr, this message translates to:
  /// **'Montbéliarde'**
  String get breedMontbeliarde;

  /// No description provided for @breedNormande.
  ///
  /// In fr, this message translates to:
  /// **'Normande'**
  String get breedNormande;

  /// No description provided for @breedRedPied.
  ///
  /// In fr, this message translates to:
  /// **'Pie Rouge'**
  String get breedRedPied;

  /// No description provided for @breedJersey.
  ///
  /// In fr, this message translates to:
  /// **'Jersiaise'**
  String get breedJersey;

  /// No description provided for @breedAtlasBrown.
  ///
  /// In fr, this message translates to:
  /// **'Brune de l’Atlas (vache locale / « Arbi »)'**
  String get breedAtlasBrown;

  /// No description provided for @breedCapBonBlonde.
  ///
  /// In fr, this message translates to:
  /// **'Blonde du Cap-Bon'**
  String get breedCapBonBlonde;

  /// No description provided for @breedCrossbred.
  ///
  /// In fr, this message translates to:
  /// **'Races croisées'**
  String get breedCrossbred;

  /// No description provided for @breedBarbarine.
  ///
  /// In fr, this message translates to:
  /// **'Barbarine (« Arbi »)'**
  String get breedBarbarine;

  /// No description provided for @breedFineTail.
  ///
  /// In fr, this message translates to:
  /// **'Queue Fine de l’Ouest (« Gharbi »)'**
  String get breedFineTail;

  /// No description provided for @breedThibar.
  ///
  /// In fr, this message translates to:
  /// **'Noire de Thibar'**
  String get breedThibar;

  /// No description provided for @breedSiciloSarde.
  ///
  /// In fr, this message translates to:
  /// **'Sicilo-Sarde'**
  String get breedSiciloSarde;

  /// No description provided for @breedCherki.
  ///
  /// In fr, this message translates to:
  /// **'Cherki (hybride)'**
  String get breedCherki;

  /// No description provided for @breedBarb.
  ///
  /// In fr, this message translates to:
  /// **'Barbe (Barbe tunisien)'**
  String get breedBarb;

  /// No description provided for @breedArabian.
  ///
  /// In fr, this message translates to:
  /// **'Pur-Sang Arabe'**
  String get breedArabian;

  /// No description provided for @breedArabBarb.
  ///
  /// In fr, this message translates to:
  /// **'Arabe-Barbe'**
  String get breedArabBarb;

  /// No description provided for @breedMogodsPony.
  ///
  /// In fr, this message translates to:
  /// **'Poney des Mogods'**
  String get breedMogodsPony;

  /// No description provided for @breedThoroughbred.
  ///
  /// In fr, this message translates to:
  /// **'Pur-Sang (Anglais)'**
  String get breedThoroughbred;

  /// No description provided for @historyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique d’activité'**
  String get historyTitle;

  /// No description provided for @recentAnimalActivity.
  ///
  /// In fr, this message translates to:
  /// **'Suivi récent de vos animaux'**
  String get recentAnimalActivity;

  /// No description provided for @searchAnimalId.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher par ID (ex : cow01)'**
  String get searchAnimalId;

  /// No description provided for @clear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get clear;

  /// No description provided for @yourAnimals.
  ///
  /// In fr, this message translates to:
  /// **'Vos animaux'**
  String get yourAnimals;

  /// No description provided for @selectAnimalForActivity.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un animal pour consulter son activité.'**
  String get selectAnimalForActivity;

  /// No description provided for @viewActivityForSevenDays.
  ///
  /// In fr, this message translates to:
  /// **'Voir l’activité sur 7 jours'**
  String get viewActivityForSevenDays;

  /// No description provided for @noHistoryAnimals.
  ///
  /// In fr, this message translates to:
  /// **'Aucun animal disponible pour l’historique.'**
  String get noHistoryAnimals;

  /// No description provided for @noSearchResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get noSearchResults;

  /// No description provided for @noAnimalToDisplay.
  ///
  /// In fr, this message translates to:
  /// **'Aucun animal à afficher'**
  String get noAnimalToDisplay;

  /// No description provided for @noAnimalMatchesSearch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun animal ne correspond à « {query} ».'**
  String noAnimalMatchesSearch(Object query);

  /// No description provided for @lstmAnalysisTitle.
  ///
  /// In fr, this message translates to:
  /// **'Analyse d’activité par LSTM'**
  String get lstmAnalysisTitle;

  /// No description provided for @purposeOfPage.
  ///
  /// In fr, this message translates to:
  /// **'À quoi sert cette page ?'**
  String get purposeOfPage;

  /// No description provided for @lstmExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Cette page rassemble l’historique d’activité de chaque animal. Les données du collier (position GPS et mouvements) sont analysées par un modèle LSTM, un réseau de neurones conçu pour comprendre des séquences dans le temps : il ne regarde pas une mesure isolée, mais la façon dont le comportement évolue d’heure en heure.'**
  String get lstmExplanation;

  /// No description provided for @collection.
  ///
  /// In fr, this message translates to:
  /// **'Collecte'**
  String get collection;

  /// No description provided for @collarSendsMovement.
  ///
  /// In fr, this message translates to:
  /// **'Le collier envoie régulièrement la position et les mouvements de l’animal.'**
  String get collarSendsMovement;

  /// No description provided for @lstmAnalysis.
  ///
  /// In fr, this message translates to:
  /// **'Analyse LSTM'**
  String get lstmAnalysis;

  /// No description provided for @modelStudiesData.
  ///
  /// In fr, this message translates to:
  /// **'Le modèle étudie l’enchaînement des données pour reconnaître l’activité : repos, marche, course…'**
  String get modelStudiesData;

  /// No description provided for @result.
  ///
  /// In fr, this message translates to:
  /// **'Résultat'**
  String get result;

  /// No description provided for @historyHighlightsBehavior.
  ///
  /// In fr, this message translates to:
  /// **'L’historique met en évidence les comportements inhabituels pour vous permettre de réagir plus tôt.'**
  String get historyHighlightsBehavior;

  /// No description provided for @historyAnalysisTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Analyse LSTM : mouvements agités'**
  String get historyAnalysisTooltip;

  /// No description provided for @aiAnalysis.
  ///
  /// In fr, this message translates to:
  /// **'Analyse IA'**
  String get aiAnalysis;

  /// No description provided for @historyPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Période à consulter'**
  String get historyPeriod;

  /// No description provided for @historyPeriodHint.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez le nombre de derniers jours à afficher'**
  String get historyPeriodHint;

  /// No description provided for @dayShort.
  ///
  /// In fr, this message translates to:
  /// **'j'**
  String get dayShort;

  /// No description provided for @dayCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} jour} other{{count} jours}}'**
  String dayCount(int count);

  /// No description provided for @loadingHistory.
  ///
  /// In fr, this message translates to:
  /// **'Chargement de l’historique…'**
  String get loadingHistory;

  /// No description provided for @errorOccurred.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue.'**
  String get errorOccurred;

  /// No description provided for @noMeasurementForAnimal.
  ///
  /// In fr, this message translates to:
  /// **'Aucune mesure disponible pour cet animal.'**
  String get noMeasurementForAnimal;

  /// No description provided for @analysisServiceUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Le service d’analyse est momentanément indisponible.'**
  String get analysisServiceUnavailable;

  /// No description provided for @historyNetworkError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le serveur. Vérifiez votre connexion, ou réessayez plus tard : le service d’analyse peut être en erreur pour cet animal.'**
  String get historyNetworkError;

  /// No description provided for @invalidHistoryPeriod.
  ///
  /// In fr, this message translates to:
  /// **'La période demandée est invalide.'**
  String get invalidHistoryPeriod;

  /// No description provided for @historyLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue lors du chargement.'**
  String get historyLoadError;

  /// No description provided for @historyUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Historique indisponible'**
  String get historyUnavailable;

  /// No description provided for @insufficientAiReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence IA insuffisante'**
  String get insufficientAiReference;

  /// No description provided for @insufficientHistoryExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Le modèle n’a pas assez de points de référence pour calculer un rythme habituel.'**
  String get insufficientHistoryExplanation;

  /// No description provided for @activityChartTitle.
  ///
  /// In fr, this message translates to:
  /// **'Activité de l’animal'**
  String get activityChartTitle;

  /// No description provided for @noDataYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de données'**
  String get noDataYet;

  /// No description provided for @noActivityForAnimal.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité à afficher pour cet animal.'**
  String get noActivityForAnimal;

  /// No description provided for @noActivityData.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée d’activité à afficher.'**
  String get noActivityData;

  /// No description provided for @normalActivity.
  ///
  /// In fr, this message translates to:
  /// **'Normal'**
  String get normalActivity;

  /// No description provided for @calmerThanUsual.
  ///
  /// In fr, this message translates to:
  /// **'Plus calme que d’habitude'**
  String get calmerThanUsual;

  /// No description provided for @moreActiveThanUsual.
  ///
  /// In fr, this message translates to:
  /// **'Plus actif que d’habitude'**
  String get moreActiveThanUsual;

  /// No description provided for @usualRhythmAi.
  ///
  /// In fr, this message translates to:
  /// **'Rythme habituel (IA)'**
  String get usualRhythmAi;

  /// No description provided for @noMeasurement.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get noMeasurement;

  /// No description provided for @calm.
  ///
  /// In fr, this message translates to:
  /// **'Calme'**
  String get calm;

  /// No description provided for @measured.
  ///
  /// In fr, this message translates to:
  /// **'Mesuré'**
  String get measured;

  /// No description provided for @partial.
  ///
  /// In fr, this message translates to:
  /// **'Partiel'**
  String get partial;

  /// No description provided for @noMeasurementThisDay.
  ///
  /// In fr, this message translates to:
  /// **'aucune mesure ce jour-là'**
  String get noMeasurementThisDay;

  /// No description provided for @usualActivity.
  ///
  /// In fr, this message translates to:
  /// **'activité normale'**
  String get usualActivity;

  /// No description provided for @noReferenceForComparison.
  ///
  /// In fr, this message translates to:
  /// **'pas encore de référence pour comparer'**
  String get noReferenceForComparison;

  /// No description provided for @incompleteDayNoEvaluation.
  ///
  /// In fr, this message translates to:
  /// **'journée incomplète ({hours} h de mesures) : pas d’évaluation'**
  String incompleteDayNoEvaluation(Object hours);

  /// No description provided for @calmerThanUsualLong.
  ///
  /// In fr, this message translates to:
  /// **'plus calme que d’habitude'**
  String get calmerThanUsualLong;

  /// No description provided for @moreActiveThanUsualLong.
  ///
  /// In fr, this message translates to:
  /// **'plus actif que d’habitude'**
  String get moreActiveThanUsualLong;

  /// No description provided for @daysMondayShort.
  ///
  /// In fr, this message translates to:
  /// **'lun.'**
  String get daysMondayShort;

  /// No description provided for @daysTuesdayShort.
  ///
  /// In fr, this message translates to:
  /// **'mar.'**
  String get daysTuesdayShort;

  /// No description provided for @daysWednesdayShort.
  ///
  /// In fr, this message translates to:
  /// **'mer.'**
  String get daysWednesdayShort;

  /// No description provided for @daysThursdayShort.
  ///
  /// In fr, this message translates to:
  /// **'jeu.'**
  String get daysThursdayShort;

  /// No description provided for @daysFridayShort.
  ///
  /// In fr, this message translates to:
  /// **'ven.'**
  String get daysFridayShort;

  /// No description provided for @daysSaturdayShort.
  ///
  /// In fr, this message translates to:
  /// **'sam.'**
  String get daysSaturdayShort;

  /// No description provided for @daysSundayShort.
  ///
  /// In fr, this message translates to:
  /// **'dim.'**
  String get daysSundayShort;

  /// No description provided for @usualStepsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Habituel : {steps} pas'**
  String usualStepsTooltip(Object steps);

  /// No description provided for @stepCount.
  ///
  /// In fr, this message translates to:
  /// **'{steps} pas'**
  String stepCount(Object steps);

  /// No description provided for @historyIncompleteDay.
  ///
  /// In fr, this message translates to:
  /// **'Données manquantes'**
  String get historyIncompleteDay;

  /// No description provided for @messengerTab.
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get messengerTab;

  /// No description provided for @messengerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Messagerie'**
  String get messengerTitle;

  /// No description provided for @messengerSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une conversation'**
  String get messengerSearch;

  /// No description provided for @messengerAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get messengerAll;

  /// No description provided for @messengerPrivate.
  ///
  /// In fr, this message translates to:
  /// **'Privés'**
  String get messengerPrivate;

  /// No description provided for @messengerGroups.
  ///
  /// In fr, this message translates to:
  /// **'Groupes'**
  String get messengerGroups;

  /// No description provided for @messengerNewConversation.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle conversation'**
  String get messengerNewConversation;

  /// No description provided for @messengerNewDiscussion.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle discussion'**
  String get messengerNewDiscussion;

  /// No description provided for @messengerCreateGroup.
  ///
  /// In fr, this message translates to:
  /// **'Créer un groupe'**
  String get messengerCreateGroup;

  /// No description provided for @messengerChoosePeople.
  ///
  /// In fr, this message translates to:
  /// **'Choisir les participants'**
  String get messengerChoosePeople;

  /// No description provided for @messengerGroupName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du groupe'**
  String get messengerGroupName;

  /// No description provided for @messengerMembers.
  ///
  /// In fr, this message translates to:
  /// **'participants'**
  String get messengerMembers;

  /// No description provided for @messengerNoConversations.
  ///
  /// In fr, this message translates to:
  /// **'Aucune conversation pour le moment.'**
  String get messengerNoConversations;

  /// No description provided for @messengerNoUsers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun autre utilisateur n’est disponible.'**
  String get messengerNoUsers;

  /// No description provided for @messengerLoadingError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les conversations.'**
  String get messengerLoadingError;

  /// No description provided for @messengerRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get messengerRetry;

  /// No description provided for @messengerMessageHint.
  ///
  /// In fr, this message translates to:
  /// **'Écrire un message…'**
  String get messengerMessageHint;

  /// No description provided for @messengerSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get messengerSend;

  /// No description provided for @messengerNoMessages.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez le premier message.'**
  String get messengerNoMessages;

  /// No description provided for @messengerYou.
  ///
  /// In fr, this message translates to:
  /// **'Vous'**
  String get messengerYou;

  /// No description provided for @messengerCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get messengerCancel;

  /// No description provided for @messengerCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get messengerCreate;

  /// No description provided for @messengerContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get messengerContinue;

  /// No description provided for @messengerSelectOne.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez au moins un utilisateur.'**
  String get messengerSelectOne;

  /// No description provided for @messengerGroupNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le nom du groupe.'**
  String get messengerGroupNameRequired;

  /// No description provided for @messengerAddMembers.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des participants'**
  String get messengerAddMembers;

  /// No description provided for @messengerGroupCreated.
  ///
  /// In fr, this message translates to:
  /// **'Groupe créé'**
  String get messengerGroupCreated;

  /// No description provided for @messengerConnectionError.
  ///
  /// In fr, this message translates to:
  /// **'La messagerie est momentanément indisponible.'**
  String get messengerConnectionError;

  /// No description provided for @messengerMessageError.
  ///
  /// In fr, this message translates to:
  /// **'Le message n’a pas pu être envoyé.'**
  String get messengerMessageError;

  /// No description provided for @messengerToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd’hui'**
  String get messengerToday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
