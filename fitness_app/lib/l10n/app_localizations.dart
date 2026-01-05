import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('ar')];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'مدرب مجدل'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In ar, this message translates to:
  /// **'سجل الدخول للمتابعة'**
  String get signInToContinue;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get createAccount;

  /// No description provided for @startManaging.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ إدارة تدريبات اللياقة'**
  String get startManaging;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phone;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get alreadyHaveAccount;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @players.
  ///
  /// In ar, this message translates to:
  /// **'اللاعبين'**
  String get players;

  /// No description provided for @workoutPlans.
  ///
  /// In ar, this message translates to:
  /// **'خطة التمارين'**
  String get workoutPlans;

  /// No description provided for @exercises.
  ///
  /// In ar, this message translates to:
  /// **'التمارين'**
  String get exercises;

  /// No description provided for @subscriptions.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات'**
  String get subscriptions;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @helpSupport.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get helpSupport;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد تسجيل الخروج؟'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @deleteConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد حذف هذا؟'**
  String get deleteConfirmation;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get saveChanges;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @remove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة'**
  String get remove;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث...'**
  String get search;

  /// No description provided for @noPlayers.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد لاعبين حتى الآن'**
  String get noPlayers;

  /// No description provided for @addFirstPlayer.
  ///
  /// In ar, this message translates to:
  /// **'أضف لاعبك الأول للبدء'**
  String get addFirstPlayer;

  /// No description provided for @addPlayer.
  ///
  /// In ar, this message translates to:
  /// **'إضافة لاعب'**
  String get addPlayer;

  /// No description provided for @playerDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل اللاعب'**
  String get playerDetails;

  /// No description provided for @editPlayer.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات اللاعب'**
  String get editPlayer;

  /// No description provided for @activeSubscription.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراك النشط'**
  String get activeSubscription;

  /// No description provided for @subscriptionHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الاشتراكات'**
  String get subscriptionHistory;

  /// No description provided for @noActiveSubscription.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اشتراك نشط'**
  String get noActiveSubscription;

  /// No description provided for @expiringSoon.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي قريباً'**
  String get expiringSoon;

  /// No description provided for @expired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get expired;

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get active;

  /// No description provided for @cancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get cancelled;

  /// No description provided for @assignPlan.
  ///
  /// In ar, this message translates to:
  /// **'تعيين خطة'**
  String get assignPlan;

  /// No description provided for @noPlans.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد خطط تمرين'**
  String get noPlans;

  /// No description provided for @createFirstPlan.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ خطة التمرين الأولى'**
  String get createFirstPlan;

  /// No description provided for @createPlan.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء خطة'**
  String get createPlan;

  /// No description provided for @newPlan.
  ///
  /// In ar, this message translates to:
  /// **'خطة جديدة'**
  String get newPlan;

  /// No description provided for @planDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الخطة'**
  String get planDetails;

  /// No description provided for @weeklySchedule.
  ///
  /// In ar, this message translates to:
  /// **'جدول التدريب'**
  String get weeklySchedule;

  /// No description provided for @workoutDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام التمرين'**
  String get workoutDays;

  /// No description provided for @restDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام الراحة'**
  String get restDays;

  /// No description provided for @noWorkoutDays.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحديد أيام تمرين'**
  String get noWorkoutDays;

  /// No description provided for @editPlan.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الخطة'**
  String get editPlan;

  /// No description provided for @difficultyLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى الصعوبة'**
  String get difficultyLevel;

  /// No description provided for @description.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get description;

  /// No description provided for @focusArea.
  ///
  /// In ar, this message translates to:
  /// **'منطقة التركيز'**
  String get focusArea;

  /// No description provided for @selectWorkoutDays.
  ///
  /// In ar, this message translates to:
  /// **'تخطيط الأيام'**
  String get selectWorkoutDays;

  /// No description provided for @selectWorkoutDaysSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قم بإضافة أيام تمرين أو راحة بالتسلسل'**
  String get selectWorkoutDaysSubtitle;

  /// No description provided for @selectFocusAreas.
  ///
  /// In ar, this message translates to:
  /// **'مناطق التركيز (اختياري)'**
  String get selectFocusAreas;

  /// No description provided for @setFocusArea.
  ///
  /// In ar, this message translates to:
  /// **'حدد تركيزاً لكل يوم تمرين'**
  String get setFocusArea;

  /// No description provided for @dayEditor.
  ///
  /// In ar, this message translates to:
  /// **'محرر اليوم'**
  String get dayEditor;

  /// No description provided for @addExercise.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تمرين'**
  String get addExercise;

  /// No description provided for @noExercises.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تمارين'**
  String get noExercises;

  /// No description provided for @buildLibrary.
  ///
  /// In ar, this message translates to:
  /// **'ابنِ مكتبة تمارينك باستخدام فيديوهات يوتيوب'**
  String get buildLibrary;

  /// No description provided for @exerciseDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل التمرين'**
  String get exerciseDetails;

  /// No description provided for @muscleGroup.
  ///
  /// In ar, this message translates to:
  /// **'العضلة المستهدفة'**
  String get muscleGroup;

  /// No description provided for @youtubeUrl.
  ///
  /// In ar, this message translates to:
  /// **'رابط فيديو يوتيوب'**
  String get youtubeUrl;

  /// No description provided for @videoPreview.
  ///
  /// In ar, this message translates to:
  /// **'معاينة الفيديو'**
  String get videoPreview;

  /// No description provided for @defaultValues.
  ///
  /// In ar, this message translates to:
  /// **'القيم الافتراضية'**
  String get defaultValues;

  /// No description provided for @sets.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات (Sets)'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In ar, this message translates to:
  /// **'التكرارات (Reps)'**
  String get reps;

  /// No description provided for @duration.
  ///
  /// In ar, this message translates to:
  /// **'المدة (ثواني)'**
  String get duration;

  /// No description provided for @durationOptional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري، للتمارين الموقوتة'**
  String get durationOptional;

  /// No description provided for @videoLink.
  ///
  /// In ar, this message translates to:
  /// **'رابط الفيديو'**
  String get videoLink;

  /// No description provided for @videoNotAvailable.
  ///
  /// In ar, this message translates to:
  /// **'الفيديو غير متوفر'**
  String get videoNotAvailable;

  /// No description provided for @newSubscription.
  ///
  /// In ar, this message translates to:
  /// **'اشتراك جديد'**
  String get newSubscription;

  /// No description provided for @editSubscription.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الاشتراك'**
  String get editSubscription;

  /// No description provided for @selectPlayer.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللاعب'**
  String get selectPlayer;

  /// No description provided for @selectPlan.
  ///
  /// In ar, this message translates to:
  /// **'اختر خطة التمرين'**
  String get selectPlan;

  /// No description provided for @subscriptionDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة الاشتراك'**
  String get subscriptionDuration;

  /// No description provided for @startDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البدء'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء'**
  String get endDate;

  /// No description provided for @payment.
  ///
  /// In ar, this message translates to:
  /// **'الدفع (اختياري)'**
  String get payment;

  /// No description provided for @amount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get amount;

  /// No description provided for @paymentNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات الدفع'**
  String get paymentNotes;

  /// No description provided for @requiredField.
  ///
  /// In ar, this message translates to:
  /// **'حقل مطلوب'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'بريد إلكتروني غير صالح'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتف غير صالح'**
  String get invalidPhone;

  /// No description provided for @passwordLength.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تكون كلمة المرور 6 أحرف على الأقل'**
  String get passwordLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمات المرور غير متطابقة'**
  String get passwordsDoNotMatch;

  /// No description provided for @pleaseSelectPlayer.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء اختيار لاعب'**
  String get pleaseSelectPlayer;

  /// No description provided for @pleaseSelectPlan.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء اختيار خطة تمرين'**
  String get pleaseSelectPlan;

  /// No description provided for @success.
  ///
  /// In ar, this message translates to:
  /// **'تم بنجاح'**
  String get success;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// No description provided for @daysLeft.
  ///
  /// In ar, this message translates to:
  /// **'باقي {days} أيام'**
  String daysLeft(Object days);

  /// No description provided for @trainTrackTransform.
  ///
  /// In ar, this message translates to:
  /// **'تمرن. تتبع. تطور.'**
  String get trainTrackTransform;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً،'**
  String get welcome;

  /// No description provided for @day.
  ///
  /// In ar, this message translates to:
  /// **'اليوم {number}'**
  String day(int number);

  /// No description provided for @restDay.
  ///
  /// In ar, this message translates to:
  /// **'راحة'**
  String get restDay;

  /// No description provided for @addDay.
  ///
  /// In ar, this message translates to:
  /// **'إضافة يوم'**
  String get addDay;

  /// No description provided for @removeDay.
  ///
  /// In ar, this message translates to:
  /// **'حذف اليوم'**
  String get removeDay;

  /// No description provided for @exportPdf.
  ///
  /// In ar, this message translates to:
  /// **'تصدير PDF'**
  String get exportPdf;

  /// No description provided for @setDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المجموعات'**
  String get setDetails;

  /// No description provided for @setLabel.
  ///
  /// In ar, this message translates to:
  /// **'مجموعة {number}'**
  String setLabel(int number);

  /// No description provided for @repsLabel.
  ///
  /// In ar, this message translates to:
  /// **'تكرار'**
  String get repsLabel;

  /// No description provided for @weightLabel.
  ///
  /// In ar, this message translates to:
  /// **'وزن (كغ)'**
  String get weightLabel;

  /// No description provided for @noSubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اشتراكات'**
  String get noSubscriptions;

  /// No description provided for @assignPlansToPlayers.
  ///
  /// In ar, this message translates to:
  /// **'قم بتعيين خطط تمرين للاعبين لإنشاء اشتراكات'**
  String get assignPlansToPlayers;

  /// No description provided for @noWorkoutPlans.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد خطط تمرين'**
  String get noWorkoutPlans;

  /// No description provided for @createFirstPlanMessage.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ خطتك الأولى للتمرين'**
  String get createFirstPlanMessage;

  /// No description provided for @exercisesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} تمرين'**
  String exercisesCount(int count);

  /// No description provided for @weight.
  ///
  /// In ar, this message translates to:
  /// **'الوزن (كغ)'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In ar, this message translates to:
  /// **'الطول (سم)'**
  String get height;

  /// No description provided for @viewPlan.
  ///
  /// In ar, this message translates to:
  /// **'عرض الخطة'**
  String get viewPlan;

  /// No description provided for @playerWorkoutPlan.
  ///
  /// In ar, this message translates to:
  /// **'خطة تمرين اللاعب'**
  String get playerWorkoutPlan;

  /// No description provided for @noMatchingExercises.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تمارين مطابقة'**
  String get noMatchingExercises;
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
      <String>['ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
