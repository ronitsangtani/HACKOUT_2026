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

void main() {
  Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('MainNavigationScaffold Tests', () {
    testWidgets('Renders all 5 bottom navigation destinations and switches tabs', (tester) async {
      await tester.pumpWidget(createTestWidget(const MainNavigationScaffold()));

      // Check destinations
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Tap Activity tab
      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();
      expect(find.text('Activity & Impact Hub'), findsOneWidget);

      // Tap Actions tab
      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      expect(find.text('Circular Actions & Tools'), findsOneWidget);

      // Tap Rewards tab
      await tester.tap(find.text('Rewards'));
      await tester.pumpAndSettle();
      expect(find.text('Eco Rewards & Milestones'), findsOneWidget);

      // Tap Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('My Profile'), findsOneWidget);
    });
  });

  group('AddActivityScreen Tests', () {
    testWidgets('Renders 4 tabs and validates required inputs', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddActivityScreen()));

      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Waste'), findsOneWidget);

      // Switch to Energy tab
      await tester.tap(find.text('Energy'));
      await tester.pumpAndSettle();
      expect(find.text('Household Energy'), findsOneWidget);

      // Switch to Shopping tab
      await tester.tap(find.text('Shopping'));
      await tester.pumpAndSettle();
      expect(find.text('Shopping & Goods'), findsOneWidget);

      // Switch to Waste tab
      await tester.tap(find.text('Waste'));
      await tester.pumpAndSettle();
      expect(find.text('Waste Disposal'), findsOneWidget);
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
      await tester.pumpWidget(createTestWidget(const RecommendationsScreen()));

      expect(find.text('Circular Recommendations'), findsOneWidget);
      expect(find.text('Switch to Cold Water Laundry'), findsOneWidget);
      expect(find.text('Repair Damaged Smartphone Display'), findsOneWidget);
    });
  });

  group('RecyclingLocatorScreen Tests', () {
    testWidgets('Renders search and recycling drop-off centers', (tester) async {
      await tester.pumpWidget(createTestWidget(const RecyclingLocatorScreen()));

      expect(find.text('Recycling & Circular Hubs'), findsOneWidget);
      expect(find.text('GreenEarth E-Waste & Battery Drop-Off'), findsOneWidget);
      expect(find.text('EcoCycle Polymer Recovery Hub'), findsOneWidget);
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
