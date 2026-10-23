import 'package:cyclia/app.dart';
import 'package:cyclia/data/cyclia_repository.dart';
import 'package:cyclia/domain/models.dart';
import 'package:cyclia/services/app_locker.dart';
import 'package:cyclia/services/reminder_scheduler.dart';
import 'package:cyclia/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InMemoryRepository implements CycliaRepository {
  InMemoryRepository({List<Period> periods = const [], HealthProfile? profile})
    : profile = profile ?? const HealthProfile() {
    for (final p in periods) {
      final saved = p.copyWith(id: _nextId++);
      this.periods[saved.id!] = saved;
    }
  }

  final periods = <int, Period>{};
  final logs = <DateTime, DayLog>{};
  HealthProfile profile;
  var _nextId = 1;

  @override
  Future<List<Period>> getPeriods() async =>
      periods.values.toList()..sort((a, b) => a.start.compareTo(b.start));

  @override
  Future<Period> addPeriod(Period period) async {
    final saved = period.copyWith(id: _nextId++);
    periods[saved.id!] = saved;
    return saved;
  }

  @override
  Future<void> updatePeriod(Period period) async =>
      periods[period.id!] = period;

  @override
  Future<void> deletePeriod(int id) async => periods.remove(id);

  @override
  Future<Map<DateTime, DayLog>> getDayLogs() async => {...logs};

  @override
  Future<void> saveDayLog(DayLog log) async =>
      log.isEmpty ? logs.remove(log.day) : logs[log.day] = log;

  @override
  Future<HealthProfile> getProfile() async => profile;

  @override
  Future<void> saveProfile(HealthProfile profile) async =>
      this.profile = profile;

  @override
  Future<void> deleteAll() async {
    periods.clear();
    logs.clear();
    profile = const HealthProfile();
  }
}

class FakeReminderScheduler implements ReminderScheduler {
  final once = <int, DateTime>{};
  final daily = <int, TimeOfDay>{};

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleOnce({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async => once[id] = at;

  @override
  Future<void> scheduleDaily({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async => daily[id] = time;

  @override
  Future<void> cancel(int id) async {
    once.remove(id);
    daily.remove(id);
  }
}

class FakeAppLocker implements AppLocker {
  FakeAppLocker({this.succeeds = true});

  bool succeeds;
  var prompts = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return succeeds;
  }
}

final testToday = DateTime(2026, 3, 20);

/// Pumps the full app wired to in-memory fakes, on a phone-sized screen.
Future<void> pumpCyclia(
  WidgetTester tester, {
  CycliaRepository? repository,
  ReminderScheduler? reminders,
  AppLocker? locker,
  bool onboarded = true,
  bool appLock = false,
  DateTime? today,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    'locale': 'en',
    'onboarding_complete': onboarded,
    'app_lock': appLock,
  });
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        repositoryProvider.overrideWithValue(
          repository ?? InMemoryRepository(),
        ),
        reminderSchedulerProvider.overrideWithValue(
          reminders ?? FakeReminderScheduler(),
        ),
        appLockerProvider.overrideWithValue(locker ?? FakeAppLocker()),
        todayProvider.overrideWithValue(today ?? testToday),
      ],
      child: const CycliaApp(),
    ),
  );
  await tester.pumpAndSettle();
}
