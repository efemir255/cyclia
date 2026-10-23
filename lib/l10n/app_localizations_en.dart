// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cyclia';

  @override
  String get navToday => 'Today';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navHealth => 'Health';

  @override
  String get navSettings => 'Settings';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get sources => 'Sources';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Cyclia';

  @override
  String get onboardingWelcomeBody =>
      'Track your cycle, understand each phase, and get guidance that fits your health.';

  @override
  String get privacyLocal =>
      'Your data stays on this phone. No account, no cloud.';

  @override
  String get privacyEncrypted =>
      'Everything is stored in an encrypted database.';

  @override
  String get privacyNoDiagnosis =>
      'Cyclia never diagnoses. Its guidance is general information, not medical advice.';

  @override
  String get disclaimerAccept =>
      'I understand that Cyclia is not a medical device and its predictions must not be used as contraception.';

  @override
  String get lastPeriodTitle => 'When did your last period start?';

  @override
  String get lastPeriodUnknown => 'I don\'t remember';

  @override
  String get cycleTitle => 'Your usual cycle';

  @override
  String get cycleLength => 'Cycle length';

  @override
  String get periodLength => 'Period length';

  @override
  String get cycleLengthHint =>
      'From the first day of one period to the first day of the next. Not sure? Keep the defaults. Cyclia learns as you log.';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get conditionsTitle => 'Diagnosed conditions';

  @override
  String get conditionsBody =>
      'Optional. Choose any conditions a doctor has diagnosed and Cyclia will tailor its guidance. You can change this later.';

  @override
  String get finishOnboarding => 'Start using Cyclia';

  @override
  String get conditionPcos => 'PCOS / PMOS';

  @override
  String get conditionEndometriosis => 'Endometriosis';

  @override
  String get conditionIronDeficiencyAnemia => 'Iron deficiency anaemia';

  @override
  String get conditionHypothyroidism => 'Underactive thyroid';

  @override
  String get conditionInsulinResistance =>
      'Insulin resistance / type 2 diabetes';

  @override
  String get phaseMenstrual => 'Menstrual phase';

  @override
  String get phaseFollicular => 'Follicular phase';

  @override
  String get phaseOvulation => 'Ovulation';

  @override
  String get phaseLuteal => 'Luteal phase';

  @override
  String get noDataTitle => 'Log your period to see predictions';

  @override
  String get noDataBody =>
      'Tap the button below on the first day of your next period, or add a past one from the calendar.';

  @override
  String get periodStarted => 'My period started';

  @override
  String get periodEnded => 'My period ended';

  @override
  String periodDay(int day) {
    return 'Period day $day';
  }

  @override
  String periodExpectedEnd(String date) {
    return 'Expected to end $date';
  }

  @override
  String periodIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Period in $count days',
      one: 'Period tomorrow',
      zero: 'Period expected today',
    );
    return '$_temp0';
  }

  @override
  String periodLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Period $count days late',
      one: 'Period 1 day late',
    );
    return '$_temp0';
  }

  @override
  String get lateHint =>
      'Periods can be late because of stress, illness, weight changes and other reasons. If you could be pregnant, take a test, and talk to a doctor if you\'re worried.';

  @override
  String cycleDay(int day) {
    return 'Cycle day $day';
  }

  @override
  String nextPeriodOn(String date) {
    return 'Next period around $date';
  }

  @override
  String fertileWindow(String start, String end) {
    return 'Estimated fertile window: $start – $end';
  }

  @override
  String get todayLog => 'Today\'s log';

  @override
  String get logSymptoms => 'Log symptoms & mood';

  @override
  String get nothingLogged => 'Nothing logged yet today.';

  @override
  String get phaseTips => 'Tips for this phase';

  @override
  String get forYourConditions => 'For your conditions';

  @override
  String get errorInFuture => 'You can\'t log a period in the future.';

  @override
  String get errorInsidePeriod => 'A period is already logged on this day.';

  @override
  String get flow => 'Flow';

  @override
  String get flowSpotting => 'Spotting';

  @override
  String get flowLight => 'Light';

  @override
  String get flowMedium => 'Medium';

  @override
  String get flowHeavy => 'Heavy';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get symptomCramps => 'Cramps';

  @override
  String get symptomHeadache => 'Headache';

  @override
  String get symptomBloating => 'Bloating';

  @override
  String get symptomBackPain => 'Back pain';

  @override
  String get symptomBreastTenderness => 'Tender breasts';

  @override
  String get symptomAcne => 'Acne';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomNausea => 'Nausea';

  @override
  String get symptomCravings => 'Cravings';

  @override
  String get symptomInsomnia => 'Poor sleep';

  @override
  String get mood => 'Mood';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodCalm => 'Calm';

  @override
  String get moodEnergetic => 'Energetic';

  @override
  String get moodSensitive => 'Sensitive';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodIrritable => 'Irritable';

  @override
  String get note => 'Note';

  @override
  String get period => 'Period';

  @override
  String get startPeriodHere => 'Period started this day';

  @override
  String get endPeriodHere => 'Period ended this day';

  @override
  String get deletePeriod => 'Delete this period';

  @override
  String get deletePeriodTitle => 'Delete this period?';

  @override
  String deletePeriodBody(String start) {
    return 'The period from $start will be removed. Your symptom logs are kept.';
  }

  @override
  String loggedPeriodRange(String start, String end) {
    return 'Logged period: $start – $end';
  }

  @override
  String ongoingPeriodFrom(String start) {
    return 'Ongoing period since $start';
  }

  @override
  String get legendPeriod => 'Period';

  @override
  String get legendPredicted => 'Predicted';

  @override
  String get legendFertile => 'Fertile';

  @override
  String get legendOvulation => 'Ovulation';

  @override
  String get today => 'Today';

  @override
  String get yourCycle => 'Your cycle';

  @override
  String get averageCycle => 'Average cycle';

  @override
  String get averagePeriod => 'Average period';

  @override
  String get cyclesLogged => 'Cycles logged';

  @override
  String get recentCycles => 'Recent cycle lengths';

  @override
  String get notEnoughCycles =>
      'Log at least two periods to see your cycle history.';

  @override
  String get commonSymptoms => 'Most logged symptoms (last 90 days)';

  @override
  String get noSymptoms => 'No symptoms logged in the last 90 days.';

  @override
  String get myConditions => 'My conditions';

  @override
  String get noConditions =>
      'No conditions added. Adding conditions a doctor has diagnosed lets Cyclia tailor its guidance.';

  @override
  String get dietTips => 'Food & diet';

  @override
  String get lifestyleTips => 'Lifestyle';

  @override
  String get cyclePhases => 'Your cycle phases';

  @override
  String get disclaimerShort =>
      'Cyclia offers general information, not medical advice. Talk to a doctor about your health.';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get privacySecurity => 'Privacy & security';

  @override
  String get appLock => 'App lock';

  @override
  String get appLockSubtitle =>
      'Require your fingerprint, face or device PIN to open Cyclia';

  @override
  String get appLockUnavailable =>
      'Set up a screen lock on your device to use app lock.';

  @override
  String get reminders => 'Reminders';

  @override
  String get periodReminder => 'Upcoming period';

  @override
  String get periodReminderSubtitle =>
      'Two days before your next predicted period';

  @override
  String get dailyReminder => 'Daily check-in';

  @override
  String get off => 'Off';

  @override
  String get notificationsDenied =>
      'Notifications are turned off for Cyclia. Turn them on in your phone\'s settings to get reminders.';

  @override
  String get cycleDefaults => 'Cycle defaults';

  @override
  String get cycleDefaultsHint =>
      'Used until you\'ve logged enough cycles for personal averages.';

  @override
  String get about => 'About';

  @override
  String get aboutBody =>
      'Cyclia is an open-source project. Your data never leaves this device.';

  @override
  String get disclaimerFull =>
      'Cyclia provides general information and is not a medical device. It does not replace professional medical advice, diagnosis or treatment. Cycle and fertility predictions are estimates and must not be used as contraception.';

  @override
  String get deleteAllData => 'Delete all data';

  @override
  String get deleteAllTitle => 'Delete all data?';

  @override
  String get deleteAllBody =>
      'This permanently erases every period, log and condition from this phone. It can\'t be undone.';

  @override
  String get deleteAllConfirm => 'Delete everything';

  @override
  String get lockedTitle => 'Cyclia is locked';

  @override
  String get unlock => 'Unlock';

  @override
  String get unlockReason => 'Unlock Cyclia to see your health data';

  @override
  String get periodReminderBody => 'A new cycle may start in about two days.';

  @override
  String get dailyReminderBody =>
      'How are you feeling today? Take a moment to check in.';

  @override
  String get dbErrorTitle => 'Your data can\'t be opened';

  @override
  String get dbErrorBody =>
      'The encryption key on this phone is missing or has changed, so the existing data can\'t be read. You can start fresh; the unreadable data will be deleted.';

  @override
  String get startFresh => 'Delete and start fresh';
}
