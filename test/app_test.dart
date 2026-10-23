import 'package:cyclia/domain/models.dart';
import 'package:cyclia/services/reminder_scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  testWidgets('onboarding saves the last period and conditions', (
    tester,
  ) async {
    final repo = InMemoryRepository();
    await pumpCyclia(tester, repository: repo, onboarded: false);

    expect(find.text('Welcome to Cyclia'), findsOneWidget);
    // The disclaimer must be accepted before continuing.
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Next'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Last period: March 1st.
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Keep the default cycle.
    expect(find.text('28 days'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Iron deficiency anaemia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start using Cyclia'));
    await tester.pumpAndSettle();

    expect(find.text('Period in 9 days'), findsOneWidget);
    expect(repo.profile.conditions, {Condition.ironDeficiencyAnemia});
    final period = repo.periods.values.single;
    expect(period.start, DateTime(2026, 3, 1));
    expect(period.end, DateTime(2026, 3, 5));
  });

  testWidgets('starting and ending a period from Today', (tester) async {
    await pumpCyclia(tester);
    expect(find.text('Log your period to see predictions'), findsOneWidget);

    await tester.tap(find.text('My period started'));
    await tester.pumpAndSettle();
    expect(find.text('Period day 1'), findsOneWidget);

    await tester.tap(find.text('My period ended'));
    await tester.pumpAndSettle();
    expect(find.text('My period ended'), findsNothing);
    // Still on the period today, which was its last day.
    expect(find.text('Period day 1'), findsOneWidget);
  });

  testWidgets('logging symptoms and mood for today', (tester) async {
    final repo = InMemoryRepository(
      periods: [Period(start: DateTime(2026, 3, 1), end: DateTime(2026, 3, 5))],
    );
    await pumpCyclia(tester, repository: repo);
    expect(find.text('Nothing logged yet today.'), findsOneWidget);

    await tester.tap(find.text('Log symptoms & mood'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cramps'));
    await tester.tap(find.text('Happy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(Chip, 'Cramps'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'Happy'), findsOneWidget);
    expect(repo.logs[testToday]!.symptoms, {Symptom.cramps});
  });

  testWidgets('condition notes appear in the matching phase', (tester) async {
    final repo = InMemoryRepository(
      periods: [Period(start: DateTime(2026, 3, 18))],
      profile: const HealthProfile(
        conditions: {Condition.ironDeficiencyAnemia},
      ),
    );
    await pumpCyclia(tester, repository: repo);

    expect(find.text('Menstrual phase'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('For your conditions'), 200);
    expect(find.textContaining('With iron deficiency anaemia'), findsOneWidget);
  });

  testWidgets('a reminder is scheduled two days before the next period', (
    tester,
  ) async {
    final reminders = FakeReminderScheduler();
    final repo = InMemoryRepository(
      periods: [Period(start: DateTime(2026, 3, 1), end: DateTime(2026, 3, 5))],
    );
    await pumpCyclia(tester, repository: repo, reminders: reminders);

    expect(
      reminders.once[ReminderIds.upcomingPeriod],
      DateTime(2026, 3, 27, 9),
    );
  });

  testWidgets('app lock hides data until unlocked', (tester) async {
    final locker = FakeAppLocker(succeeds: false);
    await pumpCyclia(tester, locker: locker, appLock: true);

    expect(find.text('Cyclia is locked'), findsOneWidget);
    expect(find.text('Log your period to see predictions'), findsNothing);
    expect(locker.prompts, 1);

    locker.succeeds = true;
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.text('Log your period to see predictions'), findsOneWidget);
  });

  testWidgets('switching the language to Turkish', (tester) async {
    await pumpCyclia(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();

    expect(find.text('Ayarlar'), findsWidgets);
    expect(find.text('Takvim'), findsOneWidget);
  });

  testWidgets('deleting all data returns to onboarding', (tester) async {
    final repo = InMemoryRepository(
      periods: [Period(start: DateTime(2026, 3, 1), end: DateTime(2026, 3, 5))],
    );
    await pumpCyclia(tester, repository: repo);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Delete all data'), 200);
    await tester.tap(find.text('Delete all data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete everything'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Cyclia'), findsOneWidget);
    expect(repo.periods, isEmpty);
  });
}
