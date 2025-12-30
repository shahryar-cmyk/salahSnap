import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('ur')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Salat Snap'**
  String get appTitle;

  /// No description provided for @appNameSalat.
  ///
  /// In en, this message translates to:
  /// **'Salat'**
  String get appNameSalat;

  /// No description provided for @appNameSnap.
  ///
  /// In en, this message translates to:
  /// **'Snap'**
  String get appNameSnap;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Salat Snap'**
  String get appName;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get languageSubtitle;

  /// No description provided for @prayerTimesTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimesTitle;

  /// No description provided for @setAlarms.
  ///
  /// In en, this message translates to:
  /// **'Set Alarms'**
  String get setAlarms;

  /// No description provided for @setAlarm.
  ///
  /// In en, this message translates to:
  /// **'Set Alarm'**
  String get setAlarm;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @capturedImage.
  ///
  /// In en, this message translates to:
  /// **'Captured Image'**
  String get capturedImage;

  /// No description provided for @step1ImagePreview.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Image Preview'**
  String get step1ImagePreview;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// No description provided for @process.
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get process;

  /// No description provided for @editPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Edit Prayer Times'**
  String get editPrayerTimes;

  /// No description provided for @imageAndOcrResult.
  ///
  /// In en, this message translates to:
  /// **'Image & OCR Result'**
  String get imageAndOcrResult;

  /// No description provided for @removeAlphabets.
  ///
  /// In en, this message translates to:
  /// **'Remove alphabets'**
  String get removeAlphabets;

  /// No description provided for @rawExtractedText.
  ///
  /// In en, this message translates to:
  /// **'Raw Extracted Text (Tap to edit times):'**
  String get rawExtractedText;

  /// No description provided for @clickSnapSetAlarms.
  ///
  /// In en, this message translates to:
  /// **'Click a snap and set alarms'**
  String get clickSnapSetAlarms;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @aboutUsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn more about Salat Snap'**
  String get aboutUsSubtitle;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @contactUsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with us'**
  String get contactUsSubtitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @mealPlanner.
  ///
  /// In en, this message translates to:
  /// **'Meal Planner'**
  String get mealPlanner;

  /// No description provided for @profileGreeting.
  ///
  /// In en, this message translates to:
  /// **'ٱلسَّلَامُ عَلَيْكُمْ'**
  String get profileGreeting;

  /// No description provided for @profileThankYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting us!'**
  String get profileThankYouTitle;

  /// No description provided for @profileThankYouDesc.
  ///
  /// In en, this message translates to:
  /// **'As a local business, we thank you for supporting us and hope you enjoy.'**
  String get profileThankYouDesc;

  /// No description provided for @aboutIntro.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Salat Snap – a smart and easy-to-use Islamic app designed to help Muslims stay punctual with their prayers, wherever they are in the world.'**
  String get aboutIntro;

  /// No description provided for @aboutDetails.
  ///
  /// In en, this message translates to:
  /// **'Salat Snap introduces a modern and convenient way to set prayer times using QR code scanning. Simply scan the QR code provided on your prayer timetable or mosque display, and the app will instantly fetch accurate prayer times.\n\nOnce scanned, Salat Snap automatically sets alarms for all five daily prayers — Fajr, Dhuhr, Asr, Maghrib, Isha — along with Jumuah on Fridays. No manual entry, no complicated setup — just scan, confirm, and stay connected with your prayers.'**
  String get aboutDetails;

  /// No description provided for @aboutBeliefTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Mission:'**
  String get aboutBeliefTitle;

  /// No description provided for @aboutQuoteAuthor.
  ///
  /// In en, this message translates to:
  /// **'Chef Ron'**
  String get aboutQuoteAuthor;

  /// No description provided for @aboutQuoteText.
  ///
  /// In en, this message translates to:
  /// **'“Prayer is the pillar of faith.”\nSalat Snap helps you protect this pillar with simplicity, accuracy, and ease.'**
  String get aboutQuoteText;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'salatsnap@srafique.com'**
  String get contactEmail;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'(123) 456-7890'**
  String get contactPhone;

  /// No description provided for @contactAddress.
  ///
  /// In en, this message translates to:
  /// **'123 Example St, City, State 12345'**
  String get contactAddress;

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code to get prayer times'**
  String get onboardTitle1;

  /// No description provided for @onboardSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Instantly fetch accurate prayer times'**
  String get onboardSubtitle1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'Auto set prayer alarms'**
  String get onboardTitle2;

  /// No description provided for @onboardSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'All prayer alarms set automatically in one scan'**
  String get onboardSubtitle2;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;
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
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
