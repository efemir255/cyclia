import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/dates.dart';
import '../domain/cycle_calendar.dart';
import '../l10n/app_localizations.dart';
import '../state/cycle_data.dart';
import '../state/providers.dart';
import 'cycle_colors.dart';
import 'day_log_screen.dart';

/// Month calendar of logged and predicted periods and fertile windows.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  /// Months before the current one that can be browsed.
  static const _monthsBack = 24;
  static const _monthsAhead = 6;

  final _pages = PageController(initialPage: _monthsBack);
  var _page = _monthsBack;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  DateTime _monthFor(int page, DateTime today) =>
      DateTime(today.year, today.month + page - _monthsBack);

  void _go(int delta) => _pages.animateToPage(
    _page + delta,
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final month = _monthFor(_page, today);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCalendar),
        actions: [
          if (_page != _monthsBack)
            TextButton(
              onPressed: () => _go(_monthsBack - _page),
              child: Text(l10n.today),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: _page > 0 ? () => _go(-1) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    DateFormat.yMMMM(locale).format(month),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: _page < _monthsBack + _monthsAhead
                      ? () => _go(1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const _WeekdayHeader(),
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: _monthsBack + _monthsAhead + 1,
              onPageChanged: (p) => setState(() => _page = p),
              itemBuilder: (context, page) =>
                  _MonthGrid(month: _monthFor(page, today)),
            ),
          ),
          const _Legend(),
        ],
      ),
    );
  }
}

int _firstWeekday(BuildContext context) {
  // MaterialLocalizations: 0 = Sunday. DateTime.weekday: 7 = Sunday.
  final index = MaterialLocalizations.of(context).firstDayOfWeekIndex;
  return index == 0 ? DateTime.sunday : index;
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final first = _firstWeekday(context);
    final names = MaterialLocalizations.of(context).narrowWeekdays;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Text(
                names[(first + i) % 7],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthGrid extends ConsumerWidget {
  const _MonthGrid({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendar = ref.watch(calendarProvider);
    final logs = ref.watch(cycleDataProvider).value?.dayLogs ?? const {};
    final today = ref.watch(todayProvider);
    final first = _firstWeekday(context);
    final leading = (month.weekday - first + 7) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final rows = ((leading + daysInMonth) / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          for (var r = 0; r < rows; r++)
            Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final dayNumber = r * 7 + c - leading + 1;
                        if (dayNumber < 1 || dayNumber > daysInMonth) {
                          return const AspectRatio(aspectRatio: 1);
                        }
                        final day = DateTime(
                          month.year,
                          month.month,
                          dayNumber,
                        );
                        return _DayCell(
                          day: day,
                          status: calendar.statusOf(day),
                          isToday: isSameDay(day, today),
                          hasLog: logs.containsKey(day),
                        );
                      },
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.status,
    required this.isToday,
    required this.hasLog,
  });

  final DateTime day;
  final DayStatus status;
  final bool isToday;
  final bool hasLog;

  @override
  Widget build(BuildContext context) {
    final colors = CycleColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final logged = status.period == PeriodMark.logged;
    final predicted = status.period == PeriodMark.predicted;

    final Color? fill = logged
        ? colors.period
        : status.fertile
        ? colors.fertile.withValues(alpha: 0.18)
        : null;
    final textColor = logged ? Colors.white : scheme.onSurface;

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => DayLogScreen(day: day)),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fill,
              border: predicted
                  ? Border.all(color: colors.period, width: 2)
                  : isToday
                  ? Border.all(color: scheme.onSurface, width: 2)
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isToday ? FontWeight.bold : null,
                  ),
                ),
                if (status.ovulation || hasLog)
                  Positioned(
                    bottom: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (status.ovulation) _Dot(color: colors.fertile),
                        if (hasLog)
                          _Dot(color: logged ? Colors.white : scheme.outline),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 5,
    height: 5,
    margin: const EdgeInsets.symmetric(horizontal: 1),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = CycleColors.of(context);
    Widget item(Widget swatch, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [swatch, const SizedBox(width: 6), Text(label)],
    );
    Widget circle({Color? fill, Color? border}) => Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: border == null ? null : Border.all(color: border, width: 2),
      ),
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            item(circle(fill: colors.period), l10n.legendPeriod),
            item(circle(border: colors.period), l10n.legendPredicted),
            item(
              circle(fill: colors.fertile.withValues(alpha: 0.25)),
              l10n.legendFertile,
            ),
            item(_Dot(color: colors.fertile), l10n.legendOvulation),
          ],
        ),
      ),
    );
  }
}
