import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// App preferences. None of these are health data, so they live in
/// SharedPreferences rather than the encrypted database.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.onboardingComplete = false,
    this.appLockEnabled = false,
    this.periodReminder = true,
    this.dailyReminder,
  });

  final ThemeMode themeMode;

  /// `null` follows the device language.
  final Locale? locale;
  final bool onboardingComplete;
  final bool appLockEnabled;

  /// Remind two days before the next predicted period.
  final bool periodReminder;

  /// Time of the daily check-in reminder, or `null` when off.
  final TimeOfDay? dailyReminder;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? Function()? locale,
    bool? onboardingComplete,
    bool? appLockEnabled,
    bool? periodReminder,
    TimeOfDay? Function()? dailyReminder,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    locale: locale != null ? locale() : this.locale,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    periodReminder: periodReminder ?? this.periodReminder,
    dailyReminder: dailyReminder != null ? dailyReminder() : this.dailyReminder,
  );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _theme = 'theme_mode';
  static const _locale = 'locale';
  static const _onboarding = 'onboarding_complete';
  static const _appLock = 'app_lock';
  static const _periodReminder = 'period_reminder';
  static const _dailyReminder = 'daily_reminder_minutes';

  @override
  AppSettings build() {
    final p = ref.read(sharedPreferencesProvider);
    final localeCode = p.getString(_locale);
    final dailyMinutes = p.getInt(_dailyReminder);
    return AppSettings(
      themeMode:
          ThemeMode.values.asNameMap()[p.getString(_theme)] ?? ThemeMode.system,
      locale: localeCode == null ? null : Locale(localeCode),
      onboardingComplete: p.getBool(_onboarding) ?? false,
      appLockEnabled: p.getBool(_appLock) ?? false,
      periodReminder: p.getBool(_periodReminder) ?? true,
      dailyReminder: dailyMinutes == null
          ? null
          : TimeOfDay(hour: dailyMinutes ~/ 60, minute: dailyMinutes % 60),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await ref.read(sharedPreferencesProvider).setString(_theme, mode.name);
  }

  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: () => locale);
    final p = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await p.remove(_locale);
    } else {
      await p.setString(_locale, locale.languageCode);
    }
  }

  Future<void> setOnboardingComplete(bool value) async {
    state = state.copyWith(onboardingComplete: value);
    await ref.read(sharedPreferencesProvider).setBool(_onboarding, value);
  }

  Future<void> setAppLock(bool enabled) async {
    state = state.copyWith(appLockEnabled: enabled);
    await ref.read(sharedPreferencesProvider).setBool(_appLock, enabled);
  }

  Future<void> setPeriodReminder(bool enabled) async {
    state = state.copyWith(periodReminder: enabled);
    await ref.read(sharedPreferencesProvider).setBool(_periodReminder, enabled);
  }

  Future<void> setDailyReminder(TimeOfDay? time) async {
    state = state.copyWith(dailyReminder: () => time);
    final p = ref.read(sharedPreferencesProvider);
    if (time == null) {
      await p.remove(_dailyReminder);
    } else {
      await p.setInt(_dailyReminder, time.hour * 60 + time.minute);
    }
  }

  /// Resets everything except appearance, used by "Delete all data".
  Future<void> resetAfterDataDeletion() async {
    state = AppSettings(themeMode: state.themeMode, locale: state.locale);
    final p = ref.read(sharedPreferencesProvider);
    for (final key in [
      _onboarding,
      _appLock,
      _periodReminder,
      _dailyReminder,
    ]) {
      await p.remove(key);
    }
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
