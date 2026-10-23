import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../state/providers.dart';
import '../state/settings.dart';

/// Covers [child] with a lock screen when app lock is on: at launch, and
/// when returning after more than [relockAfter] in the background.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  static const relockAfter = Duration(seconds: 30);

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  late bool _locked = ref.read(settingsProvider).appLockEnabled;
  late final AppLifecycleListener _lifecycle;
  DateTime? _hiddenAt;
  var _authenticating = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onHide: _onHide, onShow: _onShow);
    if (_locked) WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _onHide() {
    // The system auth prompt itself can hide the app; don't count that.
    if (!_authenticating) _hiddenAt = DateTime.now();
  }

  void _onShow() {
    // A new day may have started while the app was in the background.
    ref.invalidate(todayProvider);
    final hiddenAt = _hiddenAt;
    _hiddenAt = null;
    if (!ref.read(settingsProvider).appLockEnabled || hiddenAt == null) return;
    if (DateTime.now().difference(hiddenAt) > AppLockGate.relockAfter) {
      setState(() => _locked = true);
      _unlock();
    }
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    _authenticating = true;
    final reason = AppLocalizations.of(context).unlockReason;
    final ok = await ref.read(appLockerProvider).authenticate(reason);
    _authenticating = false;
    if (ok && mounted) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_locked) return widget.child;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(l10n.lockedTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _unlock,
                icon: const Icon(Icons.fingerprint),
                label: Text(l10n.unlock),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
