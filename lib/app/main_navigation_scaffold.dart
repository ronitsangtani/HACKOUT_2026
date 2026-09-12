import 'package:flutter/material.dart';
import '../features/activities/screens/add_activity_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/ranking/screens/leaderboard_screen.dart';
import '../features/recommendations/screens/what_if_simulator_screen.dart';
import '../features/rewards/screens/rewards_screen.dart';
import 'theme.dart';

/// Duolingo-styled 5-destination bottom navigation scaffold for EcoLoop.
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
    DashboardScreen(),           // 🏠 Home (0)
    RewardsScreen(),             // 🎁 Reward (1)
    AddActivityScreen(),         // ➕ Add (2 - opens activity flow)
    LeaderboardScreen(),         // 🏆 Rank (3)
    WhatIfSimulatorScreen(),     // 🎛️ Stimulator (4)
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (index == 2) {
      // Add Activity opens directly or navigates
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddActivityScreen()),
      ).then((_) {
        // Refresh when returning from activity
        setState(() {});
      });
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    bool isPrimary = false,
  }) {
    final isSelected = _currentIndex == index;

    if (isPrimary) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabSelected(index),
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppTheme.duoGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.duoGreenDark,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.duoGreenDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabSelected(index),
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? AppTheme.duoGreen : AppTheme.duoGrayDark,
                size: 26,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected ? AppTheme.duoGreen : AppTheme.duoSubtext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppTheme.duoGray, width: 2),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.card_giftcard_outlined,
                selectedIcon: Icons.card_giftcard_rounded,
                label: 'Reward',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.add_rounded,
                selectedIcon: Icons.add_rounded,
                label: 'Add',
                isPrimary: true,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.emoji_events_outlined,
                selectedIcon: Icons.emoji_events_rounded,
                label: 'Rank',
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.tune_rounded,
                selectedIcon: Icons.tune_rounded,
                label: 'Stimulator',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
