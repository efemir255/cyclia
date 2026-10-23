import 'package:cyclia/domain/cycle_calendar.dart';
import 'package:cyclia/domain/cycle_predictor.dart';
import 'package:cyclia/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 3, 20);
  DateTime mar(int d) => DateTime(2026, 3, d);
  DateTime apr(int d) => DateTime(2026, 4, d);

  CycleCalendar calendarFor(List<Period> periods) => CycleCalendar(
    periods: periods,
    forecast: CyclePredictor.forecast(
      periods,
      profile: const HealthProfile(),
      today: today,
    ),
    today: today,
  );

  group('CycleCalendar', () {
    test('marks logged period days', () {
      final cal = calendarFor([Period(id: 1, start: mar(1), end: mar(5))]);
      expect(cal.statusOf(mar(1)).period, PeriodMark.logged);
      expect(cal.statusOf(mar(5)).period, PeriodMark.logged);
      expect(cal.statusOf(mar(6)).period, PeriodMark.none);
    });

    test('marks predicted periods after today', () {
      final cal = calendarFor([Period(id: 1, start: mar(1), end: mar(5))]);
      expect(cal.statusOf(mar(29)).period, PeriodMark.predicted);
      expect(cal.statusOf(apr(2)).period, PeriodMark.predicted);
      expect(cal.statusOf(apr(3)).period, PeriodMark.none);
    });

    test('an ongoing period is logged up to today and predicted after', () {
      final cal = calendarFor([Period(id: 1, start: mar(18))]);
      expect(cal.statusOf(mar(20)).period, PeriodMark.logged);
      expect(cal.statusOf(mar(21)).period, PeriodMark.predicted);
      expect(cal.statusOf(mar(22)).period, PeriodMark.predicted);
      expect(cal.statusOf(mar(23)).period, PeriodMark.none);
    });

    test('marks the fertile window and ovulation day', () {
      final cal = calendarFor([Period(id: 1, start: mar(1), end: mar(5))]);
      // Next-but-one period Apr 26, so ovulation is estimated on Apr 12.
      expect(cal.statusOf(apr(7)).fertile, isTrue);
      expect(cal.statusOf(apr(13)).fertile, isTrue);
      expect(cal.statusOf(apr(14)).fertile, isFalse);
      expect(cal.statusOf(apr(12)).ovulation, isTrue);
      expect(cal.statusOf(apr(11)).ovulation, isFalse);
    });

    test('never predicts on past days', () {
      final cal = calendarFor([Period(id: 1, start: mar(1), end: mar(5))]);
      expect(cal.statusOf(mar(15)).fertile, isFalse);
    });
  });

  group('PeriodEditor.startOn', () {
    (Period?, StartPeriodError?) start(List<Period> periods, DateTime day) =>
        PeriodEditor.startOn(periods, day, periodLength: 5, today: today);

    test('rejects future days', () {
      expect(start([], mar(21)).$2, StartPeriodError.inFuture);
    });

    test('rejects days inside a logged period', () {
      final existing = [Period(id: 1, start: mar(1), end: mar(5))];
      expect(start(existing, mar(3)).$2, StartPeriodError.insidePeriod);
    });

    test('keeps a recent start open so it can be ended later', () {
      final (period, error) = start([], mar(18));
      expect(error, isNull);
      expect(period!.isOngoing, isTrue);
    });

    test('gives an older start an assumed end', () {
      final (period, _) = start([], mar(2));
      expect(period!.end, mar(6));
    });

    test('clips the assumed end before the next period', () {
      final (period, _) = start([
        Period(id: 1, start: mar(5), end: mar(8)),
      ], mar(2));
      expect(period!.end, mar(4));
    });
  });

  group('PeriodEditor.canEndOn', () {
    final first = Period(id: 1, start: mar(1));
    final second = Period(id: 2, start: mar(10), end: mar(12));
    final periods = [first, second];

    test('allows days from the start up to today', () {
      expect(
        PeriodEditor.canEndOn(periods, first, mar(4), today: today),
        isTrue,
      );
      expect(
        PeriodEditor.canEndOn(periods, first, mar(1), today: today),
        isTrue,
      );
    });

    test('rejects days before the start or in the future', () {
      expect(
        PeriodEditor.canEndOn(
          [first],
          first,
          DateTime(2026, 2, 28),
          today: today,
        ),
        isFalse,
      );
      expect(
        PeriodEditor.canEndOn([second], second, mar(21), today: today),
        isFalse,
      );
    });

    test('rejects ends that would overlap the next period', () {
      expect(
        PeriodEditor.canEndOn(periods, first, mar(10), today: today),
        isFalse,
      );
    });
  });
}
