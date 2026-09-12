import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/ranking/models/leaderboard_entry.dart';
import '../../features/recycling/models/recycling_center.dart';
import '../../models/firestore_models.dart';
import '../services/ecoloop_api_service.dart';

/// Provider for user logged activities fetched from backend
final userActivitiesProvider = FutureProvider<List<ActivityRecord>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchUserActivities(user.uid);
});

/// Provider for circular recommendations from backend
final circularRecommendationsProvider = FutureProvider<List<RecommendationRecord>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchRecommendations();
});

/// Provider for community leaderboard
final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchLeaderboard();
});

/// Provider for verified recycling centers
final recyclingCentersProvider = FutureProvider.family<List<RecyclingCenter>, String?>((ref, material) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchRecyclingCenters(material: material);
});
