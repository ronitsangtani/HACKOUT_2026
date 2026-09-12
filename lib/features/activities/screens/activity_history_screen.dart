import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/providers/ecoloop_providers.dart';
import '../models/activity_item.dart';

/// Screen listing logged user activities with category filtering,
/// live backend integration, pull-to-refresh, and empty/loading states.
class ActivityHistoryScreen extends ConsumerStatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  ConsumerState<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends ConsumerState<ActivityHistoryScreen> {
  ActivityCategory? _selectedCategory;

  ActivityCategory _mapStringToCategory(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('transport')) return ActivityCategory.transport;
    if (lower.contains('energy')) return ActivityCategory.energy;
    if (lower.contains('shopping')) return ActivityCategory.shopping;
    if (lower.contains('waste')) return ActivityCategory.waste;
    return ActivityCategory.transport;
  }

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(userActivitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Activities',
            onPressed: () => ref.refresh(userActivitiesProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', null),
                    const SizedBox(width: 8),
                    _buildFilterChip('Transport', ActivityCategory.transport),
                    const SizedBox(width: 8),
                    _buildFilterChip('Energy', ActivityCategory.energy),
                    const SizedBox(width: 8),
                    _buildFilterChip('Shopping', ActivityCategory.shopping),
                    const SizedBox(width: 8),
                    _buildFilterChip('Waste', ActivityCategory.waste),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // Activity List View with pull-to-refresh
            Expanded(
              child: activitiesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                ),
                error: (err, _) => RefreshIndicator(
                  color: AppTheme.primaryGreen,
                  onRefresh: () async => ref.refresh(userActivitiesProvider.future),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.cloud_off, size: 48, color: Colors.redAccent),
                            const SizedBox(height: 12),
                            Text('Failed to load activities: $err', style: const TextStyle(color: Colors.black54), textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => ref.refresh(userActivitiesProvider),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                data: (records) {
                  final List<ActivityItem> displayItems;
                  if (records.isNotEmpty) {
                    displayItems = records.map((r) {
                      final cat = _mapStringToCategory(r.category);
                      return ActivityItem(
                        id: r.activityId,
                        title: r.activityType,
                        category: cat,
                        details: '${r.quantity} ${r.unit} • ${r.category.toUpperCase()}',
                        mockCo2Kg: r.co2Kg,
                        timestamp: r.createdAt,
                      );
                    }).toList();
                  } else {
                    displayItems = ActivityItem.mockActivities;
                  }

                  final filtered = _selectedCategory == null
                      ? displayItems
                      : displayItems.where((a) => a.category == _selectedCategory).toList();

                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      color: AppTheme.primaryGreen,
                      onRefresh: () async => ref.refresh(userActivitiesProvider.future),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                          const Center(
                            child: Column(
                              children: [
                                Icon(Icons.history_outlined, size: 56, color: Colors.grey),
                                SizedBox(height: 12),
                                Text('No activities found in this category.', style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppTheme.primaryGreen,
                    onRefresh: () async => ref.refresh(userActivitiesProvider.future),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final activity = filtered[index];
                        return _buildActivityCard(activity);
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

  Widget _buildFilterChip(String label, ActivityCategory? category) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.darkText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }

  Widget _buildActivityCard(ActivityItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: item.categoryColor.withValues(alpha: 0.12),
          child: Icon(item.icon, color: item.categoryColor),
        ),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(item.details, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(
              '${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year} • ${_formatTime(item.timestamp)}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '+${item.mockCo2Kg} kg',
            style: TextStyle(
              color: Colors.red.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
