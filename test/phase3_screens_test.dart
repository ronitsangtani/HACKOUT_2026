import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoloop/app/main_navigation_scaffold.dart';
import 'package:ecoloop/app/theme.dart';
import 'package:ecoloop/features/activities/screens/add_activity_screen.dart';
import 'package:ecoloop/features/activities/screens/carbon_impact_screen.dart';
import 'package:ecoloop/features/profile/screens/settings_screen.dart';
import 'package:ecoloop/features/recommendations/screens/recommendations_screen.dart';
import 'package:ecoloop/features/recommendations/screens/what_if_simulator_screen.dart';
import 'package:ecoloop/features/recycling/screens/recycling_locator_screen.dart';

import 'package:ecoloop/core/providers/ecoloop_providers.dart';
import 'package:ecoloop/features/recycling/models/recycling_center.dart';
import 'package:ecoloop/models/firestore_models.dart';

void main() {
  Widget createTestWidget(Widget child, [List overrides = const []]) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('MainNavigationScaffold Tests', () {
    testWidgets('Renders all 5 bottom navigation destinations and switches tabs', (tester) async {
      await tester.pumpWidget(createTestWidget(const MainNavigationScaffold()));

      // Check Duolingo navigation destinations
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Rank'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Tap Map tab
      await tester.tap(find.text('Map'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('ECO MAP'), findsOneWidget);

      // Tap Rank tab
      await tester.tap(find.text('Rank'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('LEADERBOARD'), findsOneWidget);

      // Tap Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('PROFILE'), findsOneWidget);
    });
  });

  group('AddActivityScreen Tests', () {
    testWidgets('Renders interactive lesson steps and advances to activity selection', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddActivityScreen()));

      expect(find.text('What did you do today?'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Waste'), findsOneWidget);

      // Select Transport
      await tester.tap(find.text('Transport'));
      await tester.pumpAndSettle();

      // Tap CONTINUE button
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      // Step 2: Activity Selection
      expect(find.text('Which transport action?'), findsOneWidget);
      expect(find.text('Solo Petrol Car'), findsOneWidget);
      expect(find.text('City Bus'), findsOneWidget);
    });
  });

  group('CarbonImpactScreen Tests', () {
    testWidgets('Renders category contributions and total impact', (tester) async {
      await tester.pumpWidget(createTestWidget(const CarbonImpactScreen()));

      expect(find.text('Carbon Impact Analysis'), findsOneWidget);
      expect(find.text('Transport Emissions'), findsOneWidget);
      expect(find.text('Household Energy'), findsOneWidget);
      expect(find.text('Shopping & Goods'), findsOneWidget);
      expect(find.text('Waste & Landfill'), findsOneWidget);
    });
  });

  group('WhatIfSimulatorScreen Tests', () {
    testWidgets('Renders sliders and projected footprint stats', (tester) async {
      await tester.pumpWidget(createTestWidget(const WhatIfSimulatorScreen()));

      expect(find.text('What-If Simulator'), findsOneWidget);
      expect(find.text('Solo Car Travel'), findsOneWidget);
      expect(find.text('Plant-Based / Meatless Days'), findsOneWidget);
      expect(find.text('Air Conditioner Usage'), findsOneWidget);
      expect(find.text('Renewable / Green Energy Share'), findsOneWidget);
      expect(find.text('CO2 Reduction'), findsOneWidget);
    });
  });

  group('RecommendationsScreen Tests', () {
    testWidgets('Renders circular recommendation cards and filters', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const RecommendationsScreen(),
        [
          circularRecommendationsProvider.overrideWith((ref) async => [
            const RecommendationRecord(
              recommendationId: 'rec_001',
              category: 'Household Energy',
              title: 'Switch to Cold Water Laundry',
              description: 'Washing clothes at 30°C or cold water uses 75-90% less electricity.',
              estimatedCo2Saving: '0.6 kg CO2e / load',
              estimatedCostImpact: '-15% energy cost',
            ),
            const RecommendationRecord(
              recommendationId: 'rec_002',
              category: 'Shopping & Goods',
              title: 'Repair Damaged Smartphone Display',
              description: 'Fixing the screen rather than buying a new phone prevents 60-80 kg CO2e.',
              estimatedCo2Saving: '70 kg CO2e',
              estimatedCostImpact: '-75% replacement expense',
            ),
          ]),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Circular Recommendations'), findsOneWidget);
      expect(find.text('Switch to Cold Water Laundry'), findsOneWidget);
      expect(find.text('Repair Damaged Smartphone Display'), findsOneWidget);
    });
  });

  group('RecyclingLocatorScreen Tests', () {
    testWidgets('Renders search and recycling drop-off centers', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const RecyclingLocatorScreen(),
        [
          recyclingCentersProvider.overrideWith((ref, material) async => RecyclingCenter.mockCenters),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('ECO MAP'), findsOneWidget);
      expect(find.text('All Hubs'), findsOneWidget);
      expect(find.text('Recycling'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });
  });

  group('SettingsScreen Tests', () {
    testWidgets('Renders notification switches and measurement radios', (tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Daily Activity Reminder'), findsOneWidget);
      expect(find.text('Weekly Footprint Report'), findsOneWidget);
      expect(find.text('Metric System'), findsOneWidget);
    });
  });
}
