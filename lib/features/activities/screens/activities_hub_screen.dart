import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../models/activity_item.dart';

/// Activity Hub screen (Tab 1 in Bottom Navigation).
class ActivitiesHubScreen extends StatelessWidget {
  const ActivitiesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recentActivities = ActivityItem.mockActivities.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity & Impact Hub'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Quick Add Card
              Card(
                color: AppTheme.lightGreen,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppTheme.primaryGreen,
                        child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Log New Consumption',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Transport, energy, shopping, or waste.',
                              style: TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.addActivity),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        child: const Text('Log', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Carbon Impact Direct Nav Card
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.carbonImpact),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.analytics_outlined, color: Colors.blue.shade800, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Carbon Impact Breakdown',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'View weekly trends & category contributions.',
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recent Activities Header with "View All"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activities',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.activityHistory),
                    child: const Text('View All', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...recentActivities.map((activity) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: activity.categoryColor.withValues(alpha: 0.12),
                        child: Icon(activity.icon, color: activity.categoryColor),
                      ),
                      title: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      subtitle: Text(activity.details, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                      trailing: Text(
                        '+${activity.mockCo2Kg} kg',
                        style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
