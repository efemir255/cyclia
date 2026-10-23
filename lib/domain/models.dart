import 'package:flutter/foundation.dart';

import '../core/dates.dart';

/// One logged period. [end] is `null` while the period is still ongoing.
@immutable
class Period {
  Period({this.id, required DateTime start, DateTime? end})
    : start = dateOnly(start),
      end = end == null ? null : dateOnly(end),
      assert(end == null || !dateOnly(end).isBefore(dateOnly(start)));

  /// Database row id; `null` until saved.
  final int? id;
  final DateTime start;
  final DateTime? end;

  bool get isOngoing => end == null;

  Period copyWith({int? id, DateTime? start, DateTime? Function()? end}) =>
      Period(
        id: id ?? this.id,
        start: start ?? this.start,
        end: end != null ? end() : this.end,
      );

  @override
  bool operator ==(Object other) =>
      other is Period &&
      other.id == id &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(id, start, end);

  @override
  String toString() =>
      'Period($id, ${dayKey(start)} – ${end == null ? 'ongoing' : dayKey(end!)})';
}

enum FlowLevel { spotting, light, medium, heavy }

enum Symptom {
  cramps,
  headache,
  bloating,
  backPain,
  breastTenderness,
  acne,
  fatigue,
  nausea,
  cravings,
  insomnia,
}

enum Mood { happy, calm, energetic, sensitive, sad, anxious, irritable }

/// Everything the user noted about a single day.
@immutable
class DayLog {
  DayLog({
    required DateTime day,
    this.flow,
    this.symptoms = const {},
    this.moods = const {},
    this.note = '',
  }) : day = dateOnly(day);

  final DateTime day;
  final FlowLevel? flow;
  final Set<Symptom> symptoms;
  final Set<Mood> moods;
  final String note;

  bool get isEmpty =>
      flow == null && symptoms.isEmpty && moods.isEmpty && note.trim().isEmpty;

  DayLog copyWith({
    FlowLevel? Function()? flow,
    Set<Symptom>? symptoms,
    Set<Mood>? moods,
    String? note,
  }) => DayLog(
    day: day,
    flow: flow != null ? flow() : this.flow,
    symptoms: symptoms ?? this.symptoms,
    moods: moods ?? this.moods,
    note: note ?? this.note,
  );
}

/// Conditions a doctor has diagnosed. Cyclia never diagnoses; the user picks
/// these so guidance can be adapted.
enum Condition {
  pcos,
  endometriosis,
  ironDeficiencyAnemia,
  hypothyroidism,
  insulinResistance,
}

/// The user's cycle defaults and diagnosed conditions.
///
/// The lengths are only used until enough cycles have been logged to compute
/// personal averages.
@immutable
class HealthProfile {
  const HealthProfile({
    this.cycleLength = defaultCycleLength,
    this.periodLength = defaultPeriodLength,
    this.conditions = const {},
  });

  static const defaultCycleLength = 28;
  static const defaultPeriodLength = 5;
  static const minCycleLength = 18;
  static const maxCycleLength = 60;
  static const minPeriodLength = 1;
  static const maxPeriodLength = 12;

  final int cycleLength;
  final int periodLength;
  final Set<Condition> conditions;

  HealthProfile copyWith({
    int? cycleLength,
    int? periodLength,
    Set<Condition>? conditions,
  }) => HealthProfile(
    cycleLength: cycleLength ?? this.cycleLength,
    periodLength: periodLength ?? this.periodLength,
    conditions: conditions ?? this.conditions,
  );
}
