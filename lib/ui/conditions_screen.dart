import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../state/cycle_data.dart';
import 'widgets/common.dart';

class ConditionsScreen extends ConsumerStatefulWidget {
  const ConditionsScreen({super.key});

  @override
  ConsumerState<ConditionsScreen> createState() => _ConditionsScreenState();
}

class _ConditionsScreenState extends ConsumerState<ConditionsScreen> {
  late var _selected = ref
      .read(cycleDataProvider)
      .requireValue
      .profile
      .conditions;

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final notifier = ref.read(cycleDataProvider.notifier);
    final profile = ref.read(cycleDataProvider).requireValue.profile;
    await notifier.saveProfile(profile.copyWith(conditions: _selected));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.conditionsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.conditionsBody),
          const SizedBox(height: 8),
          ConditionsPicker(
            selected: _selected,
            onChanged: (s) => setState(() => _selected = s),
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
