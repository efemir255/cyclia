import 'package:cyclia/core/dates.dart';
import 'package:cyclia/domain/cycle_predictor.dart';
import 'package:cyclia/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 3, 20);
  const profile = HealthProfile();

  Period p(int month, int day, [int? endMonth, int? endDay]) => Period(
    start: DateTime(2026, month, day),
    end: endDay == null ? null : DateTime(2026, endMonth!, endDay),
  );

  CycleForecast forecast(
    List<Period> periods, {
    DateTime? on,
    HealthProfile? with_,
  }) => CyclePredictor.forecast(
    periods,
    profile: with_ ?? profile,
    today: on ?? today,
  )!;

  test('returns null without any periods', () {
    expect(CyclePredictor.forecast([], profile: profile, today: today), isNull);
  });

  test('ignores periods that start in the future', () {
    expect(
      CyclePredictor.forecast(
        [p(3, 25, 3, 29)],
        profile: profile,
        today: today,
      ),
      isNull,
    );
  });

  group('with a single logged period', () {
    late CycleForecast f;
    setUp(() => f = forecast([p(3, 1, 3, 5)]));

    test('uses profile defaults for the cycle length', () {
      expect(f.averageCycleLength, 28);
      expect(f.averagePeriodLength, 5);
    });

    test('counts the cycle day from the period start', () {
      expect(f.cycleDay, 20);
      expect(f.onPeriod, isFalse);
    });

    test('predicts the next period one cycle after the last start', () {
      expect(f.nextPeriodStart, DateTime(2026, 3, 29));
      expect(f.daysUntilNextPeriod, 9);
      expect(
        f.predictedPeriods.first,
        DayRange(DateTime(2026, 3, 29), DateTime(2026, 4, 2)),
      );
    });

    test('predicts three cycles ahead, one cycle apart', () {
      expect(f.predictedPeriods.map((r) => r.start), [
        DateTime(2026, 3, 29),
        DateTime(2026, 4, 26),
        DateTime(2026, 5, 24),
      ]);
    });

    test('estimates ovulation 14 days before the next period', () {
      // This cycle's ovulation (Mar 15) has passed, so the next is April's.
      expect(f.nextOvulation, DateTime(2026, 4, 12));
      expect(f.phase, CyclePhase.luteal);
    });

    test('drops fertile windows that are already over', () {
      expect(
        f.fertileWindows.first,
        DayRange(DateTime(2026, 4, 7), DateTime(2026, 4, 13)),
      );
    });
  });

  group('averages', () {
    test('average recent cycle lengths', () {
      final f = forecast([p(1, 1, 1, 5), p(1, 29, 2, 2), p(2, 28, 3, 3)]);
      expect(CyclePredictor.cycleLengths([p(1, 1), p(1, 29), p(2, 28)]), [
        28,
        30,
      ]);
      expect(f.averageCycleLength, 29);
    });

    test('skip implausible gaps such as an unlogged period', () {
      final periods = [
        Period(start: DateTime(2025, 10, 1), end: DateTime(2025, 10, 5)),
        p(1, 1, 1, 5), // 92 days later: ignored
        p(1, 29, 2, 2), // 28 days later
      ];
      final f = forecast(periods, with_: const HealthProfile(cycleLength: 35));
      expect(f.averageCycleLength, 28);
    });

    test('only use the most recent six cycles', () {
      var start = DateTime(2025, 1, 1);
      final periods = <Period>[];
      for (final gap in [40, 40, 28, 28, 28, 28, 28, 28]) {
        periods.add(Period(start: start, end: addDays(start, 4)));
        start = addDays(start, gap);
      }
      periods.add(Period(start: start, end: addDays(start, 4)));
      expect(CyclePredictor.averageCycleLength(periods, 30), 28);
    });

    test('average period length comes from completed periods', () {
      final f = forecast([
        p(1, 1, 1, 3),
        p(1, 29, 2, 2),
        p(2, 26),
      ], on: DateTime(2026, 2, 27));
      // 3 and 5 days; the ongoing period is not counted.
      expect(f.averagePeriodLength, 4);
    });
  });

  group('during a period', () {
    test('an ongoing period counts as on period', () {
      final f = forecast([p(3, 18)]);
      expect(f.onPeriod, isTrue);
      expect(f.cycleDay, 3);
      expect(f.phase, CyclePhase.menstrual);
      expect(f.currentPeriodEnd, DateTime(2026, 3, 22));
    });

    test('an ongoing period lasting longer than expected ends no earlier than today', () {
      final f = forecast([p(3, 13)]);
      expect(f.currentPeriodEnd, today);
    });

    test('a long-forgotten ongoing period is treated as over', () {
      final f = forecast([p(3, 1)]);
      expect(f.onPeriod, isFalse);
    });

    test('a completed period counts until its last day', () {
      expect(forecast([p(3, 16, 3, 20)]).onPeriod, isTrue);
      expect(forecast([p(3, 15, 3, 19)]).onPeriod, isFalse);
    });
  });

  group('late period', () {
    late CycleForecast f;
    setUp(() => f = forecast([p(2, 10, 2, 14)]));

    test('reports days late', () {
      expect(f.isLate, isTrue);
      expect(f.daysLate, 10);
    });

    test('expects the period today and predicts from there', () {
      expect(f.nextPeriodStart, today);
      expect(f.daysUntilNextPeriod, 0);
      expect(f.phase, CyclePhase.luteal);
    });
  });

  group('phases across a cycle', () {
    final periods = [p(3, 10, 3, 14)];
    // Next period Apr 7, so ovulation is estimated on Mar 24.
    CyclePhase on(int day) =>
        forecast(periods, on: DateTime(2026, 3, day)).phase;

    test('follows menstrual, follicular, ovulation and luteal', () {
      expect(on(12), CyclePhase.menstrual);
      expect(on(15), CyclePhase.follicular);
      expect(on(22), CyclePhase.follicular);
      expect(on(23), CyclePhase.ovulation);
      expect(on(24), CyclePhase.ovulation);
      expect(on(25), CyclePhase.ovulation);
      expect(on(26), CyclePhase.luteal);
    });
  });

  test('fertile window spans five days before ovulation to one after', () {
    final w = CyclePredictor.fertileWindowFor(DateTime(2026, 3, 24));
    expect(w, DayRange(DateTime(2026, 3, 19), DateTime(2026, 3, 25)));
    expect(w.lengthInDays, 7);
  });

  test('daysBetween is not affected by daylight-saving changes', () {
    // Clocks change in Europe on the last Sunday of March.
    expect(daysBetween(DateTime(2026, 3, 28), DateTime(2026, 3, 30)), 2);
    expect(daysBetween(DateTime(2026, 10, 24), DateTime(2026, 10, 26)), 2);
  });
}
