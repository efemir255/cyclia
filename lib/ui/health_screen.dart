import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/guidance.dart';
import '../core/dates.dart';
import '../domain/cycle_predictor.dart';
import '../domain/models.dart';
import '../l10n/app_localizations.dart';
import '../state/cycle_data.dart';
import '../state/providers.dart';
import 'conditions_screen.dart';
import 'cycle_colors.dart';
import 'labels.dart';
import 'widgets/common.dart';

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(cycleDataProvider).value;
    final forecast = ref.watch(forecastProvider);
    final today = ref.watch(todayProvider);
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navHealth)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _CycleStatsCard(periods: data.periods, forecast: forecast),
          const SizedBox(height: 16),
          _SymptomsCard(logs: data.dayLogs, today: today),
          const SizedBox(height: 16),
          _ConditionsSection(conditions: data.profile.conditions),
          const SizedBox(height: 16),
          const _PhaseGuideCard(),
          const SizedBox(height: 16),
          Text(
            l10n.disclaimerShort,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CycleStatsCard extends StatelessWidget {
  const _CycleStatsCard({required this.periods, required this.forecast});

  final List<Period> periods;
  final CycleForecast? forecast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lengths = CyclePredictor.cycleLengths(periods);
    final recent = lengths.length > 6
        ? lengths.sublist(lengths.length - 6)
        : lengths;
    final f = forecast;

    Widget stat(String label, String value) => Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(l10n.yourCycle),
            Row(
              children: [
                stat(
                  l10n.averageCycle,
                  f == null ? '–' : l10n.daysCount(f.averageCycleLength),
                ),
                stat(
                  l10n.averagePeriod,
                  f == null ? '–' : l10n.daysCount(f.averagePeriodLength),
                ),
                stat(l10n.cyclesLogged, '${lengths.length}'),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.recentCycles, style: theme.textTheme.labelLarge),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              Text(l10n.notEnoughCycles)
            else
              _CycleLengthChart(lengths: recent),
          ],
        ),
      ),
    );
  }
}

class _CycleLengthChart extends StatelessWidget {
  const _CycleLengthChart({required this.lengths});

  final List<int> lengths;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = CycleColors.of(context).period;
    final maxY = (lengths.reduce(math.max) + 5).toDouble();
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            bottomTitles: const AxisTitles(),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${lengths[value.toInt()]}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < lengths.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: lengths[i].toDouble(),
                    width: 22,
                    color: i == lengths.length - 1
                        ? color
                        : color.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: scheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SymptomsCard extends StatelessWidget {
  const _SymptomsCard({required this.logs, required this.today});

  final Map<DateTime, DayLog> logs;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final since = addDays(today, -90);
    final counts = <Symptom, int>{};
    for (final log in logs.values) {
      if (log.day.isBefore(since)) continue;
      for (final s in log.symptoms) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
    }
    final top = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(l10n.commonSymptoms),
            if (top.isEmpty)
              Text(l10n.noSymptoms)
            else
              for (final e in top.take(5))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(l10n.symptomLabel(e.key))),
                      Text(l10n.daysCount(e.value)),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _ConditionsSection extends StatelessWidget {
  const _ConditionsSection({required this.conditions});

  final Set<Condition> conditions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: SectionTitle(l10n.myConditions)),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ConditionsScreen(),
                    ),
                  ),
                  child: Text(l10n.edit),
                ),
              ],
            ),
            if (conditions.isEmpty) Text(l10n.noConditions),
            for (final c in Condition.values)
              if (conditions.contains(c))
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: Text(l10n.conditionLabel(c)),
                  subtitle: Text(
                    conditionGuides[c]!.summary.of(locale),
                    style: theme.textTheme.bodySmall,
                  ),
                  children: [
                    Text(l10n.dietTips, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TipList(tips: conditionGuides[c]!.diet),
                    const SizedBox(height: 8),
                    Text(l10n.lifestyleTips, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TipList(
                      tips: conditionGuides[c]!.lifestyle,
                      sources: conditionGuides[c]!.sources,
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}

class _PhaseGuideCard extends StatelessWidget {
  const _PhaseGuideCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final colors = CycleColors.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(l10n.cyclePhases),
            for (final p in CyclePhase.values)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                leading: Icon(Icons.circle, size: 14, color: colors.phase(p)),
                title: Text(l10n.phaseLabel(p)),
                children: [
                  Text(phaseGuides[p]!.summary.of(locale)),
                  const SizedBox(height: 8),
                  TipList(
                    tips: phaseGuides[p]!.tips,
                    sources: phaseGuides[p]!.sources,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
