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
import 'package:ecoloop/features/rewards/screens/rewards_screen.dart';
import 'package:ecoloop/features/dashboard/dashboard_screen.dart';

import 'package:ecoloop/core/providers/ecoloop_providers.dart';
import 'package:ecoloop/core/widgets/polar_bear_widget.dart';
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

      // Check Duolingo navigation destinations: Home, Reward, Add, Rank, Stimulator
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Reward'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Rank'), findsOneWidget);
      expect(find.text('Stimulator'), findsOneWidget);

      // Tap Reward tab
      await tester.tap(find.text('Reward'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('ECO REWARDS'), findsOneWidget);

      // Tap Rank tab
      await tester.tap(find.text('Rank'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('🏆 ECO LEAGUE'), findsOneWidget);

      // Tap Stimulator tab
      await tester.tap(find.text('Stimulator'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('What-If Simulator'), findsOneWidget);
    });
  });

  group('DashboardScreen Journey Path Tests', () {
    testWidgets('Renders the 4 active journey stages and allows tapping any level directly', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const DashboardScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify the 4 active levels are present together
      expect(find.text('Transport'), findsWidgets);
      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('Diet & Food'), findsOneWidget);
      expect(find.text('Circular Goods'), findsOneWidget);

      // Verify Zero Waste and Eco Master are removed
      expect(find.text('Zero Waste'), findsNothing);
      expect(find.text('Eco Master'), findsNothing);

      // Verify tapping 'Energy' directly opens the energy flow
      await tester.tap(find.text('Energy'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Which energy action?'), findsOneWidget);
      expect(find.text('Grid Electricity'), findsOneWidget);
      expect(find.text('MULTIPLE SELECTIONS ALLOWED'), findsOneWidget);
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
      await tester.pump(const Duration(milliseconds: 300));

      // Tap CONTINUE button
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 300));

      // Step 2: Activity Selection
      expect(find.text('Which transport action?'), findsOneWidget);
      expect(find.text('Solo Petrol Car'), findsOneWidget);
      expect(find.text('City Bus'), findsOneWidget);
    });

    testWidgets('Awards positive points for sustainable low-carbon choices (Bicycle)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const AddActivityScreen(initialCategory: 'Transport')));
      await tester.pump(const Duration(milliseconds: 300));

      // Step 2: Pick Bicycle / Walking
      await tester.tap(find.text('Bicycle / Walking'));
      await tester.pump(const Duration(milliseconds: 300));

      // Continue to quantity
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 300));

      // Step 3: Calculate & Log
      await tester.tap(find.text('CALCULATE & LOG'));
      await tester.pump(const Duration(milliseconds: 600));

      // Verify Celebration Screen awards positive points
      expect(find.text('SUSTAINABLE CHOICE!'), findsOneWidget);
      expect(find.text('EARNED'), findsOneWidget);
      expect(find.textContaining('🌱'), findsWidgets);
    });

    testWidgets('Applies negative penalty points for excessive carbon choice (Solo Petrol Car)', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddActivityScreen(initialCategory: 'Transport')));
      await tester.pump(const Duration(milliseconds: 300));

      // Step 2: Pick Solo Petrol Car
      await tester.tap(find.text('Solo Petrol Car'));
      await tester.pump(const Duration(milliseconds: 300));

      // Continue to quantity
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 300));

      // Step 3: Calculate & Log
      await tester.tap(find.text('CALCULATE & LOG'));
      await tester.pump(const Duration(milliseconds: 600));

      // Verify Celebration Screen displays penalty warning and negative points
      expect(find.text('HIGH CARBON FOOTPRINT!'), findsOneWidget);
      expect(find.text('PENALTY'), findsOneWidget);
      expect(find.textContaining('🔻'), findsWidgets);
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

  group('RewardsScreen Tests', () {
    testWidgets('Renders live eco points, perks card, and milestone badges without community leaderboard', (tester) async {
      await tester.pumpWidget(createTestWidget(const RewardsScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('ECO REWARDS'), findsOneWidget);
      expect(find.text('UNLOCKED MILESTONE BADGES'), findsOneWidget);
      expect(find.text('EARN GEMS & KEEP ICE COOL'), findsOneWidget);
      expect(find.text('COMMUNITY LEADERBOARD'), findsNothing);
      expect(find.text('VIEW LEADERBOARD'), findsNothing);
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

  group('PolarBearWidget Mascot Tests', () {
    testWidgets('Renders PolarBearWidget in various emotional states', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const Column(
          children: [
            PolarBearWidget(mood: PolarBearMood.happy, size: 100),
            PolarBearWidget(mood: PolarBearMood.worried, size: 100),
            PolarBearWidget(mood: PolarBearMood.celebrating, size: 100),
          ],
        ),
      ));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(PolarBearWidget), findsNWidgets(3));
    });

    testWidgets('Dashboard displays Polar Bear stage, Header profile mascot, and Carbon Status card', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const DashboardScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('YOUR CARBON STATUS'), findsOneWidget);
      // Both Header profile button and Hero Stage contain PolarBearWidget
      expect(find.byType(PolarBearWidget), findsAtLeastNWidgets(1));
    });

    testWidgets('AddActivityScreen supports multiple choice in non-transport and shows AI recommendation in summary', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddActivityScreen(initialCategory: 'Energy')));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Which energy action?'), findsOneWidget);
      expect(find.text('MULTIPLE SELECTIONS ALLOWED'), findsOneWidget);

      // Select Grid Electricity
      await tester.tap(find.text('Grid Electricity'));
      await tester.pump(const Duration(milliseconds: 200));

      // Also select Rooftop Solar Power (Multiple selection allowed!)
      await tester.tap(find.text('Rooftop Solar Power'));
      await tester.pump(const Duration(milliseconds: 200));

      // Advance to Step 3 (Quantities)
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Quantities Recorded'), findsOneWidget);

      // Submit calculation
      await tester.tap(find.text('CALCULATE & LOG'));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify AI recommendation card is prominently displayed
      expect(find.text('AI RECOMMENDATION'), findsOneWidget);
      expect(find.text('TRY THIS'), findsOneWidget);
    });
  });
}
