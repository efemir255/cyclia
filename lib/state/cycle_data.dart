import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dates.dart';
import '../domain/cycle_calendar.dart';
import '../domain/cycle_predictor.dart';
import '../domain/models.dart';
import 'providers.dart';

/// Everything the user has recorded, loaded from the encrypted database.
@immutable
class CycleData {
  const CycleData({
    required this.periods,
    required this.dayLogs,
    required this.profile,
  });

  /// Sorted by start date.
  final List<Period> periods;
  final Map<DateTime, DayLog> dayLogs;
  final HealthProfile profile;

  DayLog logFor(DateTime day) =>
      dayLogs[dateOnly(day)] ?? DayLog(day: dateOnly(day));

  CycleData copyWith({
    List<Period>? periods,
    Map<DateTime, DayLog>? dayLogs,
    HealthProfile? profile,
  }) => CycleData(
    periods: periods ?? this.periods,
    dayLogs: dayLogs ?? this.dayLogs,
    profile: profile ?? this.profile,
  );
}

/// Owns all health data. Every change is written to the repository and
/// reflected in state; derived values like the forecast recompute from it.
class CycleDataNotifier extends AsyncNotifier<CycleData> {
  @override
  Future<CycleData> build() async {
    final repo = ref.read(repositoryProvider);
    final (periods, logs, profile) = await (
      repo.getPeriods(),
      repo.getDayLogs(),
      repo.getProfile(),
    ).wait;
    return CycleData(
      periods: _sorted(periods),
      dayLogs: logs,
      profile: profile,
    );
  }

  CycleData get _data => state.requireValue;

  /// Records a period starting on [day]. Returns why it couldn't, if so.
  Future<StartPeriodError?> startPeriod(DateTime day) async {
    final (period, error) = PeriodEditor.startOn(
      _data.periods,
      day,
      periodLength: CyclePredictor.averagePeriodLength(
        _data.periods,
        _data.profile.periodLength,
      ),
      today: ref.read(todayProvider),
    );
    if (period == null) return error;
    final saved = await ref.read(repositoryProvider).addPeriod(period);
    state = AsyncData(
      _data.copyWith(periods: _sorted([..._data.periods, saved])),
    );
    return null;
  }

  Future<void> endPeriod(Period period, DateTime day) async {
    final updated = period.copyWith(end: () => dateOnly(day));
    await ref.read(repositoryProvider).updatePeriod(updated);
    state = AsyncData(
      _data.copyWith(
        periods: [
          for (final p in _data.periods)
            if (p.id == period.id) updated else p,
        ],
      ),
    );
  }

  Future<void> deletePeriod(int id) async {
    await ref.read(repositoryProvider).deletePeriod(id);
    state = AsyncData(
      _data.copyWith(periods: _data.periods.where((p) => p.id != id).toList()),
    );
  }

  Future<void> saveDayLog(DayLog log) async {
    await ref.read(repositoryProvider).saveDayLog(log);
    final logs = {..._data.dayLogs};
    if (log.isEmpty) {
      logs.remove(log.day);
    } else {
      logs[log.day] = log;
    }
    state = AsyncData(_data.copyWith(dayLogs: logs));
  }

  Future<void> saveProfile(HealthProfile profile) async {
    await ref.read(repositoryProvider).saveProfile(profile);
    state = AsyncData(_data.copyWith(profile: profile));
  }

  /// Saves the answers from onboarding.
  Future<void> completeOnboarding({
    required HealthProfile profile,
    DateTime? lastPeriodStart,
  }) async {
    await future; // Onboarding can finish before the first load completes.
    await saveProfile(profile);
    if (lastPeriodStart != null) await startPeriod(lastPeriodStart);
  }

  /// Permanently erases every record.
  Future<void> deleteAll() async {
    await ref.read(repositoryProvider).deleteAll();
    state = const AsyncData(
      CycleData(periods: [], dayLogs: {}, profile: HealthProfile()),
    );
  }

  static List<Period> _sorted(List<Period> periods) =>
      [...periods]..sort((a, b) => a.start.compareTo(b.start));
}

final cycleDataProvider = AsyncNotifierProvider<CycleDataNotifier, CycleData>(
  CycleDataNotifier.new,
);

final forecastProvider = Provider<CycleForecast?>((ref) {
  final data = ref.watch(cycleDataProvider).value;
  if (data == null) return null;
  return CyclePredictor.forecast(
    data.periods,
    profile: data.profile,
    today: ref.watch(todayProvider),
  );
});

final calendarProvider = Provider<CycleCalendar>((ref) {
  final data = ref.watch(cycleDataProvider).value;
  return CycleCalendar(
    periods: data?.periods ?? const [],
    forecast: ref.watch(forecastProvider),
    today: ref.watch(todayProvider),
  );
});
