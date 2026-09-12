import 'package:flutter/material.dart';

class BadgeItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final String? earnedDate;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.earnedDate,
  });
}

class CompletedAction {
  final String title;
  final int points;
  final String date;

  const CompletedAction({
    required this.title,
    required this.points,
    required this.date,
  });
}

class RewardSummary {
  final int ecoPoints;
  final int level;
  final String levelTitle;
  final int streakDays;
  final List<BadgeItem> badges;
  final List<CompletedAction> recentActions;

  const RewardSummary({
    required this.ecoPoints,
    required this.level,
    required this.levelTitle,
    required this.streakDays,
    required this.badges,
    required this.recentActions,
  });

  static RewardSummary get mockSummary => const RewardSummary(
        ecoPoints: 580,
        level: 3,
        levelTitle: 'Eco Pathfinder',
        streakDays: 7,
        badges: [
          BadgeItem(
            id: '1',
            title: 'First Step',
            description: 'Logged your first activity in EcoLoop.',
            icon: Icons.flag_outlined,
            isUnlocked: true,
            earnedDate: 'Sep 05, 2026',
          ),
          BadgeItem(
            id: '2',
            title: 'Transit Hero',
            description: 'Took public transport 5 times in a week.',
            icon: Icons.directions_subway_outlined,
            isUnlocked: true,
            earnedDate: 'Sep 09, 2026',
          ),
          BadgeItem(
            id: '3',
            title: 'Circular Mindset',
            description: 'Completed 3 repair or reuse actions.',
            icon: Icons.autorenew,
            isUnlocked: true,
            earnedDate: 'Sep 11, 2026',
          ),
          BadgeItem(
            id: '4',
            title: 'Zero Waste Week',
            description: 'Maintained segregated waste disposal for 7 days.',
            icon: Icons.recycling,
            isUnlocked: false,
          ),
          BadgeItem(
            id: '5',
            title: 'Carbon Cutter 100',
            description: 'Saved a cumulative 100 kg of CO2e.',
            icon: Icons.eco_outlined,
            isUnlocked: false,
          ),
        ],
        recentActions: [
          CompletedAction(
            title: 'Repaired smartphone screen',
            points: 50,
            date: 'Yesterday',
          ),
          CompletedAction(
            title: 'Took Metro to commute',
            points: 25,
            date: '2 days ago',
          ),
          CompletedAction(
            title: 'Plastic waste segregated',
            points: 15,
            date: '3 days ago',
          ),
          CompletedAction(
            title: 'Switched to cold laundry',
            points: 20,
            date: 'Sep 07, 2026',
          ),
        ],
      );
}
