import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dates.dart';
import '../domain/models.dart';
import '../l10n/app_localizations.dart';
import '../state/cycle_data.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import 'widgets/common.dart';

/// First-launch flow: privacy and disclaimer, last period, usual cycle,
/// and optional diagnosed conditions.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pageCount = 4;

  final _pages = PageController();
  var _page = 0;
  var _accepted = false;
  DateTime? _lastPeriod;
  var _unknownLastPeriod = false;
  var _profile = const HealthProfile();
  var _saving = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  bool get _canContinue => switch (_page) {
    0 => _accepted,
    1 => _lastPeriod != null || _unknownLastPeriod,
    _ => true,
  };

  Future<void> _next() async {
    if (_page < _pageCount - 1) {
      await _pages.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }
    setState(() => _saving = true);
    await ref
        .read(cycleDataProvider.notifier)
        .completeOnboarding(
          profile: _profile,
          lastPeriodStart: _unknownLastPeriod ? null : _lastPeriod,
        );
    await ref.read(settingsProvider.notifier).setOnboardingComplete(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLast = _page == _pageCount - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: LinearProgressIndicator(
                value: (_page + 1) / _pageCount,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  _WelcomePage(
                    accepted: _accepted,
                    onAccepted: (v) => setState(() => _accepted = v),
                  ),
                  _LastPeriodPage(
                    selected: _lastPeriod,
                    unknown: _unknownLastPeriod,
                    onSelected: (d) => setState(() {
                      _lastPeriod = d;
                      _unknownLastPeriod = false;
                    }),
                    onUnknown: (v) => setState(() => _unknownLastPeriod = v),
                  ),
                  _CyclePage(
                    profile: _profile,
                    onChanged: (p) => setState(() => _profile = p),
                  ),
                  _OnboardingPage(
                    title: l10n.conditionsTitle,
                    children: [
                      Text(l10n.conditionsBody),
                      const SizedBox(height: 8),
                      ConditionsPicker(
                        selected: _profile.conditions,
                        onChanged: (c) => setState(
                          () => _profile = _profile.copyWith(conditions: c),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_page > 0)
                    TextButton(
                      onPressed: () => _pages.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      ),
                      child: Text(l10n.back),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _canContinue && !_saving ? _next : null,
                    child: Text(isLast ? l10n.finishOnboarding : l10n.next),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.accepted, required this.onAccepted});

  final bool accepted;
  final ValueChanged<bool> onAccepted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    Widget point(IconData icon, String text) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(text),
    );

    return _OnboardingPage(
      title: l10n.onboardingWelcomeTitle,
      children: [
        Text(l10n.onboardingWelcomeBody, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        point(Icons.phone_android, l10n.privacyLocal),
        point(Icons.lock_outline, l10n.privacyEncrypted),
        point(Icons.medical_information_outlined, l10n.privacyNoDiagnosis),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: accepted,
          onChanged: (v) => onAccepted(v ?? false),
          title: Text(l10n.disclaimerAccept),
        ),
      ],
    );
  }
}

class _LastPeriodPage extends ConsumerWidget {
  const _LastPeriodPage({
    required this.selected,
    required this.unknown,
    required this.onSelected,
    required this.onUnknown,
  });

  final DateTime? selected;
  final bool unknown;
  final ValueChanged<DateTime> onSelected;
  final ValueChanged<bool> onUnknown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayProvider);
    return _OnboardingPage(
      title: l10n.lastPeriodTitle,
      children: [
        CalendarDatePicker(
          initialDate: selected ?? today,
          firstDate: addDays(today, -365),
          lastDate: today,
          onDateChanged: onSelected,
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: unknown,
          onChanged: (v) => onUnknown(v ?? false),
          title: Text(l10n.lastPeriodUnknown),
        ),
      ],
    );
  }
}

class _CyclePage extends StatelessWidget {
  const _CyclePage({required this.profile, required this.onChanged});

  final HealthProfile profile;
  final ValueChanged<HealthProfile> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _OnboardingPage(
      title: l10n.cycleTitle,
      children: [
        DayStepper(
          label: l10n.cycleLength,
          value: profile.cycleLength,
          min: HealthProfile.minCycleLength,
          max: HealthProfile.maxCycleLength,
          onChanged: (v) => onChanged(profile.copyWith(cycleLength: v)),
        ),
        const SizedBox(height: 12),
        DayStepper(
          label: l10n.periodLength,
          value: profile.periodLength,
          min: HealthProfile.minPeriodLength,
          max: HealthProfile.maxPeriodLength,
          onChanged: (v) => onChanged(profile.copyWith(periodLength: v)),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.cycleLengthHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
