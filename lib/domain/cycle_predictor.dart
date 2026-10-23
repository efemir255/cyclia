import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/dates.dart';
import 'models.dart';

enum CyclePhase { menstrual, follicular, ovulation, luteal }

/// Where the user is in their cycle today, and what comes next.
@immutable
class CycleForecast {
  const CycleForecast({
    required this.today,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.lastPeriodStart,
    required this.cycleDay,
    required this.phase,
    required this.onPeriod,
    required this.currentPeriodEnd,
    required this.nextPeriodStart,
    required this.daysLate,
    required this.nextOvulation,
    required this.predictedPeriods,
    required this.fertileWindows,
  });

  final DateTime today;
  final int averageCycleLength;
  final int averagePeriodLength;
  final DateTime lastPeriodStart;

  /// 1 on the first day of the most recent period.
  final int cycleDay;
  final CyclePhase phase;
  final bool onPeriod;

  /// Logged or expected last day of the current period, when [onPeriod].
  final DateTime? currentPeriodEnd;

  /// Expected start of the next period. When the period is late this is
  /// today, since it could start any day now.
  final DateTime nextPeriodStart;

  /// Days past the expected start, or 0 when not late.
  final int daysLate;

  /// The next estimated ovulation day on or after today.
  final DateTime nextOvulation;

  /// Upcoming predicted periods, soonest first.
  final List<DayRange> predictedPeriods;

  /// Current and upcoming estimated fertile windows, soonest first.
  final List<DayRange> fertileWindows;

  int get daysUntilNextPeriod => daysBetween(today, nextPeriodStart);

  bool get isLate => daysLate > 0;
}

/// Period prediction using the calendar method: averages of the user's
/// recent cycles, with ovulation estimated 14 days before the next period.
///
/// This is the standard approach used by most cycle apps. It is an estimate
/// and must never be presented as contraception.
abstract final class CyclePredictor {
  /// How many recent cycles feed the averages.
  static const historyWindow = 6;

  /// The luteal phase is fairly constant at about 14 days, so ovulation is
  /// counted back from the next expected period.
  static const lutealPhaseLength = 14;

  /// An ongoing period older than this is assumed to have ended (the user
  /// most likely forgot to log the end).
  static const ongoingCutoffDays = 14;

  /// How many future cycles to predict.
  static const cyclesAhead = 3;

  /// Lengths of complete cycles (start to next start), oldest first.
  static List<int> cycleLengths(List<Period> periods) {
    final sorted = _sorted(periods);
    return [
      for (var i = 1; i < sorted.length; i++)
        daysBetween(sorted[i - 1].start, sorted[i].start),
    ];
  }

  /// Average of the recent plausible cycle lengths, or [fallback] when there
  /// are none. Implausible gaps (usually a period that wasn't logged) are
  /// ignored rather than skewing the average.
  static int averageCycleLength(List<Period> periods, int fallback) {
    final plausible = cycleLengths(periods)
        .where(
          (l) =>
              l >= HealthProfile.minCycleLength &&
              l <= HealthProfile.maxCycleLength,
        )
        .toList();
    return _recentAverage(plausible) ?? fallback;
  }

  /// Average length of recent completed periods, or [fallback].
  static int averagePeriodLength(List<Period> periods, int fallback) {
    final lengths = [
      for (final p in _sorted(periods))
        if (p.end != null) daysBetween(p.start, p.end!) + 1,
    ].where((l) => l <= HealthProfile.maxPeriodLength).toList();
    return _recentAverage(lengths) ?? fallback;
  }

  static CycleForecast? forecast(
    List<Period> periods, {
    required HealthProfile profile,
    required DateTime today,
  }) {
    final t = dateOnly(today);
    final past = _sorted(periods).where((p) => !p.start.isAfter(t)).toList();
    if (past.isEmpty) return null;

    final cycle = averageCycleLength(past, profile.cycleLength);
    final periodLength = averagePeriodLength(past, profile.periodLength);
    final last = past.last;
    final cycleDay = daysBetween(last.start, t) + 1;

    final expectedEnd = addDays(last.start, periodLength - 1);
    final ongoing = last.isOngoing && cycleDay <= ongoingCutoffDays;
    final lastEnd = last.end ?? expectedEnd;
    final onPeriod = ongoing || !t.isAfter(lastEnd);
    final currentPeriodEnd = !onPeriod
        ? null
        : ongoing
        ? maxDate(expectedEnd, t)
        : lastEnd;

    final due = addDays(last.start, cycle);
    final daysLate = !onPeriod && t.isAfter(due) ? daysBetween(due, t) : 0;
    final nextStart = daysLate > 0 ? t : due;

    final predictedPeriods = [
      for (var k = 0; k < cyclesAhead; k++)
        DayRange(
          addDays(nextStart, k * cycle),
          addDays(nextStart, k * cycle + periodLength - 1),
        ),
    ];

    // Ovulation of each cycle sits 14 days before the period that ends it.
    final ovulations = [
      for (final p in predictedPeriods) addDays(p.start, -lutealPhaseLength),
    ];
    final fertileWindows = [
      for (final ov in ovulations)
        if (!addDays(ov, 1).isBefore(t)) fertileWindowFor(ov),
    ];
    final nextOvulation = ovulations.firstWhere(
      (ov) => !ov.isBefore(t),
      orElse: () => ovulations.last,
    );

    return CycleForecast(
      today: t,
      averageCycleLength: cycle,
      averagePeriodLength: periodLength,
      lastPeriodStart: last.start,
      cycleDay: cycleDay,
      phase: _phase(
        t,
        onPeriod: onPeriod,
        isLate: daysLate > 0,
        ovulation: ovulations.first,
      ),
      onPeriod: onPeriod,
      currentPeriodEnd: currentPeriodEnd,
      nextPeriodStart: nextStart,
      daysLate: daysLate,
      nextOvulation: nextOvulation,
      predictedPeriods: predictedPeriods,
      fertileWindows: fertileWindows,
    );
  }

  /// The ~6 days in which pregnancy is possible: the 5 days before
  /// ovulation, ovulation day, and the day after.
  static DayRange fertileWindowFor(DateTime ovulation) =>
      DayRange(addDays(ovulation, -5), addDays(ovulation, 1));

  static CyclePhase _phase(
    DateTime today, {
    required bool onPeriod,
    required bool isLate,
    required DateTime ovulation,
  }) {
    if (onPeriod) return CyclePhase.menstrual;
    if (isLate) return CyclePhase.luteal;
    final fromOvulation = daysBetween(ovulation, today);
    if (fromOvulation < -1) return CyclePhase.follicular;
    if (fromOvulation <= 1) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }

  static int? _recentAverage(List<int> values) {
    if (values.isEmpty) return null;
    final recent = values.length > historyWindow
        ? values.sublist(values.length - historyWindow)
        : values;
    final sum = recent.reduce((a, b) => a + b);
    return math.max(1, (sum / recent.length).round());
  }

  static List<Period> _sorted(List<Period> periods) =>
      [...periods]..sort((a, b) => a.start.compareTo(b.start));
}
