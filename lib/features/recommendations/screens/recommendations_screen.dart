import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/providers/ecoloop_providers.dart';
import '../models/recommendation_item.dart';

/// Screen displaying circular recommendations (Repair, Reuse, Recycling, Lower-Carbon).
/// Features live API integration, pull-to-refresh, category filters, and action adoption.
class RecommendationsScreen extends ConsumerStatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  ConsumerState<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends ConsumerState<RecommendationsScreen> {
  final Set<String> _adoptedRecommendations = {};
  RecommendationType? _selectedFilter;

  RecommendationType _mapCategoryToType(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('repair')) return RecommendationType.repair;
    if (lower.contains('reuse')) return RecommendationType.reuse;
    if (lower.contains('recycle') || lower.contains('waste')) return RecommendationType.recycle;
    return RecommendationType.alternative;
  }

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(circularRecommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Circular Recommendations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Recommendations',
            onPressed: () => ref.invalidate(circularRecommendationsProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All Actions', null),
                    const SizedBox(width: 8),
                    _buildFilterChip('Repair', RecommendationType.repair),
                    const SizedBox(width: 8),
                    _buildFilterChip('Reuse', RecommendationType.reuse),
                    const SizedBox(width: 8),
                    _buildFilterChip('Recycle', RecommendationType.recycle),
                    const SizedBox(width: 8),
                    _buildFilterChip('Lower-Carbon', RecommendationType.alternative),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // Recommendations List with pull-to-refresh
            Expanded(
              child: recommendationsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                ),
                error: (err, _) => RefreshIndicator(
                  color: AppTheme.primaryGreen,
                  onRefresh: () async {
                    ref.invalidate(circularRecommendationsProvider);
                    await ref.read(circularRecommendationsProvider.future);
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.cloud_off, size: 48, color: Colors.redAccent),
                            const SizedBox(height: 12),
                            Text('Could not load recommendations: $err', style: const TextStyle(color: Colors.black54), textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => ref.invalidate(circularRecommendationsProvider),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                data: (records) {
                  final List<RecommendationItem> allItems;
                  if (records.isNotEmpty) {
                    allItems = records.map((r) {
                      final type = _mapCategoryToType(r.category);
                      return RecommendationItem(
                        id: r.recommendationId,
                        title: r.title,
                        type: type,
                        reason: r.description,
                        estimatedCo2Saving: r.estimatedCo2Saving,
                        estimatedCostImpact: r.estimatedCostImpact,
                      );
                    }).toList();
                  } else {
                    allItems = RecommendationItem.mockRecommendations;
                  }

                  final filteredItems = _selectedFilter == null
                      ? allItems
                      : allItems.where((r) => r.type == _selectedFilter).toList();

                  return RefreshIndicator(
                    color: AppTheme.primaryGreen,
                    onRefresh: () async {
                      ref.invalidate(circularRecommendationsProvider);
                      await ref.read(circularRecommendationsProvider.future);
                    },
                    child: filteredItems.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 40),
                              Center(
                                child: Text('No recommendations in this category.', style: TextStyle(color: Colors.black54)),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16.0),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final isAdopted = _adoptedRecommendations.contains(item.id);
                              return _buildRecommendationCard(item, isAdopted);
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, RecommendationType? type) {
    final isSelected = _selectedFilter == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.darkText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => setState(() => _selectedFilter = type),
    );
  }

  Widget _buildRecommendationCard(RecommendationItem item, bool isAdopted) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Type Badge + Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.typeLabel.toUpperCase(),
                    style: TextStyle(
                      color: item.typeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (isAdopted)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Adopted',
                        style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              item.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText),
            ),
            const SizedBox(height: 6),

            Text(
              item.reason,
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
            ),
            const SizedBox(height: 14),

            // Estimated Impact Row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.eco_outlined, color: AppTheme.primaryGreen, size: 18),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CO2 Saving', style: TextStyle(fontSize: 10, color: Colors.black54)),
                          Text(
                            item.estimatedCo2Saving,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryGreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(height: 24, width: 1, color: Colors.grey.shade300),
                  Row(
                    children: [
                      const Icon(Icons.savings_outlined, color: Colors.teal, size: 18),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cost Impact', style: TextStyle(fontSize: 10, color: Colors.black54)),
                          Text(
                            item.estimatedCostImpact,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    if (isAdopted) {
                      _adoptedRecommendations.remove(item.id);
                    } else {
                      _adoptedRecommendations.add(item.id);
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAdopted ? 'Habit removed from active list.' : '🎉 Habit adopted! +20 Eco Points earned.',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: Icon(isAdopted ? Icons.check : Icons.all_inclusive, size: 18),
                label: Text(isAdopted ? 'Action Completed' : 'Adopt Circular Action'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAdopted ? Colors.grey.shade700 : AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
