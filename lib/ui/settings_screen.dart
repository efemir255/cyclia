import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models.dart';
import '../l10n/app_localizations.dart';
import '../state/cycle_data.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import 'conditions_screen.dart';
import 'labels.dart';
import 'widgets/common.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Language names are shown in their own language, as is conventional.
  static const _languages = {'en': 'English', 'tr': 'Türkçe'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final profile =
        ref.watch(cycleDataProvider).value?.profile ?? const HealthProfile();
    final daily = settings.dailyReminder;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SectionTitle(l10n.appearance),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.brightness_auto),
                label: Text(l10n.themeSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: const Icon(Icons.light_mode),
                label: Text(l10n.themeLight),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: const Icon(Icons.dark_mode),
                label: Text(l10n.themeDark),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => notifier.setThemeMode(s.single),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: '', label: Text(l10n.languageSystem)),
              for (final MapEntry(:key, :value) in _languages.entries)
                ButtonSegment(value: key, label: Text(value)),
            ],
            selected: {settings.locale?.languageCode ?? ''},
            onSelectionChanged: (s) =>
                notifier.setLocale(s.single.isEmpty ? null : Locale(s.single)),
          ),
          const SizedBox(height: 16),
          SectionTitle(l10n.privacySecurity),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.fingerprint),
            title: Text(l10n.appLock),
            subtitle: Text(l10n.appLockSubtitle),
            value: settings.appLockEnabled,
            onChanged: (on) => _setAppLock(context, ref, on),
          ),
          const SizedBox(height: 8),
          SectionTitle(l10n.reminders),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l10n.periodReminder),
            subtitle: Text(l10n.periodReminderSubtitle),
            value: settings.periodReminder,
            onChanged: (on) async {
              if (on && !await _ensurePermission(context, ref)) return;
              await notifier.setPeriodReminder(on);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.edit_calendar_outlined),
            title: Text(l10n.dailyReminder),
            subtitle: Text(daily == null ? l10n.off : daily.format(context)),
            value: daily != null,
            onChanged: (on) => _setDailyReminder(context, ref, on),
          ),
          const SizedBox(height: 8),
          SectionTitle(l10n.cycleDefaults),
          DayStepper(
            label: l10n.cycleLength,
            value: profile.cycleLength,
            min: HealthProfile.minCycleLength,
            max: HealthProfile.maxCycleLength,
            onChanged: (v) => ref
                .read(cycleDataProvider.notifier)
                .saveProfile(profile.copyWith(cycleLength: v)),
          ),
          const SizedBox(height: 8),
          DayStepper(
            label: l10n.periodLength,
            value: profile.periodLength,
            min: HealthProfile.minPeriodLength,
            max: HealthProfile.maxPeriodLength,
            onChanged: (v) => ref
                .read(cycleDataProvider.notifier)
                .saveProfile(profile.copyWith(periodLength: v)),
          ),
          const SizedBox(height: 8),
          Text(l10n.cycleDefaultsHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.medical_information_outlined),
            title: Text(l10n.conditionsTitle),
            subtitle: Text(
              profile.conditions.isEmpty
                  ? l10n.off
                  : profile.conditions.map(l10n.conditionLabel).join(', '),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ConditionsScreen()),
            ),
          ),
          const SizedBox(height: 8),
          SectionTitle(l10n.about),
          Text(l10n.aboutBody),
          const SizedBox(height: 8),
          Text(l10n.disclaimerFull, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text('github.com/efemir255/cyclia', style: theme.textTheme.bodySmall),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: () => _confirmDeleteAll(context, ref),
            icon: const Icon(Icons.delete_forever_outlined),
            label: Text(l10n.deleteAllData),
          ),
        ],
      ),
    );
  }

  Future<void> _setAppLock(BuildContext context, WidgetRef ref, bool on) async {
    final notifier = ref.read(settingsProvider.notifier);
    if (!on) return notifier.setAppLock(false);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final locker = ref.read(appLockerProvider);
    if (!await locker.isAvailable()) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.appLockUnavailable)));
      return;
    }
    // Confirm the user can actually unlock before turning the lock on.
    if (await locker.authenticate(l10n.unlockReason)) {
      await notifier.setAppLock(true);
    }
  }

  Future<bool> _ensurePermission(BuildContext context, WidgetRef ref) async {
    final message = AppLocalizations.of(context).notificationsDenied;
    final messenger = ScaffoldMessenger.of(context);
    final granted = await ref
        .read(reminderSchedulerProvider)
        .requestPermission();
    if (!granted) messenger.showSnackBar(SnackBar(content: Text(message)));
    return granted;
  }

  Future<void> _setDailyReminder(
    BuildContext context,
    WidgetRef ref,
    bool on,
  ) async {
    final notifier = ref.read(settingsProvider.notifier);
    if (!on) return notifier.setDailyReminder(null);
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
    );
    if (time == null || !context.mounted) return;
    if (!await _ensurePermission(context, ref)) return;
    await notifier.setDailyReminder(time);
  }

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAllTitle),
        content: Text(l10n.deleteAllBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteAllConfirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(cycleDataProvider.notifier).deleteAll();
    // Returning to onboarding also cancels reminders via the sync provider.
    await ref.read(settingsProvider.notifier).resetAfterDataDeletion();
  }
}
