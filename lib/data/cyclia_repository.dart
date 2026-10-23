import 'package:sqflite_common/sqlite_api.dart';

import '../core/dates.dart';
import '../domain/models.dart';

/// Persistence boundary for all health data, so the state and UI layers
/// never depend on SQLite directly and tests can use an in-memory fake.
abstract interface class CycliaRepository {
  Future<List<Period>> getPeriods();

  /// Saves a new period and returns it with its generated id.
  Future<Period> addPeriod(Period period);

  Future<void> updatePeriod(Period period);

  Future<void> deletePeriod(int id);

  Future<Map<DateTime, DayLog>> getDayLogs();

  /// Saves [log], or removes the day's entry when the log is empty.
  Future<void> saveDayLog(DayLog log);

  Future<HealthProfile> getProfile();

  Future<void> saveProfile(HealthProfile profile);

  /// Permanently erases every record.
  Future<void> deleteAll();
}

class SqlCycliaRepository implements CycliaRepository {
  SqlCycliaRepository(this._db);

  final Database _db;

  static const schemaVersion = 1;

  static Future<void> createSchema(Database db, int version) async {
    final batch = db.batch()
      ..execute('''
        CREATE TABLE periods (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          start_day TEXT NOT NULL,
          end_day TEXT
        )''')
      ..execute('''
        CREATE TABLE day_logs (
          day TEXT PRIMARY KEY,
          flow TEXT,
          symptoms TEXT NOT NULL,
          moods TEXT NOT NULL,
          note TEXT NOT NULL
        )''')
      ..execute('''
        CREATE TABLE profile (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )''');
    await batch.commit(noResult: true);
  }

  // Periods

  @override
  Future<List<Period>> getPeriods() async {
    final rows = await _db.query('periods', orderBy: 'start_day');
    return [
      for (final r in rows)
        Period(
          id: r['id'] as int,
          start: parseDayKey(r['start_day'] as String),
          end: r['end_day'] == null
              ? null
              : parseDayKey(r['end_day'] as String),
        ),
    ];
  }

  @override
  Future<Period> addPeriod(Period period) async {
    final id = await _db.insert('periods', _periodRow(period));
    return period.copyWith(id: id);
  }

  @override
  Future<void> updatePeriod(Period period) => _db.update(
    'periods',
    _periodRow(period),
    where: 'id = ?',
    whereArgs: [period.id],
  );

  @override
  Future<void> deletePeriod(int id) =>
      _db.delete('periods', where: 'id = ?', whereArgs: [id]);

  Map<String, Object?> _periodRow(Period p) => {
    'start_day': dayKey(p.start),
    'end_day': p.end == null ? null : dayKey(p.end!),
  };

  // Day logs. Enums are stored by name so reordering them is safe.

  @override
  Future<Map<DateTime, DayLog>> getDayLogs() async {
    final rows = await _db.query('day_logs');
    final logs = <DateTime, DayLog>{};
    for (final r in rows) {
      final day = parseDayKey(r['day'] as String);
      logs[day] = DayLog(
        day: day,
        flow: FlowLevel.values.asNameMap()[r['flow']],
        symptoms: _decode(r['symptoms'] as String, Symptom.values),
        moods: _decode(r['moods'] as String, Mood.values),
        note: r['note'] as String,
      );
    }
    return logs;
  }

  @override
  Future<void> saveDayLog(DayLog log) async {
    if (log.isEmpty) {
      await _db.delete(
        'day_logs',
        where: 'day = ?',
        whereArgs: [dayKey(log.day)],
      );
      return;
    }
    await _db.insert('day_logs', {
      'day': dayKey(log.day),
      'flow': log.flow?.name,
      'symptoms': _encode(log.symptoms),
      'moods': _encode(log.moods),
      'note': log.note.trim(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Profile, stored as key/value pairs so new fields need no migration.

  @override
  Future<HealthProfile> getProfile() async {
    final rows = await _db.query('profile');
    final values = {
      for (final r in rows) r['key'] as String: r['value'] as String,
    };
    const defaults = HealthProfile();
    return HealthProfile(
      cycleLength:
          int.tryParse(values['cycle_length'] ?? '') ?? defaults.cycleLength,
      periodLength:
          int.tryParse(values['period_length'] ?? '') ?? defaults.periodLength,
      conditions: _decode(values['conditions'] ?? '', Condition.values),
    );
  }

  @override
  Future<void> saveProfile(HealthProfile profile) async {
    final batch = _db.batch();
    for (final MapEntry(:key, :value) in {
      'cycle_length': '${profile.cycleLength}',
      'period_length': '${profile.periodLength}',
      'conditions': _encode(profile.conditions),
    }.entries) {
      batch.insert('profile', {
        'key': key,
        'value': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteAll() async {
    final batch = _db.batch()
      ..delete('periods')
      ..delete('day_logs')
      ..delete('profile');
    await batch.commit(noResult: true);
  }

  Future<void> close() => _db.close();

  static String _encode(Set<Enum> values) =>
      values.map((v) => v.name).join(',');

  static Set<T> _decode<T extends Enum>(String raw, List<T> all) {
    final byName = all.asNameMap();
    return {for (final name in raw.split(',')) ?byName[name]};
  }
}
