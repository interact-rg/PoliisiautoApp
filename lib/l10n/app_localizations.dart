import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fi.dart';

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
    Locale('en'),
    Locale('fi')
  ];

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the application'**
  String get aboutApp;

  /// No description provided for @addressed.
  ///
  /// In en, this message translates to:
  /// **'Addressed'**
  String get addressed;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @alright.
  ///
  /// In en, this message translates to:
  /// **'Alright'**
  String get alright;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'PoliisiautoApp'**
  String get appName;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @bulliedPerson.
  ///
  /// In en, this message translates to:
  /// **'The person being bullied was someone other than me'**
  String get bulliedPerson;

  /// No description provided for @bully.
  ///
  /// In en, this message translates to:
  /// **'Bully'**
  String get bully;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cantLeaveEmpty.
  ///
  /// In en, this message translates to:
  /// **'You cannot leave this field empty!'**
  String get cantLeaveEmpty;

  /// No description provided for @checkEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Make sure you typed the email and password correctly.'**
  String get checkEmailAndPassword;

  /// No description provided for @createdByMe.
  ///
  /// In en, this message translates to:
  /// **' Created by me'**
  String get createdByMe;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description '**
  String get description;

  /// No description provided for @disengageFromSituation.
  ///
  /// In en, this message translates to:
  /// **'If possible, try to disengage from the situation.'**
  String get disengageFromSituation;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emergencyInfo.
  ///
  /// In en, this message translates to:
  /// **'When you make an emergency report, the nearest Adults will receive a notification showing your name, location and other information.'**
  String get emergencyInfo;

  /// No description provided for @emergencyIsSendAdult.
  ///
  /// In en, this message translates to:
  /// **'An emergency notification has been sent to the nearest adults'**
  String get emergencyIsSendAdult;

  /// No description provided for @emergencyNotification.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to send an emergency notification?'**
  String get emergencyNotification;

  /// No description provided for @emergencyReport.
  ///
  /// In en, this message translates to:
  /// **'Make an emergency report'**
  String get emergencyReport;

  /// No description provided for @en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get en;

  /// No description provided for @fi.
  ///
  /// In en, this message translates to:
  /// **'Finnish'**
  String get fi;

  /// No description provided for @findAdult.
  ///
  /// In en, this message translates to:
  /// **'The emergency notification and your location have been sent.'**
  String get findAdult;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @frontpage.
  ///
  /// In en, this message translates to:
  /// **'Front page'**
  String get frontpage;

  /// No description provided for @giveEmail.
  ///
  /// In en, this message translates to:
  /// **'Give email address'**
  String get giveEmail;

  /// No description provided for @givePassword.
  ///
  /// In en, this message translates to:
  /// **'Give password'**
  String get givePassword;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpInfoText.
  ///
  /// In en, this message translates to:
  /// **'The organization\'s own links and other content can be searched for on this page.'**
  String get helpInfoText;

  /// No description provided for @helpPages.
  ///
  /// In en, this message translates to:
  /// **'Help pages'**
  String get helpPages;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// No description provided for @homePagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'This includes, for example, organization-specific content, which can change daily.'**
  String get homePagePlaceholder;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @infoText.
  ///
  /// In en, this message translates to:
  /// **'Poliisiauto is an application designed by school children through which kids can report bullying to a trusted adult and adults can handle bullying cases. The source code of the application is open.'**
  String get infoText;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed!'**
  String get loginFailed;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @makeReport.
  ///
  /// In en, this message translates to:
  /// **'Make a report'**
  String get makeReport;

  /// No description provided for @messageContent.
  ///
  /// In en, this message translates to:
  /// **'Message content'**
  String get messageContent;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @myNotifications.
  ///
  /// In en, this message translates to:
  /// **'My reports'**
  String get myNotifications;

  /// No description provided for @mySettings.
  ///
  /// In en, this message translates to:
  /// **'My settings'**
  String get mySettings;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'I don\'t want the teacher to know my name'**
  String get noName;

  /// No description provided for @notReported.
  ///
  /// In en, this message translates to:
  /// **'Not reported'**
  String get notReported;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get notifications;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @placeholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Report title placeholder'**
  String get placeholderTitle;

  /// No description provided for @placeholderDate.
  ///
  /// In en, this message translates to:
  /// **'Date: 12.12.2023, 14.30'**
  String get placeholderDate;

  /// No description provided for @placeholderReceiver.
  ///
  /// In en, this message translates to:
  /// **'To: Mrs Jane Doe'**
  String get placeholderReceiver;

  /// No description provided for @pageHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {userName}'**
  String pageHomeTitle(Object userName);

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @receiver.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get receiver;

  /// No description provided for @reportDescription.
  ///
  /// In en, this message translates to:
  /// **'Description of the report'**
  String get reportDescription;

  /// No description provided for @reportInformation.
  ///
  /// In en, this message translates to:
  /// **'Report information'**
  String get reportInformation;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @sendNotificationWho.
  ///
  /// In en, this message translates to:
  /// **'Who do you want to send the notification to?'**
  String get sendNotificationWho;

  /// No description provided for @sendVideoImage.
  ///
  /// In en, this message translates to:
  /// **'Send a video image'**
  String get sendVideoImage;

  /// No description provided for @sendVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Send a voice message'**
  String get sendVoiceMessage;

  /// No description provided for @sendingEmergencyNotification.
  ///
  /// In en, this message translates to:
  /// **'Sending an emergency notification'**
  String get sendingEmergencyNotification;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @shouldWeSend.
  ///
  /// In en, this message translates to:
  /// **'Do we send this notification'**
  String get shouldWeSend;

  /// No description provided for @signin.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signin;

  /// No description provided for @spring.
  ///
  /// In en, this message translates to:
  /// **'spring'**
  String get spring;

  /// No description provided for @stopSending.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get stopSending;

  /// No description provided for @sure.
  ///
  /// In en, this message translates to:
  /// **'I\'m sure'**
  String get sure;

  /// No description provided for @tellWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'Tell in your own words what happened'**
  String get tellWhatHappened;

  /// No description provided for @thanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks'**
  String get thanks;

  /// No description provided for @victim.
  ///
  /// In en, this message translates to:
  /// **'Victim of bullying'**
  String get victim;

  /// No description provided for @whatHappened.
  ///
  /// In en, this message translates to:
  /// **' What happened?'**
  String get whatHappened;

  /// No description provided for @whoBullied.
  ///
  /// In en, this message translates to:
  /// **'Who bullied? (optional)'**
  String get whoBullied;

  /// No description provided for @whoWasBullied.
  ///
  /// In en, this message translates to:
  /// **' Who was bullied? (optional)'**
  String get whoWasBullied;

  /// No description provided for @writeMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get writeMessage;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @sendThisReport.
  ///
  /// In en, this message translates to:
  /// **'Do we send this report'**
  String get sendThisReport;
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
      <String>['en', 'fi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fi':
      return AppLocalizationsFi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
