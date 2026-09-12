import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

/// Root application widget for EcoLoop.
class EcoLoopApp extends StatelessWidget {
  const EcoLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoLoop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.root,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
