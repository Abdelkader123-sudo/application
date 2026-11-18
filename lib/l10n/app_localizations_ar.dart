// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تتبع GPS';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageSelection => 'اختيار اللغة';

  @override
  String get manageUsers => 'إدارة المستخدمين';

  @override
  String get usersTitle => 'المستخدمون';

  @override
  String get usersAdministrators => 'المسؤولون';

  @override
  String get usersAdministrator => 'مسؤول';

  @override
  String get usersAdminRole => 'مسؤول';

  @override
  String get usersAdd => 'إضافة';

  @override
  String get usersDelete => 'حذف';

  @override
  String get usersDeleteTitle => 'حذف هذا الحساب؟';

  @override
  String usersDeleteMessage(Object name) {
    return 'لن يتمكن $name من تسجيل الدخول بعد الآن.';
  }

  @override
  String get usersEmpty =>
      'لا يوجد مستخدمون حاليًا.\nاضغط على «إضافة» لإنشاء أول مستخدم.';

  @override
  String get usersNoAdministrators => 'لا يوجد مسؤولون.';

  @override
  String get usersNoUsers => 'لا يوجد مستخدمون.';

  @override
  String get usersActions => 'الإجراءات';

  @override
  String get usersNewUser => 'مستخدم جديد';

  @override
  String get usersRole => 'الدور';

  @override
  String get usersFirstName => 'الاسم الأول';

  @override
  String get usersLoginNameHint => 'يُستخدم لتسجيل الدخول';

  @override
  String get usersAgeLabel => 'العمر';

  @override
  String usersAge(int age) {
    return '$age سنة';
  }

  @override
  String get usersResidence => 'مكان الإقامة';

  @override
  String get usersPhone => 'رقم الهاتف';

  @override
  String get usersCinPassword => 'رقم الهوية (كلمة المرور)';

  @override
  String get usersCinHint => '8 أرقام: ستُستخدم كلمة مرور';

  @override
  String get usersRequiredField => 'هذا الحقل مطلوب.';

  @override
  String get usersAgeRequired => 'العمر مطلوب.';

  @override
  String get usersAgeRange => 'يجب أن يكون العمر بين 0 و120.';

  @override
  String get usersPhoneInvalid => 'رقم الهاتف غير صالح.';

  @override
  String get usersCinInvalid => 'يجب أن يتكون رقم الهوية من 8 أرقام.';

  @override
  String get usersSaving => 'جارٍ الحفظ…';

  @override
  String get mapTab => 'الخريطة';

  @override
  String get herdsTab => 'القطعان';

  @override
  String get alertsTab => 'التنبيهات';

  @override
  String get animalsTab => 'الحيوانات';

  @override
  String get historyTab => 'السجل';

  @override
  String get settingsTab => 'الإعدادات';

  @override
  String get account => 'الحساب';

  @override
  String get toggleBackgroundImage => 'تخفيف صورة الخلفية';

  @override
  String get showBackgroundImage => 'إظهار الصورة بالألوان';

  @override
  String get disconnect => 'تسجيل الخروج';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get start => 'ابدأ';

  @override
  String get authorizedAccess => 'وصول محجوز للحسابات المصرح لها';

  @override
  String get authConnecting => 'جارٍ الاتصال بالخادم…';

  @override
  String get authWelcome => 'مرحبًا';

  @override
  String get authCreateMainAccount => 'إنشاء الحساب الرئيسي';

  @override
  String get authFirstAccountDescription =>
      'لا يوجد أي حساب حتى الآن. سيكون هذا الحساب مسؤولًا عامًا، وسيتمكن من إضافة المسؤولين والمستخدمين.';

  @override
  String get authLoginDescription => 'سجّل الدخول للوصول إلى متابعة قطيعك.';

  @override
  String get authName => 'الاسم';

  @override
  String get authEnterName => 'أدخل اسمك';

  @override
  String get authNameRequired => 'الاسم مطلوب.';

  @override
  String get authMinNameLength => 'يجب ألا يقل الاسم عن حرفين.';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authPasswordRequired => 'كلمة المرور مطلوبة.';

  @override
  String get authMinPasswordLength => 'يجب ألا تقل كلمة المرور عن 8 أحرف.';

  @override
  String get authConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authPasswordsMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get authShowPassword => 'إظهار';

  @override
  String get authHidePassword => 'إخفاء';

  @override
  String get authCreateAccount => 'إنشاء الحساب';

  @override
  String get authNetworkError =>
      'تعذّر الاتصال. تحقق من اتصال الشبكة ثم حاول مجددًا.';

  @override
  String get authInvalidInformation => 'بعض المعلومات غير صالحة.';

  @override
  String authServerError(int statusCode) {
    return 'خطأ في الخادم ($statusCode).';
  }

  @override
  String get roleTitle => 'دور التطبيق';

  @override
  String get appRoleDescription =>
      'يسمح لك التطبيق بتتبع حيواناتك في الوقت الحقيقي ومراقبة حركتها والتحذير عند مغادرة الحيوان للمساحة المسموح بها.';

  @override
  String get trackingByGps => 'تتبع القطيع عبر GPS';

  @override
  String get configuration => 'الإعدادات';

  @override
  String get liveLocation => 'الموقع المباشر';

  @override
  String get liveLocationDescription =>
      'شاهد موقع كل حيوان على الخريطة في الوقت الحقيقي.';

  @override
  String get securityZone => 'منطقة الأمان';

  @override
  String get securityZoneDescription =>
      'حدد محيطًا حول المرعى للحفاظ على القطيع تحت السيطرة.';

  @override
  String get instantAlerts => 'تنبيهات فورية';

  @override
  String get instantAlertsDescription =>
      'احصل على تنبيه فوري في حال خروج الحيوان من المنطقة أو وجود أي خلل.';

  @override
  String get routeHistory => 'سجل المسارات';

  @override
  String get routeHistoryDescription =>
      'استعرض الحركات السابقة لفهم سلوك القطيع بشكل أفضل.';

  @override
  String get herdMonitoring => 'مراقبة القطيع';

  @override
  String get herdMonitoringDescription =>
      'خصص العتبات والتنبيهات وفق احتياجاتك.';

  @override
  String availableParameters(Object count) {
    return '$count إعدادات متاحة';
  }

  @override
  String get loadingParameters => 'جارٍ تحميل الإعدادات…';

  @override
  String get loadingImpossible => 'تعذّر التحميل';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get saveParameters => 'حفظ الإعدادات';

  @override
  String get settingsLanguageSection => 'اللغة';

  @override
  String get languageToggleHint => 'اختر لغتك المفضلة';

  @override
  String get parameterGroupingDistance => 'مسافة تجميع القطيع';

  @override
  String get parameterGroupingDistanceDescription =>
      'يكون الحيوانان في المجموعة نفسها إذا كانت المسافة بينهما أقل من هذه القيمة.';

  @override
  String get parameterMaximumDistance => 'أقصى مسافة للابتعاد';

  @override
  String get parameterMaximumDistanceDescription =>
      'يُعد الحيوان منعزلًا إذا تجاوزت المسافة بينه وبين القطيع هذه القيمة.';

  @override
  String get parameterMinimumHerdSize => 'الحد الأدنى لحجم القطيع';

  @override
  String get parameterMinimumHerdSizeDescription =>
      'الحد الأدنى لعدد الحيوانات لتكوين قطيع.';

  @override
  String get parameterMaximumSpeed => 'السرعة القصوى';

  @override
  String get parameterMaximumSpeedDescription =>
      'يُكتشف تجاوز السرعة عند تخطي هذه القيمة.';

  @override
  String get parameterImmobilityDuration => 'مدة عدم الحركة';

  @override
  String get parameterImmobilityDurationDescription =>
      'المدة التي تمر دون حركة قبل إطلاق تنبيه.';

  @override
  String get parameterCollarSignalDelay => 'مدة انقطاع إشارة الطوق';

  @override
  String get parameterCollarSignalDelayDescription =>
      'المدة دون بيانات جديدة قبل إطلاق تنبيه.';

  @override
  String get herdGroupingSection => 'تجميع القطيع';

  @override
  String get herdGroupingSectionDescription =>
      'كيفية تجميع الحيوانات ومتابعتها.';

  @override
  String get speedAndImmobilitySection => 'السرعة وعدم الحركة';

  @override
  String get speedAndImmobilitySectionDescription =>
      'حدود سرعة الحيوانات وفترات راحتها.';

  @override
  String get collarSignalSection => 'إشارة الطوق';

  @override
  String get collarSignalSectionDescription =>
      'مراقبة الإشارة التي يرسلها الطوق.';

  @override
  String get settingsLoadError =>
      'تعذّر تحميل الإعدادات. تحقق من اتصالك بالإنترنت ثم حاول مجددًا.';

  @override
  String get settingsSaveSuccess => 'تم حفظ الإعدادات بنجاح.';

  @override
  String get settingsSaveError =>
      'تعذّر حفظ الإعدادات. تحقق من اتصالك بالإنترنت ثم حاول مجددًا.';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsDescription =>
      'استقبل تنبيهات القطيع والرسائل الجديدة.';

  @override
  String get monitoringDurationLabel => 'مدة المراقبة';

  @override
  String get monitoringStart => 'تفعيل المراقبة';

  @override
  String get monitoringStop => 'إيقاف المراقبة';

  @override
  String get monitoringActive => 'المراقبة مفعّلة';

  @override
  String get monitoringInactive => 'المراقبة غير مفعّلة';

  @override
  String get monitoringRunningDescription =>
      'يتم التحقق من التنبيهات كل 30 ثانية طوال المدة المحددة. يلزم اتصال بالإنترنت.';

  @override
  String get monitoringPermissionDenied =>
      'اسمح بالإشعارات في Android لاستقبال التنبيهات.';

  @override
  String get monitoringOperationError => 'تعذّر تغيير مراقبة التنبيهات.';

  @override
  String get messagesNotifications => 'إشعارات الرسائل';

  @override
  String get messagesNotificationsDescription =>
      'أبلغني عند وصول رسالة جديدة حتى عند إغلاق التطبيق.';

  @override
  String get messagesNotificationsEnabled => 'تم تفعيل إشعارات الرسائل.';

  @override
  String get messagesNotificationsDisabled => 'تم إيقاف إشعارات الرسائل.';

  @override
  String get notificationsPermissionRequired =>
      'اسمح بالإشعارات من إعدادات Android للمتابعة.';

  @override
  String notificationDurationMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String notificationDurationHours(int hours) {
    return '$hours ساعة';
  }

  @override
  String get settingsUnexpectedError => 'حدث خطأ ما.';

  @override
  String settingsServerError(int statusCode) {
    return 'استجاب الخادم برمز الحالة $statusCode.';
  }

  @override
  String settingsInvalidValue(Object label) {
    return '$label: أدخل قيمة صحيحة.';
  }

  @override
  String get requiredField => 'هذا الحقل مطلوب.';

  @override
  String get integerRequired => 'يجب إدخال عدد صحيح.';

  @override
  String get numberRequired => 'يجب إدخال رقم.';

  @override
  String get settingsSaving => 'جارٍ الحفظ…';

  @override
  String get settingsChangesApplied => 'تُطبّق التغييرات بعد حفظها.';

  @override
  String get languageFrenchOption => 'الفرنسية';

  @override
  String get languageArabicOption => 'العربية';

  @override
  String get close => 'إغلاق';

  @override
  String countAlerts(Object count) {
    return '$count في حالة تنبيه';
  }

  @override
  String get searchAnimalsAndCoordinates => 'ابحث عن حيوان أو إحداثيات';

  @override
  String zoneLabel(Object name) {
    return 'المنطقة: $name';
  }

  @override
  String get unknownZone => 'مرعى';

  @override
  String get positionLive => 'موقع مباشر';

  @override
  String get collarNoSignal => 'قلادة بدون إشارة';

  @override
  String get alertActive => 'تنبيه فعال';

  @override
  String get herdGroupLabel => 'قطيع كبير';

  @override
  String smallHerdLabel(Object number) {
    return 'قطيع صغير $number';
  }

  @override
  String isolatedCow(Object id) {
    return 'بقرة منعزلة · $id';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get languageSection => 'اللغة';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String countAnimals(Object count) {
    return '$count حيوان';
  }

  @override
  String get onlineStatus => 'متصل';

  @override
  String get offlineStatus => 'غير متصل';

  @override
  String get alertsTitle => 'التنبيهات';

  @override
  String get alertsMonitoring => 'مراقبة القطيع';

  @override
  String get alertsToHandle => 'تنبيهات تحتاج إلى معالجة';

  @override
  String get alertsToHandleMessage => 'يتم تحديث التنبيهات مباشرة.';

  @override
  String get active => 'نشط';

  @override
  String get information => 'معلومة';

  @override
  String get alertSection => 'التنبيهات';

  @override
  String get infoSection => 'معلومة';

  @override
  String get noAlertsActive => 'لا توجد تنبيهات نشطة';

  @override
  String get noAlertsMessage =>
      'يتم مراقبة القطيع، وستظهر التنبيهات الجديدة هنا.';

  @override
  String get connectionInterrupted => 'تمت مقاطعة الاتصال';

  @override
  String get connectionInterruptedMessage =>
      'تمت مقاطعة الاتصال. ستظهر التنبيهات عند استعادة الاتصال.';

  @override
  String get animalLeftHerd => 'ابتعد هذا الحيوان عن بقية القطيع';

  @override
  String get animalOutsidePasture => 'خرج هذا الحيوان خارج المرعى';

  @override
  String animalAtDistanceFromLimit(Object distance) {
    return 'يقع على بعد $distance م من الحد.';
  }

  @override
  String get animalInactive =>
      'لم يتحرك هذا الحيوان تقريبًا منذ فترة طويلة. تحقق من عدم إصابته أو مرضه.';

  @override
  String get abnormalMovement =>
      'يتحرك هذا الحيوان بسرعة أو مسافة أكبر من المعتاد.';

  @override
  String get collarSilent =>
      'لا يرسل القلادة إشارة بعد الآن. تحقق من البطارية أو تغطية الشبكة.';

  @override
  String get abnormalBehavior => 'تغير سلوك هذا الحيوان مقارنة بعاداته.';

  @override
  String get noDetailProvided => 'لا توجد تفاصيل.';

  @override
  String get dateUnavailable => 'التاريخ غير متوفر';

  @override
  String get lstmPageTitle => 'الحركات غير الطبيعية';

  @override
  String get lstmPageSubtitle => 'يتم اكتشافها تلقائيًا';

  @override
  String get lstmEventTitle => 'حركة غير طبيعية';

  @override
  String get lstmExpectedPosition => 'الموقع المتوقع';

  @override
  String get lstmActualPosition => 'الموقع الفعلي';

  @override
  String lstmDistanceLabel(Object distance) {
    return 'الفرق: $distance';
  }

  @override
  String lstmMeters(int distance) {
    return '$distance م';
  }

  @override
  String lstmKilometers(Object distance) {
    return '$distance كم';
  }

  @override
  String lstmMovementDescription(Object distance) {
    return 'وفقًا لسلوكه المعتاد، كان يُفترض أن يكون الحيوان عند النقطة الزرقاء. لكنه يوجد فعليًا عند النقطة الحمراء، على بُعد نحو $distance.';
  }

  @override
  String get lstmAdviceStrong =>
      'هذه الحركة غير معتادة جدًا. ننصح بالتحقق من حالة الحيوان.';

  @override
  String get lstmAdviceMarked =>
      'هذه الحركة غير معتادة. يُنصح بالتحقق من الحيوان.';

  @override
  String get lstmAdviceModerate =>
      'هذه الحركة غير معتادة قليلًا؛ يُفضّل مراقبتها.';

  @override
  String get lstmLegacyPositionUnavailable =>
      'مواقع هذا التنبيه القديم غير متاحة. ستظهر الخريطة مع التنبيهات الجديدة.';

  @override
  String lstmTodayAt(Object time) {
    return 'اليوم في $time';
  }

  @override
  String lstmYesterdayAt(Object time) {
    return 'أمس في $time';
  }

  @override
  String lstmDateAt(Object day, Object month, int year, Object time) {
    return '$day/$month/$year في $time';
  }

  @override
  String get lstmLoadError =>
      'تعذّر تحميل البيانات. تحقق من اتصالك ثم حاول مجددًا.';

  @override
  String get lstmNoEvents => 'لا توجد حركات غير طبيعية';

  @override
  String get lstmNoEventsMessage =>
      'كل شيء يبدو طبيعيًا. ستظهر التنبيهات الجديدة هنا.';

  @override
  String get startedAt => 'البداية ·';

  @override
  String get viewActivityHistory => 'عرض سجل النشاط';

  @override
  String get animalNotIdentified => 'حيوان غير محدد';

  @override
  String get unknownAlert => 'تنبيه';

  @override
  String get animalSeparatedFromGroup => 'حيوان منفصل عن المجموعة حاليًا';

  @override
  String get animalsSeparatedFromGroup => 'حيوانات منفصلة عن المجموعة حاليًا';

  @override
  String get alertTypeOutOfZone => 'حيوان بعيد عن القطيع';

  @override
  String get alertTypeOutsidePasture => 'حيوان خارج المرعى';

  @override
  String get alertTypeInactive => 'حيوان ساكن لفترة طويلة';

  @override
  String get alertTypeUnusualMovement => 'حركة غير طبيعية';

  @override
  String get alertTypeCollarSilent => 'قلادة بدون إشارة';

  @override
  String get alertTypeUnusualBehavior => 'سلوك غير معتاد';

  @override
  String get herdOverviewTitle => 'نظرة عامة على المجموعات';

  @override
  String get waitingForData => 'في انتظار البيانات';

  @override
  String get groupsWillAppearHere =>
      'ستظهر المجموعات هنا بمجرد استقبال أول البيانات.';

  @override
  String get herdDataIncomplete => 'بيانات القطيع غير مكتملة';

  @override
  String get grandHerdNotYetDisplayed =>
      'لا يمكن عرض القطيع الكبير بعد. يرجى التحقق من البيانات المستلمة.';

  @override
  String get noHerdDetected => 'لم يتم اكتشاف قطيع بعد';

  @override
  String get groupAppearsWhenEnoughAnimals =>
      'ستظهر مجموعة عندما يتوفر عدد كافٍ من الحيوانات النشطة.';

  @override
  String get zoomIn => 'تكبير';

  @override
  String get zoomOut => 'تصغير';

  @override
  String get centerPasture => 'توسيط على منطقة الرعي';

  @override
  String get centerAnimals => 'توسيط على الحيوانات';

  @override
  String get waitingForFirstPositions => 'في انتظار أول المواقع…';

  @override
  String get trackingConnectionInterrupted => 'تمت مقاطعة اتصال المتابعة';

  @override
  String get noPositionsAvailable => 'لا توجد مواقع متاحة حاليًا';

  @override
  String get noPastureRecorded => 'لم يتم تسجيل أي منطقة رعي';

  @override
  String noAnimalMatches(Object query) {
    return 'لا يوجد حيوان يطابق «$query»';
  }

  @override
  String get enterCoordinatesFormat => 'أدخل الإحداثيات بالصيغة 36.80, 10.18';

  @override
  String get invalidCoordinatesExample =>
      'إحداثيات غير صالحة. مثال: 36.80, 10.18';

  @override
  String get pastureName => 'المرعى';

  @override
  String get mainPastureName => 'المرعى الرئيسي';

  @override
  String get automaticModeLabel => 'تلقائي';

  @override
  String get noGroupsDetected => 'لم يتم اكتشاف أي مجموعة';

  @override
  String groupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مجموعة',
      many: '$count مجموعة',
      few: '$count مجموعات',
      two: 'مجموعتان',
      one: 'مجموعة واحدة',
      zero: 'لا توجد مجموعات',
    );
    return '$_temp0';
  }

  @override
  String get detectedGroups => 'المجموعات المكتشفة';

  @override
  String get liveTrackedAnimals => 'الحيوانات المتابعة مباشرة';

  @override
  String get animalInAlert => 'حيوان في حالة تنبيه';

  @override
  String get alertSuffix => 'تنبيه';

  @override
  String get pastureZone => 'منطقة الرعي';

  @override
  String get distanceToMainHerd => 'المسافة إلى القطيع الرئيسي';

  @override
  String animalsInGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حيوان',
      many: '$count حيوانًا',
      few: '$count حيوانات',
      two: 'حيوانان',
      one: 'حيوان واحد',
      zero: '0 حيوان',
    );
    return '$_temp0';
  }

  @override
  String animalsOutsideZone(int count, Object ids) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# حيوان خارج المنطقة: $ids',
      many: '# حيوانًا خارج المنطقة: $ids',
      few: '# حيوانات خارج المنطقة: $ids',
      two: 'حيوانان خارج المنطقة: $ids',
      one: 'حيوان واحد خارج المنطقة: $ids',
    );
    return '$_temp0';
  }

  @override
  String get openStreetMapAttribution => '© مساهمو OpenStreetMap';

  @override
  String get herdTracking => 'مراقبة القطيع';

  @override
  String get currentComposition => 'التركيبة الحالية';

  @override
  String get herdCompositionDescription =>
      'تعرّف على المجموعات والحيوانات المنعزلة.';

  @override
  String get isolatedGroups => 'المجموعات المنعزلة';

  @override
  String get animalsAlone => 'الحيوانات المنعزلة';

  @override
  String get animalsInGroupLabel => 'الحيوانات في المجموعة';

  @override
  String get otherGroups => 'مجموعات أخرى';

  @override
  String get noOtherGroups => 'لم يتم اكتشاف مجموعات أخرى حاليًا.';

  @override
  String get isolatedAnimal => 'حيوان منعزل';

  @override
  String get smallHerd => 'قطيع صغير';

  @override
  String get distanceUnavailable => 'المسافة غير متاحة';

  @override
  String distanceFromMainHerd(Object distance) {
    return 'على بُعد $distance م من القطيع الرئيسي';
  }

  @override
  String get thresholdExceeded => 'تم تجاوز الحد';

  @override
  String get belowThreshold => 'ضمن الحد';

  @override
  String get animalIdsUnavailable => 'معرّفات الحيوانات غير متاحة.';

  @override
  String get myHerd => 'قطيعي';

  @override
  String get animalTrackingLive => 'متابعة الحيوانات مباشرة';

  @override
  String get trackedAnimals => 'الحيوانات المتابعة';

  @override
  String get searchAnimalsGroupsTypes => 'ابحث عن حيوان أو مجموعة أو نوع';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get cardsView => 'بطاقات';

  @override
  String get tableView => 'جدول';

  @override
  String get animalsHeading => 'الحيوانات';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا توجد نتائج',
    );
    return '$_temp0';
  }

  @override
  String get identifier => 'المعرّف';

  @override
  String get group => 'المجموعة';

  @override
  String get type => 'النوع';

  @override
  String get sex => 'الجنس';

  @override
  String get age => 'العمر';

  @override
  String get weight => 'الوزن';

  @override
  String get gps => 'الموقع';

  @override
  String get lastMeasurement => 'آخر قياس';

  @override
  String get action => 'إجراء';

  @override
  String get edit => 'تعديل';

  @override
  String get editInformation => 'تعديل المعلومات';

  @override
  String get unknownGroup => 'مجموعة غير معروفة';

  @override
  String get addAnimalDetails => 'أضف العمر والنوع والوزن والجنس';

  @override
  String animalInfoSaved(Object id) {
    return 'تم حفظ معلومات $id';
  }

  @override
  String get animalInfoUnavailable => 'معلومات الحيوانات غير متاحة.';

  @override
  String get now => 'الآن';

  @override
  String timeAgo(Object count, Object unit) {
    return 'قبل $count $unit';
  }

  @override
  String get secondsShort => 'ث';

  @override
  String get minutesShort => 'د';

  @override
  String get hoursShort => 'س';

  @override
  String get daysShort => 'ي';

  @override
  String get gpsUnavailable => 'موقع GPS غير متاح';

  @override
  String get animalFeatures => 'معلومات الحيوان';

  @override
  String get typeAndBreed => 'النوع / السلالة';

  @override
  String get currentValue => 'القيمة الحالية';

  @override
  String get female => 'أنثى';

  @override
  String get male => 'ذكر';

  @override
  String get yearsUnit => 'سنة';

  @override
  String get monthsUnit => 'شهر';

  @override
  String ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سنة',
      many: '$count سنة',
      few: '$count سنوات',
      two: 'سنتان',
      one: 'سنة واحدة',
      zero: '0 سنة',
    );
    return '$_temp0';
  }

  @override
  String ageMonths(Object count) {
    return '$count شهر';
  }

  @override
  String get invalidNumber => 'الرقم غير صالح';

  @override
  String get ageRangeError => 'يجب أن يكون العمر بين 0 و40 سنة';

  @override
  String get weightRangeError => 'يجب أن يكون الوزن بين 1 و1500 كغ';

  @override
  String get saveFailed => 'تعذّر الحفظ.';

  @override
  String get waitingPositions => 'في انتظار المواقع…';

  @override
  String get trackingOffline => 'المتابعة غير متصلة';

  @override
  String get noAnimalFound => 'لم يتم العثور على حيوان';

  @override
  String get animalsAppearOnGps =>
      'ستظهر الحيوانات هنا عند وصول تحديث GPS التالي.';

  @override
  String get connectionInterruptedAnimals =>
      'الاتصال مقطوع. ستظهر المواقع مجددًا عند استعادة الاتصال.';

  @override
  String get tryDifferentSearch => 'جرّب معرّفًا أو مجموعة أو نوعًا آخر.';

  @override
  String get resetSearch => 'إعادة ضبط البحث';

  @override
  String get speciesCattle => 'الأبقار';

  @override
  String get speciesSheep => 'الأغنام';

  @override
  String get speciesHorses => 'الخيول';

  @override
  String get breedHolstein => 'هولشتاين (أبيض وأسود)';

  @override
  String get breedBrownSwiss => 'براون سويس (بنية)';

  @override
  String get breedTarentaise => 'تارانتيس';

  @override
  String get breedMontbeliarde => 'مونبيليارد';

  @override
  String get breedNormande => 'نورماند';

  @override
  String get breedRedPied => 'بي روج';

  @override
  String get breedJersey => 'جيرسي';

  @override
  String get breedAtlasBrown => 'بنية الأطلس (أربي)';

  @override
  String get breedCapBonBlonde => 'شقراء الوطن القبلي';

  @override
  String get breedCrossbred => 'سلالات مهجنة';

  @override
  String get breedBarbarine => 'برابرين (عربي)';

  @override
  String get breedFineTail => 'رفيعة الذيل الغربية (غربي)';

  @override
  String get breedThibar => 'سوداء تيبار';

  @override
  String get breedSiciloSarde => 'صقلية سردينية';

  @override
  String get breedCherki => 'شرقي (هجين)';

  @override
  String get breedBarb => 'بربري تونسي';

  @override
  String get breedArabian => 'عربي أصيل';

  @override
  String get breedArabBarb => 'عربي بربري';

  @override
  String get breedMogodsPony => 'مهر المغود';

  @override
  String get breedThoroughbred => 'إنجليزي أصيل';

  @override
  String get historyTitle => 'سجل النشاط';

  @override
  String get recentAnimalActivity => 'متابعة حديثة لحيواناتك';

  @override
  String get searchAnimalId => 'ابحث باستخدام المعرّف (مثال: cow01)';

  @override
  String get clear => 'مسح';

  @override
  String get yourAnimals => 'حيواناتك';

  @override
  String get selectAnimalForActivity => 'اختر حيوانًا للاطلاع على نشاطه.';

  @override
  String get viewActivityForSevenDays => 'عرض النشاط خلال 7 أيام';

  @override
  String get noHistoryAnimals => 'لا توجد حيوانات لعرض سجلها.';

  @override
  String get noSearchResults => 'لا توجد نتائج';

  @override
  String get noAnimalToDisplay => 'لا توجد حيوانات لعرضها';

  @override
  String noAnimalMatchesSearch(Object query) {
    return 'لا يوجد حيوان يطابق «$query».';
  }

  @override
  String get lstmAnalysisTitle => 'تحليل النشاط باستخدام LSTM';

  @override
  String get purposeOfPage => 'ما فائدة هذه الصفحة؟';

  @override
  String get lstmExplanation =>
      'تعرض هذه الصفحة سجل نشاط كل حيوان. يحلل نموذج LSTM، وهو شبكة عصبية مصممة لفهم التسلسلات الزمنية، بيانات الطوق مثل موقع GPS والحركة. فهو لا ينظر إلى قياس منفرد، بل إلى كيفية تغير السلوك ساعة بعد ساعة.';

  @override
  String get collection => 'جمع البيانات';

  @override
  String get collarSendsMovement => 'يرسل الطوق موقع الحيوان وحركته بانتظام.';

  @override
  String get lstmAnalysis => 'تحليل LSTM';

  @override
  String get modelStudiesData =>
      'يدرس النموذج تسلسل البيانات للتعرف على النشاط: الراحة والمشي والجري…';

  @override
  String get result => 'النتيجة';

  @override
  String get historyHighlightsBehavior =>
      'يسلط السجل الضوء على السلوك غير المعتاد لمساعدتك على التدخل مبكرًا.';

  @override
  String get historyAnalysisTooltip => 'تحليل LSTM: الحركات النشطة';

  @override
  String get aiAnalysis => 'تحليل الذكاء الاصطناعي';

  @override
  String get historyPeriod => 'الفترة المراد عرضها';

  @override
  String get historyPeriodHint => 'اختر عدد الأيام الأخيرة لعرضها';

  @override
  String get dayShort => 'ي';

  @override
  String dayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يومًا',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
      zero: '0 يوم',
    );
    return '$_temp0';
  }

  @override
  String get loadingHistory => 'جارٍ تحميل السجل…';

  @override
  String get errorOccurred => 'حدث خطأ.';

  @override
  String get noMeasurementForAnimal => 'لا توجد قياسات لهذا الحيوان.';

  @override
  String get analysisServiceUnavailable => 'خدمة التحليل غير متاحة مؤقتًا.';

  @override
  String get historyNetworkError =>
      'تعذر الاتصال بالخادم. تحقق من اتصالك أو حاول لاحقًا؛ قد تكون خدمة التحليل متوقفة لهذا الحيوان.';

  @override
  String get invalidHistoryPeriod => 'الفترة المطلوبة غير صالحة.';

  @override
  String get historyLoadError => 'حدث خطأ أثناء تحميل السجل.';

  @override
  String get historyUnavailable => 'السجل غير متاح';

  @override
  String get insufficientAiReference =>
      'بيانات مرجعية غير كافية للذكاء الاصطناعي';

  @override
  String get insufficientHistoryExplanation =>
      'لا يملك النموذج نقاطًا مرجعية كافية لحساب النشاط المعتاد.';

  @override
  String get activityChartTitle => 'نشاط الحيوان';

  @override
  String get noDataYet => 'لا توجد بيانات بعد';

  @override
  String get noActivityForAnimal => 'لا يوجد نشاط لعرضه لهذا الحيوان.';

  @override
  String get noActivityData => 'لا توجد بيانات نشاط لعرضها.';

  @override
  String get normalActivity => 'طبيعي';

  @override
  String get calmerThanUsual => 'أقل نشاطًا من المعتاد';

  @override
  String get moreActiveThanUsual => 'أكثر نشاطًا من المعتاد';

  @override
  String get usualRhythmAi => 'النشاط المعتاد (ذكاء اصطناعي)';

  @override
  String get noMeasurement => 'لا توجد قياسات';

  @override
  String get calm => 'هادئ';

  @override
  String get measured => 'تم القياس';

  @override
  String get partial => 'جزئي';

  @override
  String get noMeasurementThisDay => 'لا توجد قياسات في هذا اليوم';

  @override
  String get usualActivity => 'النشاط طبيعي';

  @override
  String get noReferenceForComparison => 'لا توجد بيانات مرجعية للمقارنة بعد';

  @override
  String incompleteDayNoEvaluation(Object hours) {
    return 'يوم غير مكتمل ($hours ساعة من القياسات): لا يمكن التقييم';
  }

  @override
  String get calmerThanUsualLong => 'أقل نشاطًا من المعتاد';

  @override
  String get moreActiveThanUsualLong => 'أكثر نشاطًا من المعتاد';

  @override
  String get daysMondayShort => 'اثن.';

  @override
  String get daysTuesdayShort => 'ثلا.';

  @override
  String get daysWednesdayShort => 'أرب.';

  @override
  String get daysThursdayShort => 'خمي.';

  @override
  String get daysFridayShort => 'جمع.';

  @override
  String get daysSaturdayShort => 'سبت';

  @override
  String get daysSundayShort => 'أحد';

  @override
  String usualStepsTooltip(Object steps) {
    return 'المعتاد: $steps خطوة';
  }

  @override
  String stepCount(Object steps) {
    return '$steps خطوة';
  }

  @override
  String get historyIncompleteDay => 'بيانات غير مكتملة';

  @override
  String get messengerTab => 'الرسائل';

  @override
  String get messengerTitle => 'المراسلة';

  @override
  String get messengerSearch => 'البحث في المحادثات';

  @override
  String get messengerAll => 'الكل';

  @override
  String get messengerPrivate => 'شخصية';

  @override
  String get messengerGroups => 'المجموعات';

  @override
  String get messengerNewConversation => 'محادثة جديدة';

  @override
  String get messengerNewDiscussion => 'محادثة جديدة';

  @override
  String get messengerCreateGroup => 'إنشاء مجموعة';

  @override
  String get messengerChoosePeople => 'اختيار المشاركين';

  @override
  String get messengerGroupName => 'اسم المجموعة';

  @override
  String get messengerMembers => 'مشاركون';

  @override
  String get messengerNoConversations => 'لا توجد محادثات بعد.';

  @override
  String get messengerNoUsers => 'لا يوجد مستخدمون آخرون.';

  @override
  String get messengerLoadingError => 'تعذر تحميل المحادثات.';

  @override
  String get messengerRetry => 'إعادة المحاولة';

  @override
  String get messengerMessageHint => 'اكتب رسالة…';

  @override
  String get messengerSend => 'إرسال';

  @override
  String get messengerNoMessages => 'أرسل أول رسالة.';

  @override
  String get messengerYou => 'أنت';

  @override
  String get messengerCancel => 'إلغاء';

  @override
  String get messengerCreate => 'إنشاء';

  @override
  String get messengerContinue => 'متابعة';

  @override
  String get messengerSelectOne => 'اختر مستخدمًا واحدًا على الأقل.';

  @override
  String get messengerGroupNameRequired => 'أدخل اسم المجموعة.';

  @override
  String get messengerAddMembers => 'إضافة مشاركين';

  @override
  String get messengerGroupCreated => 'تم إنشاء المجموعة';

  @override
  String get messengerConnectionError => 'المراسلة غير متاحة مؤقتًا.';

  @override
  String get messengerMessageError => 'تعذر إرسال الرسالة.';

  @override
  String get messengerToday => 'اليوم';
}
