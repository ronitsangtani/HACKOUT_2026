import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../models/recommendation_item.dart';

/// Actions Hub screen (Tab 2 in Bottom Navigation).
/// Hosts quick access to Circular Recommendations and What-If Simulator.
class ActionsHubScreen extends StatelessWidget {
  const ActionsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topRecommendations = RecommendationItem.mockRecommendations.take(2).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Circular Actions & Tools'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // What-If Simulator Feature Banner
              Card(
                color: Colors.teal.shade700,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.tune, color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'What-If Simulator',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Simulate how switching to public transit, plant-based days, or solar power cuts your footprint.',
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.whatIf),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.teal.shade800,
                        ),
                        child: const Text('Open Simulator', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Recycling Locator Shortcut Card
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    child: Icon(Icons.recycling, color: Colors.green.shade800),
                  ),
                  title: const Text('Recycling & Circular Centers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Find local verified e-waste, plastic & textile drops.', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.recycling),
                ),
              ),

              const SizedBox(height: 24),

              // Top Recommendations Header with "See All"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended Circular Actions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.recommendations),
                    child: const Text('See All', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...topRecommendations.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: item.typeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.typeLabel.toUpperCase(),
                                  style: TextStyle(color: item.typeColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Spacer(),
                              Text(item.estimatedCo2Saving, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryGreen)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(item.reason, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        ],
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
