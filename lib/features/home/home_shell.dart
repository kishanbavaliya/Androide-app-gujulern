import 'package:flutter/material.dart';
import 'home_dashboard_screen.dart';
import '../learning/categories_screen.dart';
import '../practice/practice_screen.dart';
import '../progress/progress_screen.dart';
import '../settings/settings_screen.dart';

/// Hosts the bottom navigation bar and switches between the five main
/// tabs of the app once onboarding is complete.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _screens = const [
    HomeDashboardScreen(),
    CategoriesScreen(),
    PracticeScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  void _goToTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return HomeTabController(
      goToTab: _goToTab,
      child: Scaffold(
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _goToTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Learn',
            ),
            NavigationDestination(
              icon: Icon(Icons.quiz_outlined),
              selectedIcon: Icon(Icons.quiz),
              label: 'Practice',
            ),
            NavigationDestination(
              icon: Icon(Icons.trending_up_outlined),
              selectedIcon: Icon(Icons.trending_up),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

/// Lets descendant widgets switch tabs (e.g. a "Continue Learning" button
/// on the dashboard jumping to the Learn tab) without needing a new route.
class HomeTabController extends InheritedWidget {
  final void Function(int) goToTab;

  const HomeTabController({
    super.key,
    required this.goToTab,
    required super.child,
  });

  static HomeTabController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeTabController>();
  }

  @override
  bool updateShouldNotify(HomeTabController oldWidget) => false;
}
