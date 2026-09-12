import 'package:flutter/material.dart';
import '../features/activities/screens/activities_hub_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/recommendations/screens/actions_hub_screen.dart';
import '../features/rewards/screens/rewards_screen.dart';
import 'theme.dart';

/// Main navigation frame containing the Bottom Navigation Bar for EcoLoop.
class MainNavigationScaffold extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScaffold({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ActivitiesHubScreen(),
    ActionsHubScreen(),
    RewardsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 4,
        indicatorColor: AppTheme.lightGreen,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.primaryGreen),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt, color: AppTheme.primaryGreen),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.all_inclusive_outlined),
            selectedIcon: Icon(Icons.all_inclusive, color: AppTheme.primaryGreen),
            label: 'Actions',
          ),
          NavigationDestination(
            icon: Icon(Icons.military_tech_outlined),
            selectedIcon: Icon(Icons.military_tech, color: AppTheme.primaryGreen),
            label: 'Rewards',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primaryGreen),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
