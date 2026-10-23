/// Calendar-day helpers.
///
/// Cycles are tracked per local calendar day, so every date that enters the
/// domain is normalised to midnight. Days are stepped with the [DateTime]
/// constructor rather than `Duration(days: 1)` so daylight-saving shifts never
/// skip or repeat a day.
library;

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Whole calendar days from [from] to [to]; negative when [to] is earlier.
int daysBetween(DateTime from, DateTime to) {
  // UTC avoids the 23/25-hour days around daylight-saving changes.
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

DateTime maxDate(DateTime a, DateTime b) => a.isAfter(b) ? a : b;

DateTime minDate(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

/// Storage key in `yyyy-MM-dd` form, which also sorts chronologically.
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime parseDayKey(String key) {
  final parts = key.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

/// An inclusive range of calendar days.
class DayRange {
  DayRange(DateTime start, DateTime end)
    : start = dateOnly(start),
      end = dateOnly(end),
      assert(!dateOnly(end).isBefore(dateOnly(start)));

  final DateTime start;
  final DateTime end;

  int get lengthInDays => daysBetween(start, end) + 1;

  bool contains(DateTime day) {
    final d = dateOnly(day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  @override
  bool operator ==(Object other) =>
      other is DayRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DayRange(${dayKey(start)} – ${dayKey(end)})';
}
