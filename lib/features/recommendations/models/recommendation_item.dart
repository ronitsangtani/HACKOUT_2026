import 'package:flutter/material.dart';

enum RecommendationType { repair, reuse, recycle, alternative }

/// Model representing a circular economy recommendation.
class RecommendationItem {
  final String id;
  final String title;
  final String reason;
  final String estimatedCo2Saving;
  final String estimatedCostImpact;
  final RecommendationType type;

  const RecommendationItem({
    required this.id,
    required this.title,
    required this.reason,
    required this.estimatedCo2Saving,
    required this.estimatedCostImpact,
    required this.type,
  });

  String get typeLabel {
    switch (type) {
      case RecommendationType.repair:
        return 'Repair';
      case RecommendationType.reuse:
        return 'Reuse';
      case RecommendationType.recycle:
        return 'Recycle';
      case RecommendationType.alternative:
        return 'Lower-Carbon';
    }
  }

  Color get typeColor {
    switch (type) {
      case RecommendationType.repair:
        return Colors.orange.shade700;
      case RecommendationType.reuse:
        return Colors.teal.shade700;
      case RecommendationType.recycle:
        return Colors.green.shade700;
      case RecommendationType.alternative:
        return Colors.blue.shade700;
    }
  }

  static List<RecommendationItem> get mockRecommendations => const [
        RecommendationItem(
          id: '1',
          title: 'Switch to Cold Water Laundry',
          reason: 'Water heating accounts for ~90% of washing machine electricity consumption.',
          estimatedCo2Saving: '-18 kg CO2/mo',
          estimatedCostImpact: 'Save ~₹320/mo',
          type: RecommendationType.alternative,
        ),
        RecommendationItem(
          id: '2',
          title: 'Repair Damaged Smartphone Display',
          reason: 'Manufacturing a new phone emits ~70 kg CO2. Repairing extends product life by 2+ years.',
          estimatedCo2Saving: '-65 kg CO2',
          estimatedCostImpact: 'Save ~₹18,000 vs new',
          type: RecommendationType.repair,
        ),
        RecommendationItem(
          id: '3',
          title: 'Adopt Stainless Steel Water Bottle',
          reason: 'Eliminates an estimated 150 single-use plastic bottles annually per person.',
          estimatedCo2Saving: '-12 kg CO2/yr',
          estimatedCostImpact: 'Save ~₹1,200/yr',
          type: RecommendationType.reuse,
        ),
        RecommendationItem(
          id: '4',
          title: 'Segregate E-Waste for Certified Recycler',
          reason: 'Recovers rare earth metals, lithium, and prevents toxic heavy metals in landfills.',
          estimatedCo2Saving: '-24 kg CO2/drop-off',
          estimatedCostImpact: 'Earn eco credits',
          type: RecommendationType.recycle,
        ),
        RecommendationItem(
          id: '5',
          title: 'Shift 2 Work Commutes to Metro / Train',
          reason: 'Public rapid transit emits 75% less CO2 per passenger km than solo driving.',
          estimatedCo2Saving: '-28 kg CO2/mo',
          estimatedCostImpact: 'Save ~₹1,400 fuel/mo',
          type: RecommendationType.alternative,
        ),
      ];
}
