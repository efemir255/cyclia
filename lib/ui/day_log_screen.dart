import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cycle_calendar.dart';
import '../domain/models.dart';
import '../l10n/app_localizations.dart';
import '../state/cycle_data.dart';
import '../state/providers.dart';
import 'cycle_colors.dart';
import 'labels.dart';
import 'widgets/common.dart';

/// Period actions and the symptom/mood/flow log for a single day.
class DayLogScreen extends ConsumerStatefulWidget {
  const DayLogScreen({super.key, required this.day});

  final DateTime day;

  @override
  ConsumerState<DayLogScreen> createState() => _DayLogScreenState();
}

class _DayLogScreenState extends ConsumerState<DayLogScreen> {
  late DayLog _log = ref
      .read(cycleDataProvider)
      .requireValue
      .logFor(widget.day);
  late final _note = TextEditingController(text: _log.note);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    await ref
        .read(cycleDataProvider.notifier)
        .saveDayLog(_log.copyWith(note: _note.text));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayProvider);
    final isFuture = widget.day.isAfter(today);

    return Scaffold(
      appBar: AppBar(title: Text(longDate(context, widget.day))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!isFuture) ...[
            _PeriodSection(day: widget.day),
            const Divider(height: 32),
          ],
          SectionTitle(l10n.flow),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in FlowLevel.values)
                ChoiceChip(
                  label: Text(l10n.flowLabel(f)),
                  selected: _log.flow == f,
                  onSelected: (on) => setState(
                    () => _log = _log.copyWith(flow: () => on ? f : null),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SectionTitle(l10n.symptoms),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in Symptom.values)
                FilterChip(
                  label: Text(l10n.symptomLabel(s)),
                  selected: _log.symptoms.contains(s),
                  onSelected: (on) => setState(
                    () => _log = _log.copyWith(
                      symptoms: on
                          ? {..._log.symptoms, s}
                          : ({..._log.symptoms}..remove(s)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SectionTitle(l10n.mood),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in Mood.values)
                FilterChip(
                  label: Text(l10n.moodLabel(m)),
                  selected: _log.moods.contains(m),
                  onSelected: (on) => setState(
                    () => _log = _log.copyWith(
                      moods: on
                          ? {..._log.moods, m}
                          : ({..._log.moods}..remove(m)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(labelText: l10n.note),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(onPressed: _save, child: Text(l10n.save)),
        ),
      ),
    );
  }
}

/// Start, end or delete the period on this day. Changes apply immediately.
class _PeriodSection extends ConsumerWidget {
  const _PeriodSection({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final calendar = ref.watch(calendarProvider);
    final periods = ref.watch(cycleDataProvider).value?.periods ?? const [];
    final today = ref.watch(todayProvider);
    final notifier = ref.read(cycleDataProvider.notifier);
    final period = calendar.loggedPeriodOn(day);
    final color = CycleColors.of(context).period;

    if (period == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(l10n.period),
          FilledButton.tonalIcon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final error = await notifier.startPeriod(day);
              if (error == StartPeriodError.insidePeriod) {
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.errorInsidePeriod)),
                );
              }
            },
            icon: Icon(Icons.water_drop, color: color),
            label: Text(l10n.startPeriodHere),
          ),
        ],
      );
    }

    final end = calendar.effectiveEnd(period);
    final canEnd =
        PeriodEditor.canEndOn(periods, period, day, today: today) &&
        !(period.end != null && day == period.end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(l10n.period),
        Row(
          children: [
            Icon(Icons.water_drop, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                period.isOngoing && end == today
                    ? l10n.ongoingPeriodFrom(shortDate(context, period.start))
                    : l10n.loggedPeriodRange(
                        shortDate(context, period.start),
                        shortDate(context, end),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (canEnd)
          OutlinedButton.icon(
            onPressed: () => notifier.endPeriod(period, day),
            icon: const Icon(Icons.check),
            label: Text(l10n.endPeriodHere),
          ),
        TextButton.icon(
          onPressed: () => _confirmDelete(context, ref, period),
          icon: const Icon(Icons.delete_outline),
          label: Text(l10n.deletePeriod),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Period period,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePeriodTitle),
        content: Text(l10n.deletePeriodBody(shortDate(context, period.start))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(cycleDataProvider.notifier).deletePeriod(period.id!);
    }
  }
}
