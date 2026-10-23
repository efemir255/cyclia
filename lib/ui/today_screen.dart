import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/guidance.dart';
import '../domain/cycle_calendar.dart';
import '../domain/cycle_predictor.dart';
import '../domain/models.dart';
import '../l10n/app_localizations.dart';
import '../state/cycle_data.dart';
import '../state/providers.dart';
import 'cycle_colors.dart';
import 'day_log_screen.dart';
import 'labels.dart';
import 'widgets/common.dart';
import 'widgets/cycle_ring.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(cycleDataProvider);
    final forecast = ref.watch(forecastProvider);
    final today = ref.watch(todayProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Text(
            longDate(context, today),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
      body: switch (data) {
        AsyncData(:final value) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (forecast == null)
              const _NoDataCard()
            else
              _StatusSection(forecast: forecast, periods: value.periods),
            const SizedBox(height: 16),
            _TodayLogCard(log: value.logFor(today)),
            if (forecast != null) ...[
              const SizedBox(height: 16),
              _PhaseCard(phase: forecast.phase),
              _ConditionNotes(
                phase: forecast.phase,
                conditions: value.profile.conditions,
              ),
            ],
          ],
        ),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// Starts a period today, showing why if it can't.
Future<void> startPeriodToday(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final error = await ref
      .read(cycleDataProvider.notifier)
      .startPeriod(ref.read(todayProvider));
  if (error != null) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (error) {
          StartPeriodError.inFuture => l10n.errorInFuture,
          StartPeriodError.insidePeriod => l10n.errorInsidePeriod,
        }),
      ),
    );
  }
}

class _NoDataCard extends ConsumerWidget {
  const _NoDataCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 56,
              color: CycleColors.of(context).period,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noDataTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(l10n.noDataBody, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => startPeriodToday(context, ref),
              icon: const Icon(Icons.water_drop),
              label: Text(l10n.periodStarted),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusSection extends ConsumerWidget {
  const _StatusSection({required this.forecast, required this.periods});

  final CycleForecast forecast;
  final List<Period> periods;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = CycleColors.of(context);
    final f = forecast;
    final ongoing = periods.isNotEmpty && periods.last.isOngoing && f.onPeriod;

    final headline = f.onPeriod
        ? l10n.periodDay(f.cycleDay)
        : f.isLate
        ? l10n.periodLate(f.daysLate)
        : l10n.periodIn(f.daysUntilNextPeriod);
    final detail = f.onPeriod && f.currentPeriodEnd != null
        ? l10n.periodExpectedEnd(shortDate(context, f.currentPeriodEnd!))
        : l10n.cycleDay(f.cycleDay);

    final upcomingFertile = f.fertileWindows.firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: CycleRing(
            forecast: f,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  headline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(detail, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Chip(
                  visualDensity: VisualDensity.compact,
                  side: BorderSide.none,
                  backgroundColor: colors
                      .phase(f.phase)
                      .withValues(alpha: 0.15),
                  label: Text(l10n.phaseLabel(f.phase)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (ongoing)
          FilledButton.tonalIcon(
            onPressed: () => ref
                .read(cycleDataProvider.notifier)
                .endPeriod(periods.last, ref.read(todayProvider)),
            icon: const Icon(Icons.check),
            label: Text(l10n.periodEnded),
          )
        else if (!f.onPeriod)
          FilledButton.icon(
            onPressed: () => startPeriodToday(context, ref),
            icon: const Icon(Icons.water_drop),
            label: Text(l10n.periodStarted),
          ),
        if (f.onPeriod)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              l10n.nextPeriodOn(shortDate(context, f.nextPeriodStart)),
              textAlign: TextAlign.center,
            ),
          ),
        if (f.isLate)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              l10n.lateHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (!f.onPeriod && !f.isLate && upcomingFertile != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco_outlined, size: 18, color: colors.fertile),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.fertileWindow(
                    shortDate(context, upcomingFertile.start),
                    shortDate(context, upcomingFertile.end),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            fertilityDisclaimer.of(Localizations.localeOf(context)),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _TodayLogCard extends ConsumerWidget {
  const _TodayLogCard({required this.log});

  final DayLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final chips = [
      if (log.flow != null) l10n.flowLabel(log.flow!),
      for (final s in log.symptoms) l10n.symptomLabel(s),
      for (final m in log.moods) l10n.moodLabel(m),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.todayLog, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (chips.isEmpty)
              Text(l10n.nothingLogged)
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in chips)
                    Chip(label: Text(c), visualDensity: VisualDensity.compact),
                ],
              ),
            if (log.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(log.note, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DayLogScreen(day: log.day),
                ),
              ),
              icon: const Icon(Icons.edit_note),
              label: Text(l10n.logSymptoms),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({required this.phase});

  final CyclePhase phase;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final guide = phaseGuides[phase]!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant_outlined,
                  color: CycleColors.of(context).phase(phase),
                ),
                const SizedBox(width: 8),
                Text(l10n.phaseTips, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(guide.summary.of(locale)),
            const SizedBox(height: 12),
            TipList(tips: guide.tips),
            Text(
              phaseEvidenceNote.of(locale),
              style: theme.textTheme.bodySmall,
            ),
            SourceList(sources: guide.sources),
          ],
        ),
      ),
    );
  }
}

class _ConditionNotes extends StatelessWidget {
  const _ConditionNotes({required this.phase, required this.conditions});

  final CyclePhase phase;
  final Set<Condition> conditions;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final notes = [
      for (final c in Condition.values)
        if (conditions.contains(c)) ?conditionGuides[c]!.phaseNotes[phase],
    ];
    if (notes.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(l10n.forYourConditions),
              for (final n in notes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(n.of(locale)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
