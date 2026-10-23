import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../content/guidance.dart';
import '../../domain/models.dart';
import '../../l10n/app_localizations.dart';
import '../labels.dart';

/// A bulleted list of tips with a collapsible list of sources.
class TipList extends StatelessWidget {
  const TipList({super.key, required this.tips, this.sources = const []});

  final List<LocalizedText> tips;
  final List<Source> sources;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final tip in tips)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7, right: 10),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Expanded(child: Text(tip.of(locale))),
              ],
            ),
          ),
        if (sources.isNotEmpty) SourceList(sources: sources),
      ],
    );
  }
}

class SourceList extends StatelessWidget {
  const SourceList({super.key, required this.sources});

  final List<Source> sources;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        dense: true,
        leading: const Icon(Icons.menu_book_outlined, size: 18),
        title: Text(l10n.sources, style: theme.textTheme.labelLarge),
        children: [
          for (final s in sources)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(s.title),
              subtitle: Text(s.url),
              // Tapping copies the link: Cyclia has no internet permission
              // of its own, so it never opens pages itself.
              trailing: const Icon(Icons.copy, size: 18),
              onTap: () => Clipboard.setData(ClipboardData(text: s.url)),
            ),
        ],
      ),
    );
  }
}

/// Section heading used throughout the app.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

/// A minus/value/plus control for a whole number of days.
class DayStepper extends StatelessWidget {
  const DayStepper({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton.filledTonal(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 72,
          child: Text(
            l10n.daysCount(value),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton.filledTonal(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

/// Checkbox list of diagnosable conditions.
class ConditionsPicker extends StatelessWidget {
  const ConditionsPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Set<Condition> selected;
  final ValueChanged<Set<Condition>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        for (final c in Condition.values)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.conditionLabel(c)),
            value: selected.contains(c),
            onChanged: (on) => onChanged(
              on == true ? {...selected, c} : ({...selected}..remove(c)),
            ),
          ),
      ],
    );
  }
}
