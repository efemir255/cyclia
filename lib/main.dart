import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/database_key.dart';
import 'data/open_database.dart';
import 'l10n/app_localizations.dart';
import 'services/app_locker.dart';
import 'services/reminder_scheduler.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final keys = DatabaseKeyStore();
  final prefs = await SharedPreferences.getInstance();
  final reminders = LocalNotificationScheduler();
  await reminders.init();

  try {
    final repository = await openEncryptedRepository(keys);
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          repositoryProvider.overrideWithValue(repository),
          reminderSchedulerProvider.overrideWithValue(reminders),
          appLockerProvider.overrideWithValue(DeviceAppLocker()),
        ],
        child: const CycliaApp(),
      ),
    );
  } on DatabaseUnreadableException {
    runApp(
      _DatabaseErrorApp(
        onStartFresh: () async {
          await wipeEncryptedDatabase(keys);
          await prefs.clear();
          await main();
        },
      ),
    );
  }
}

/// Shown when the encrypted database exists but its key is gone. The data
/// is unrecoverable by design, so the only way forward is a fresh start.
class _DatabaseErrorApp extends StatelessWidget {
  const _DatabaseErrorApp({required this.onStartFresh});

  final Future<void> Function() onStartFresh;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_reset, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      l10n.dbErrorTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.dbErrorBody, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: onStartFresh,
                      child: Text(l10n.startFresh),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
