import 'package:flutter/foundation.dart';

import '../core/dates.dart';
import 'cycle_predictor.dart';
import 'models.dart';

enum PeriodMark { none, logged, predicted }

@immutable
class DayStatus {
  const DayStatus({
    this.period = PeriodMark.none,
    this.fertile = false,
    this.ovulation = false,
  });

  final PeriodMark period;
  final bool fertile;
  final bool ovulation;
}

/// Answers "what is this day?" for the calendar, combining logged periods
/// with the forecast.
class CycleCalendar {
  CycleCalendar({
    required List<Period> periods,
    required this.forecast,
    required DateTime today,
  }) : today = dateOnly(today),
       _periods = [...periods]..sort((a, b) => a.start.compareTo(b.start));

  final List<Period> _periods;
  final CycleForecast? forecast;
  final DateTime today;

  int get _periodLength => forecast?.averagePeriodLength ?? 5;

  /// The logged period covering [day], if any. Ongoing periods cover up to
  /// today; their expected remainder is reported as predicted instead.
  Period? loggedPeriodOn(DateTime day) {
    final d = dateOnly(day);
    for (final p in _periods) {
      if (d.isBefore(p.start)) break;
      if (!d.isAfter(effectiveEnd(p))) return p;
    }
    return null;
  }

  /// Last day a period counts as logged.
  DateTime effectiveEnd(Period p) {
    if (p.end != null) return p.end!;
    final stillRunning =
        p == _periods.last &&
        daysBetween(p.start, today) < CyclePredictor.ongoingCutoffDays;
    return stillRunning ? today : addDays(p.start, _periodLength - 1);
  }

  DayStatus statusOf(DateTime day) {
    final d = dateOnly(day);
    if (loggedPeriodOn(d) != null) {
      return const DayStatus(period: PeriodMark.logged);
    }

    final f = forecast;
    if (f == null || !d.isAfter(today)) return const DayStatus();

    final ongoingTail =
        f.onPeriod &&
        f.currentPeriodEnd != null &&
        !d.isAfter(f.currentPeriodEnd!);
    if (ongoingTail || f.predictedPeriods.any((r) => r.contains(d))) {
      return const DayStatus(period: PeriodMark.predicted);
    }
    final fertile = f.fertileWindows.any((w) => w.contains(d));
    final ovulation = f.fertileWindows.any(
      (w) => isSameDay(addDays(w.end, -1), d),
    );
    return DayStatus(fertile: fertile, ovulation: ovulation);
  }
}

enum StartPeriodError { inFuture, insidePeriod }

/// Pure rules for creating and closing periods from user actions.
abstract final class PeriodEditor {
  /// Builds the period to insert when the user says their period started on
  /// [day], or returns an error explaining why it can't start there.
  ///
  /// Recent starts stay open (ongoing) so the user can end them later.
  /// Starts further back get an assumed end of [periodLength] days, clipped
  /// so it never overlaps the following period.
  static (Period?, StartPeriodError?) startOn(
    List<Period> periods,
    DateTime day, {
    required int periodLength,
    required DateTime today,
  }) {
    final d = dateOnly(day);
    final t = dateOnly(today);
    if (d.isAfter(t)) return (null, StartPeriodError.inFuture);

    final calendar = CycleCalendar(periods: periods, forecast: null, today: t);
    if (calendar.loggedPeriodOn(d) != null) {
      return (null, StartPeriodError.insidePeriod);
    }

    final later = [...periods.where((p) => p.start.isAfter(d))]
      ..sort((a, b) => a.start.compareTo(b.start));
    final next = later.isEmpty ? null : later.first;
    final assumedEnd = addDays(d, periodLength - 1);

    if (next == null && !assumedEnd.isBefore(t)) {
      return (Period(start: d), null);
    }
    var end = minDate(assumedEnd, t);
    if (next != null && !end.isBefore(next.start)) {
      end = addDays(next.start, -1);
    }
    return (Period(start: d, end: end), null);
  }

  /// Whether [period] can be marked as ending on [day].
  static bool canEndOn(
    List<Period> periods,
    Period period,
    DateTime day, {
    required DateTime today,
  }) {
    final d = dateOnly(day);
    if (d.isBefore(period.start) || d.isAfter(dateOnly(today))) return false;
    return !periods.any(
      (p) =>
          p.id != period.id &&
          p.start.isAfter(period.start) &&
          !d.isBefore(p.start),
    );
  }
}
