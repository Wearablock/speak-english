import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_screen.dart';
import '../lessons/category_screen.dart';
import '../progress/progress_screen.dart';
import '../settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoryScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.house(PhosphorIconsStyle.regular)),
            activeIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.books(PhosphorIconsStyle.regular)),
            activeIcon: Icon(PhosphorIcons.books(PhosphorIconsStyle.fill)),
            label: l10n.lessons,
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.chartLine(PhosphorIconsStyle.regular)),
            activeIcon: Icon(PhosphorIcons.chartLine(PhosphorIconsStyle.fill)),
            label: l10n.progress,
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.gear(PhosphorIconsStyle.regular)),
            activeIcon: Icon(PhosphorIcons.gear(PhosphorIconsStyle.fill)),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
