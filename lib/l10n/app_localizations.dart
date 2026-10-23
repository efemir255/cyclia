import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cyclia'**
  String get appTitle;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get navHealth;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @sources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sources;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Cyclia'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Track your cycle, understand each phase, and get guidance that fits your health.'**
  String get onboardingWelcomeBody;

  /// No description provided for @privacyLocal.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this phone. No account, no cloud.'**
  String get privacyLocal;

  /// No description provided for @privacyEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Everything is stored in an encrypted database.'**
  String get privacyEncrypted;

  /// No description provided for @privacyNoDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Cyclia never diagnoses. Its guidance is general information, not medical advice.'**
  String get privacyNoDiagnosis;

  /// No description provided for @disclaimerAccept.
  ///
  /// In en, this message translates to:
  /// **'I understand that Cyclia is not a medical device and its predictions must not be used as contraception.'**
  String get disclaimerAccept;

  /// No description provided for @lastPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'When did your last period start?'**
  String get lastPeriodTitle;

  /// No description provided for @lastPeriodUnknown.
  ///
  /// In en, this message translates to:
  /// **'I don\'t remember'**
  String get lastPeriodUnknown;

  /// No description provided for @cycleTitle.
  ///
  /// In en, this message translates to:
  /// **'Your usual cycle'**
  String get cycleTitle;

  /// No description provided for @cycleLength.
  ///
  /// In en, this message translates to:
  /// **'Cycle length'**
  String get cycleLength;

  /// No description provided for @periodLength.
  ///
  /// In en, this message translates to:
  /// **'Period length'**
  String get periodLength;

  /// No description provided for @cycleLengthHint.
  ///
  /// In en, this message translates to:
  /// **'From the first day of one period to the first day of the next. Not sure? Keep the defaults. Cyclia learns as you log.'**
  String get cycleLengthHint;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @conditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnosed conditions'**
  String get conditionsTitle;

  /// No description provided for @conditionsBody.
  ///
  /// In en, this message translates to:
  /// **'Optional. Choose any conditions a doctor has diagnosed and Cyclia will tailor its guidance. You can change this later.'**
  String get conditionsBody;

  /// No description provided for @finishOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Start using Cyclia'**
  String get finishOnboarding;

  /// No description provided for @conditionPcos.
  ///
  /// In en, this message translates to:
  /// **'PCOS / PMOS'**
  String get conditionPcos;

  /// No description provided for @conditionEndometriosis.
  ///
  /// In en, this message translates to:
  /// **'Endometriosis'**
  String get conditionEndometriosis;

  /// No description provided for @conditionIronDeficiencyAnemia.
  ///
  /// In en, this message translates to:
  /// **'Iron deficiency anaemia'**
  String get conditionIronDeficiencyAnemia;

  /// No description provided for @conditionHypothyroidism.
  ///
  /// In en, this message translates to:
  /// **'Underactive thyroid'**
  String get conditionHypothyroidism;

  /// No description provided for @conditionInsulinResistance.
  ///
  /// In en, this message translates to:
  /// **'Insulin resistance / type 2 diabetes'**
  String get conditionInsulinResistance;

  /// No description provided for @phaseMenstrual.
  ///
  /// In en, this message translates to:
  /// **'Menstrual phase'**
  String get phaseMenstrual;

  /// No description provided for @phaseFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular phase'**
  String get phaseFollicular;

  /// No description provided for @phaseOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get phaseOvulation;

  /// No description provided for @phaseLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal phase'**
  String get phaseLuteal;

  /// No description provided for @noDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Log your period to see predictions'**
  String get noDataTitle;

  /// No description provided for @noDataBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below on the first day of your next period, or add a past one from the calendar.'**
  String get noDataBody;

  /// No description provided for @periodStarted.
  ///
  /// In en, this message translates to:
  /// **'My period started'**
  String get periodStarted;

  /// No description provided for @periodEnded.
  ///
  /// In en, this message translates to:
  /// **'My period ended'**
  String get periodEnded;

  /// No description provided for @periodDay.
  ///
  /// In en, this message translates to:
  /// **'Period day {day}'**
  String periodDay(int day);

  /// No description provided for @periodExpectedEnd.
  ///
  /// In en, this message translates to:
  /// **'Expected to end {date}'**
  String periodExpectedEnd(String date);

  /// No description provided for @periodIn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Period expected today} =1{Period tomorrow} other{Period in {count} days}}'**
  String periodIn(int count);

  /// No description provided for @periodLate.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Period 1 day late} other{Period {count} days late}}'**
  String periodLate(int count);

  /// No description provided for @lateHint.
  ///
  /// In en, this message translates to:
  /// **'Periods can be late because of stress, illness, weight changes and other reasons. If you could be pregnant, take a test, and talk to a doctor if you\'re worried.'**
  String get lateHint;

  /// No description provided for @cycleDay.
  ///
  /// In en, this message translates to:
  /// **'Cycle day {day}'**
  String cycleDay(int day);

  /// No description provided for @nextPeriodOn.
  ///
  /// In en, this message translates to:
  /// **'Next period around {date}'**
  String nextPeriodOn(String date);

  /// No description provided for @fertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Estimated fertile window: {start} – {end}'**
  String fertileWindow(String start, String end);

  /// No description provided for @todayLog.
  ///
  /// In en, this message translates to:
  /// **'Today\'s log'**
  String get todayLog;

  /// No description provided for @logSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Log symptoms & mood'**
  String get logSymptoms;

  /// No description provided for @nothingLogged.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet today.'**
  String get nothingLogged;

  /// No description provided for @phaseTips.
  ///
  /// In en, this message translates to:
  /// **'Tips for this phase'**
  String get phaseTips;

  /// No description provided for @forYourConditions.
  ///
  /// In en, this message translates to:
  /// **'For your conditions'**
  String get forYourConditions;

  /// No description provided for @errorInFuture.
  ///
  /// In en, this message translates to:
  /// **'You can\'t log a period in the future.'**
  String get errorInFuture;

  /// No description provided for @errorInsidePeriod.
  ///
  /// In en, this message translates to:
  /// **'A period is already logged on this day.'**
  String get errorInsidePeriod;

  /// No description provided for @flow.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get flow;

  /// No description provided for @flowSpotting.
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get flowSpotting;

  /// No description provided for @flowLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get flowLight;

  /// No description provided for @flowMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get flowMedium;

  /// No description provided for @flowHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get flowHeavy;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @symptomCramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get symptomCramps;

  /// No description provided for @symptomHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get symptomHeadache;

  /// No description provided for @symptomBloating.
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get symptomBloating;

  /// No description provided for @symptomBackPain.
  ///
  /// In en, this message translates to:
  /// **'Back pain'**
  String get symptomBackPain;

  /// No description provided for @symptomBreastTenderness.
  ///
  /// In en, this message translates to:
  /// **'Tender breasts'**
  String get symptomBreastTenderness;

  /// No description provided for @symptomAcne.
  ///
  /// In en, this message translates to:
  /// **'Acne'**
  String get symptomAcne;

  /// No description provided for @symptomFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomFatigue;

  /// No description provided for @symptomNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get symptomNausea;

  /// No description provided for @symptomCravings.
  ///
  /// In en, this message translates to:
  /// **'Cravings'**
  String get symptomCravings;

  /// No description provided for @symptomInsomnia.
  ///
  /// In en, this message translates to:
  /// **'Poor sleep'**
  String get symptomInsomnia;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodCalm;

  /// No description provided for @moodEnergetic.
  ///
  /// In en, this message translates to:
  /// **'Energetic'**
  String get moodEnergetic;

  /// No description provided for @moodSensitive.
  ///
  /// In en, this message translates to:
  /// **'Sensitive'**
  String get moodSensitive;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodIrritable.
  ///
  /// In en, this message translates to:
  /// **'Irritable'**
  String get moodIrritable;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @startPeriodHere.
  ///
  /// In en, this message translates to:
  /// **'Period started this day'**
  String get startPeriodHere;

  /// No description provided for @endPeriodHere.
  ///
  /// In en, this message translates to:
  /// **'Period ended this day'**
  String get endPeriodHere;

  /// No description provided for @deletePeriod.
  ///
  /// In en, this message translates to:
  /// **'Delete this period'**
  String get deletePeriod;

  /// No description provided for @deletePeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this period?'**
  String get deletePeriodTitle;

  /// No description provided for @deletePeriodBody.
  ///
  /// In en, this message translates to:
  /// **'The period from {start} will be removed. Your symptom logs are kept.'**
  String deletePeriodBody(String start);

  /// No description provided for @loggedPeriodRange.
  ///
  /// In en, this message translates to:
  /// **'Logged period: {start} – {end}'**
  String loggedPeriodRange(String start, String end);

  /// No description provided for @ongoingPeriodFrom.
  ///
  /// In en, this message translates to:
  /// **'Ongoing period since {start}'**
  String ongoingPeriodFrom(String start);

  /// No description provided for @legendPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get legendPeriod;

  /// No description provided for @legendPredicted.
  ///
  /// In en, this message translates to:
  /// **'Predicted'**
  String get legendPredicted;

  /// No description provided for @legendFertile.
  ///
  /// In en, this message translates to:
  /// **'Fertile'**
  String get legendFertile;

  /// No description provided for @legendOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get legendOvulation;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yourCycle.
  ///
  /// In en, this message translates to:
  /// **'Your cycle'**
  String get yourCycle;

  /// No description provided for @averageCycle.
  ///
  /// In en, this message translates to:
  /// **'Average cycle'**
  String get averageCycle;

  /// No description provided for @averagePeriod.
  ///
  /// In en, this message translates to:
  /// **'Average period'**
  String get averagePeriod;

  /// No description provided for @cyclesLogged.
  ///
  /// In en, this message translates to:
  /// **'Cycles logged'**
  String get cyclesLogged;

  /// No description provided for @recentCycles.
  ///
  /// In en, this message translates to:
  /// **'Recent cycle lengths'**
  String get recentCycles;

  /// No description provided for @notEnoughCycles.
  ///
  /// In en, this message translates to:
  /// **'Log at least two periods to see your cycle history.'**
  String get notEnoughCycles;

  /// No description provided for @commonSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Most logged symptoms (last 90 days)'**
  String get commonSymptoms;

  /// No description provided for @noSymptoms.
  ///
  /// In en, this message translates to:
  /// **'No symptoms logged in the last 90 days.'**
  String get noSymptoms;

  /// No description provided for @myConditions.
  ///
  /// In en, this message translates to:
  /// **'My conditions'**
  String get myConditions;

  /// No description provided for @noConditions.
  ///
  /// In en, this message translates to:
  /// **'No conditions added. Adding conditions a doctor has diagnosed lets Cyclia tailor its guidance.'**
  String get noConditions;

  /// No description provided for @dietTips.
  ///
  /// In en, this message translates to:
  /// **'Food & diet'**
  String get dietTips;

  /// No description provided for @lifestyleTips.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get lifestyleTips;

  /// No description provided for @cyclePhases.
  ///
  /// In en, this message translates to:
  /// **'Your cycle phases'**
  String get cyclePhases;

  /// No description provided for @disclaimerShort.
  ///
  /// In en, this message translates to:
  /// **'Cyclia offers general information, not medical advice. Talk to a doctor about your health.'**
  String get disclaimerShort;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get privacySecurity;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @appLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require your fingerprint, face or device PIN to open Cyclia'**
  String get appLockSubtitle;

  /// No description provided for @appLockUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Set up a screen lock on your device to use app lock.'**
  String get appLockUnavailable;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @periodReminder.
  ///
  /// In en, this message translates to:
  /// **'Upcoming period'**
  String get periodReminder;

  /// No description provided for @periodReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Two days before your next predicted period'**
  String get periodReminderSubtitle;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in'**
  String get dailyReminder;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for Cyclia. Turn them on in your phone\'s settings to get reminders.'**
  String get notificationsDenied;

  /// No description provided for @cycleDefaults.
  ///
  /// In en, this message translates to:
  /// **'Cycle defaults'**
  String get cycleDefaults;

  /// No description provided for @cycleDefaultsHint.
  ///
  /// In en, this message translates to:
  /// **'Used until you\'ve logged enough cycles for personal averages.'**
  String get cycleDefaultsHint;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Cyclia is an open-source project. Your data never leaves this device.'**
  String get aboutBody;

  /// No description provided for @disclaimerFull.
  ///
  /// In en, this message translates to:
  /// **'Cyclia provides general information and is not a medical device. It does not replace professional medical advice, diagnosis or treatment. Cycle and fertility predictions are estimates and must not be used as contraception.'**
  String get disclaimerFull;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// No description provided for @deleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteAllTitle;

  /// No description provided for @deleteAllBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently erases every period, log and condition from this phone. It can\'t be undone.'**
  String get deleteAllBody;

  /// No description provided for @deleteAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteAllConfirm;

  /// No description provided for @lockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Cyclia is locked'**
  String get lockedTitle;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @unlockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Cyclia to see your health data'**
  String get unlockReason;

  /// No description provided for @periodReminderBody.
  ///
  /// In en, this message translates to:
  /// **'A new cycle may start in about two days.'**
  String get periodReminderBody;

  /// No description provided for @dailyReminderBody.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today? Take a moment to check in.'**
  String get dailyReminderBody;

  /// No description provided for @dbErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data can\'t be opened'**
  String get dbErrorTitle;

  /// No description provided for @dbErrorBody.
  ///
  /// In en, this message translates to:
  /// **'The encryption key on this phone is missing or has changed, so the existing data can\'t be read. You can start fresh; the unreadable data will be deleted.'**
  String get dbErrorBody;

  /// No description provided for @startFresh.
  ///
  /// In en, this message translates to:
  /// **'Delete and start fresh'**
  String get startFresh;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
