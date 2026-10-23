import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/dates.dart';
import '../data/cyclia_repository.dart';
import '../services/app_locker.dart';
import '../services/reminder_scheduler.dart';

// Platform services, overridden in main() and with fakes in tests.

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final repositoryProvider = Provider<CycliaRepository>(
  (ref) => throw UnimplementedError('repositoryProvider not overridden'),
);

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => throw UnimplementedError('reminderSchedulerProvider not overridden'),
);

final appLockerProvider = Provider<AppLocker>(
  (ref) => throw UnimplementedError('appLockerProvider not overridden'),
);

/// Today's date. Invalidated when the app returns to the foreground so a
/// session left open overnight moves on to the new day.
final todayProvider = Provider<DateTime>((ref) => dateOnly(DateTime.now()));
