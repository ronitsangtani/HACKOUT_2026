import 'package:flutter/material.dart';
import '../../../app/theme.dart';

/// Settings screen managing notification preferences, measurement units, and app information.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyReminder = true;
  bool _weeklySummary = true;
  bool _actionAlerts = false;
  String _selectedUnit = 'Metric (kg CO2e, km, kWh)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // 1. Notification Preferences
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Daily Activity Reminder', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Prompts to log your commute & energy at 8:00 PM', style: TextStyle(fontSize: 11)),
                    activeThumbColor: AppTheme.primaryGreen,
                    value: _dailyReminder,
                    onChanged: (val) => setState(() => _dailyReminder = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Weekly Footprint Report', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Summary of weekly trends & CO2 reductions', style: TextStyle(fontSize: 11)),
                    activeThumbColor: AppTheme.primaryGreen,
                    value: _weeklySummary,
                    onChanged: (val) => setState(() => _weeklySummary = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Circular Habit Alerts', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Action reminders for repair and recycling days', style: TextStyle(fontSize: 11)),
                    activeThumbColor: AppTheme.primaryGreen,
                    value: _actionAlerts,
                    onChanged: (val) => setState(() => _actionAlerts = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Units of Measurement
            const Text(
              'Units & Measurements',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Metric System', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Kilograms (kg CO2e), Kilometers (km), kWh', style: TextStyle(fontSize: 11)),
                    leading: Icon(
                      _selectedUnit.startsWith('Metric') ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: _selectedUnit.startsWith('Metric') ? AppTheme.primaryGreen : Colors.grey,
                    ),
                    onTap: () => setState(() => _selectedUnit = 'Metric (kg CO2e, km, kWh)'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Imperial System', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Pounds (lb CO2e), Miles (mi), kWh', style: TextStyle(fontSize: 11)),
                    leading: Icon(
                      _selectedUnit.startsWith('Imperial') ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: _selectedUnit.startsWith('Imperial') ? AppTheme.primaryGreen : Colors.grey,
                    ),
                    onTap: () => setState(() => _selectedUnit = 'Imperial (lb CO2e, mi, kWh)'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. About & Privacy
            const Text(
              'About & Privacy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: AppTheme.primaryGreen),
                    title: const Text('About EcoLoop', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Version 1.0.0 • Hackout 2026 Project', style: TextStyle(fontSize: 11)),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'EcoLoop',
                        applicationVersion: '1.0.0 (Phase 3 Foundation)',
                        applicationLegalese: 'Built for the Consumer Carbon Loop problem statement.',
                        children: const [
                          SizedBox(height: 12),
                          Text(
                            'EcoLoop empowers individuals to track daily carbon footprints and adopts circular actions including repair, reuse, recycling, and lower-carbon alternatives.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.primaryGreen),
                    title: const Text('Privacy & Data Handling', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Your consumption records are kept private', style: TextStyle(fontSize: 11)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Privacy Commitment'),
                          content: const Text(
                            'EcoLoop stores your activity data strictly for personalized circular feedback and carbon estimation. Personal details are never shared with third parties.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
