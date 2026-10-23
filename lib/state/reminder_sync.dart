import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dates.dart';
import '../domain/cycle_predictor.dart';
import '../l10n/app_localizations.dart';
import '../services/reminder_scheduler.dart';
import 'cycle_data.dart';
import 'providers.dart';
import 'settings.dart';

/// Keeps scheduled notifications in line with the forecast and settings.
///
/// Watched by the app root, so it re-runs whenever the forecast, the
/// reminder settings or the language change.
final reminderSyncProvider = Provider<void>((ref) {
  final scheduler = ref.watch(reminderSchedulerProvider);
  final settings = ref.watch(settingsProvider);
  final forecast = ref.watch(forecastProvider);
  final l10n = lookupAppLocalizations(resolveAppLocale(settings.locale));
  // Before onboarding (including right after "Delete all data") there must
  // be no reminders at all.
  final effective = settings.onboardingComplete
      ? settings
      : const AppSettings(periodReminder: false);
  unawaited(
    _sync(scheduler, effective, forecast, l10n).catchError((Object e) {
      // A failed reminder must never break the app.
      debugPrint('Reminder sync failed: $e');
    }),
  );
});

Future<void> _sync(
  ReminderScheduler scheduler,
  AppSettings settings,
  CycleForecast? forecast,
  AppLocalizations l10n,
) async {
  if (settings.periodReminder && forecast != null && !forecast.onPeriod) {
    final day = addDays(forecast.nextPeriodStart, -2);
    await scheduler.scheduleOnce(
      id: ReminderIds.upcomingPeriod,
      at: DateTime(day.year, day.month, day.day, 9),
      title: l10n.appTitle,
      body: l10n.periodReminderBody,
    );
  } else {
    await scheduler.cancel(ReminderIds.upcomingPeriod);
  }

  final daily = settings.dailyReminder;
  if (daily != null) {
    await scheduler.scheduleDaily(
      id: ReminderIds.dailyCheckIn,
      time: daily,
      title: l10n.appTitle,
      body: l10n.dailyReminderBody,
    );
  } else {
    await scheduler.cancel(ReminderIds.dailyCheckIn);
  }
}

/// The chosen locale, or the device locale when supported, else English.
Locale resolveAppLocale(Locale? chosen) {
  final candidate = chosen ?? PlatformDispatcher.instance.locale;
  final supported = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == candidate.languageCode,
  );
  return supported ? Locale(candidate.languageCode) : const Locale('en');
}
