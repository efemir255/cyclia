import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'calendar_screen.dart';
import 'health_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

/// Root screen with bottom navigation between the four tabs.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          TodayScreen(),
          CalendarScreen(),
          HealthScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.water_drop_outlined),
            selectedIcon: const Icon(Icons.water_drop),
            label: l10n.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.navCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline),
            selectedIcon: const Icon(Icons.favorite),
            label: l10n.navHealth,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
