import 'package:cyclia/data/cyclia_repository.dart';
import 'package:cyclia/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Runs the real schema and queries against an in-memory SQLite database.
/// (Encryption itself is provided by SQLCipher on devices.)
void main() {
  sqfliteFfiInit();
  late SqlCycliaRepository repo;

  setUp(() async {
    final db = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: SqlCycliaRepository.schemaVersion,
        onCreate: SqlCycliaRepository.createSchema,
      ),
    );
    repo = SqlCycliaRepository(db);
  });

  tearDown(() => repo.close());

  group('periods', () {
    test('are saved with ids and returned sorted by start', () async {
      await repo.addPeriod(
        Period(start: DateTime(2026, 3, 1), end: DateTime(2026, 3, 5)),
      );
      final earlier = await repo.addPeriod(Period(start: DateTime(2026, 2, 1)));

      final periods = await repo.getPeriods();
      expect(earlier.id, isNotNull);
      expect(periods.map((p) => p.start), [
        DateTime(2026, 2, 1),
        DateTime(2026, 3, 1),
      ]);
      expect(periods.first.isOngoing, isTrue);
      expect(periods.last.end, DateTime(2026, 3, 5));
    });

    test('can be ended and deleted', () async {
      final p = await repo.addPeriod(Period(start: DateTime(2026, 3, 1)));
      await repo.updatePeriod(p.copyWith(end: () => DateTime(2026, 3, 4)));
      expect((await repo.getPeriods()).single.end, DateTime(2026, 3, 4));

      await repo.deletePeriod(p.id!);
      expect(await repo.getPeriods(), isEmpty);
    });
  });

  group('day logs', () {
    final day = DateTime(2026, 3, 2);

    test('round-trip every field', () async {
      await repo.saveDayLog(
        DayLog(
          day: day,
          flow: FlowLevel.heavy,
          symptoms: {Symptom.cramps, Symptom.backPain},
          moods: {Mood.sensitive},
          note: '  rested a lot  ',
        ),
      );
      final log = (await repo.getDayLogs())[day]!;
      expect(log.flow, FlowLevel.heavy);
      expect(log.symptoms, {Symptom.cramps, Symptom.backPain});
      expect(log.moods, {Mood.sensitive});
      expect(log.note, 'rested a lot');
    });

    test('overwrite the same day', () async {
      await repo.saveDayLog(DayLog(day: day, flow: FlowLevel.light));
      await repo.saveDayLog(DayLog(day: day, moods: {Mood.happy}));
      final log = (await repo.getDayLogs())[day]!;
      expect(log.flow, isNull);
      expect(log.moods, {Mood.happy});
    });

    test('are removed when saved empty', () async {
      await repo.saveDayLog(DayLog(day: day, flow: FlowLevel.light));
      await repo.saveDayLog(DayLog(day: day));
      expect(await repo.getDayLogs(), isEmpty);
    });
  });

  group('profile', () {
    test('defaults when nothing is saved', () async {
      final profile = await repo.getProfile();
      expect(profile.cycleLength, HealthProfile.defaultCycleLength);
      expect(profile.conditions, isEmpty);
    });

    test('round-trips lengths and conditions', () async {
      await repo.saveProfile(
        const HealthProfile(
          cycleLength: 31,
          periodLength: 6,
          conditions: {Condition.pcos, Condition.hypothyroidism},
        ),
      );
      final profile = await repo.getProfile();
      expect(profile.cycleLength, 31);
      expect(profile.periodLength, 6);
      expect(profile.conditions, {Condition.pcos, Condition.hypothyroidism});
    });
  });

  test('deleteAll erases everything', () async {
    await repo.addPeriod(Period(start: DateTime(2026, 3, 1)));
    await repo.saveDayLog(
      DayLog(day: DateTime(2026, 3, 1), flow: FlowLevel.medium),
    );
    await repo.saveProfile(const HealthProfile(conditions: {Condition.pcos}));

    await repo.deleteAll();

    expect(await repo.getPeriods(), isEmpty);
    expect(await repo.getDayLogs(), isEmpty);
    expect((await repo.getProfile()).conditions, isEmpty);
  });
}
