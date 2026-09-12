import 'package:flutter/material.dart';

enum ActivityCategory { transport, energy, shopping, waste }

/// Model representing a logged consumer activity.
class ActivityItem {
  final String id;
  final ActivityCategory category;
  final String title;
  final String details;
  final DateTime timestamp;
  final double mockCo2Kg;

  const ActivityItem({
    required this.id,
    required this.category,
    required this.title,
    required this.details,
    required this.timestamp,
    required this.mockCo2Kg,
  });

  IconData get icon {
    switch (category) {
      case ActivityCategory.transport:
        return Icons.directions_car_outlined;
      case ActivityCategory.energy:
        return Icons.bolt_outlined;
      case ActivityCategory.shopping:
        return Icons.shopping_bag_outlined;
      case ActivityCategory.waste:
        return Icons.delete_outline;
    }
  }

  Color get categoryColor {
    switch (category) {
      case ActivityCategory.transport:
        return Colors.blue.shade700;
      case ActivityCategory.energy:
        return Colors.orange.shade700;
      case ActivityCategory.shopping:
        return Colors.purple.shade700;
      case ActivityCategory.waste:
        return Colors.teal.shade700;
    }
  }

  static List<ActivityItem> get mockActivities => [
        ActivityItem(
          id: '1',
          category: ActivityCategory.transport,
          title: 'Petrol Car Commute',
          details: '18 km • Petrol Sedan',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          mockCo2Kg: 3.4,
        ),
        ActivityItem(
          id: '2',
          category: ActivityCategory.energy,
          title: 'Daily Electricity Consumption',
          details: '8.5 kWh consumed',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          mockCo2Kg: 6.2,
        ),
        ActivityItem(
          id: '3',
          category: ActivityCategory.shopping,
          title: 'Weekly Supermarket Grocery',
          details: '₹1,850 • Fresh Produce & Staples',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          mockCo2Kg: 4.1,
        ),
        ActivityItem(
          id: '4',
          category: ActivityCategory.waste,
          title: 'Recycled Plastic Bottles & Packaging',
          details: '2.5 kg segregated plastic',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          mockCo2Kg: 0.8,
        ),
        ActivityItem(
          id: '5',
          category: ActivityCategory.transport,
          title: 'Metro Rail Travel',
          details: '12 km • Electric Subway',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          mockCo2Kg: 0.5,
        ),
      ];
}
