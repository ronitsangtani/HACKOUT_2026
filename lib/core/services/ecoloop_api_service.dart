import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/models/user_model.dart';
import '../../models/firestore_models.dart';
import '../../features/ranking/models/leaderboard_entry.dart';
import '../../features/recycling/models/recycling_center.dart';
import 'api_client.dart';

/// Service interfacing Flutter with the EcoLoop FastAPI backend.
class EcoLoopApiService {
  final ApiClient _client;

  EcoLoopApiService([ApiClient? client]) : _client = client ?? ApiClient();

  /// GET /api/v1/profile/{user_id}
  Future<UserModel> fetchProfile(String userId) async {
    final data = await _client.get('/api/v1/profile/$userId');
    if (data is Map<String, dynamic>) {
      return UserModel.fromMap(data);
    }
    throw const ApiException(statusCode: 500, message: 'Invalid profile response format');
  }

  /// POST /api/v1/activities
  Future<ActivityAnalysisResult> logActivity({
    required String category,
    required String activityType,
    required double quantity,
    required String unit,
  }) async {
    final payload = {
      'category': category,
      'activityType': activityType,
      'quantity': quantity,
      'unit': unit,
    };
    final data = await _client.post('/api/v1/activities', body: payload);
    if (data is Map<String, dynamic>) {
      return ActivityAnalysisResult.fromMap(data);
    }
    throw const ApiException(statusCode: 500, message: 'Invalid activity response format');
  }

  /// GET /api/v1/activities/{user_id}
  Future<List<ActivityRecord>> fetchUserActivities(String userId) async {
    final data = await _client.get('/api/v1/activities/$userId');
    if (data is List) {
      return data
          .map((item) => ActivityRecord.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  /// POST /api/v1/calculate-carbon
  Future<Map<String, dynamic>> calculateCarbon({
    required String category,
    required String activityType,
    required double quantity,
    required String unit,
  }) async {
    final payload = {
      'category': category,
      'activityType': activityType,
      'quantity': quantity,
      'unit': unit,
    };
    final data = await _client.post('/api/v1/calculate-carbon', body: payload);
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ApiException(statusCode: 500, message: 'Invalid carbon response format');
  }

  /// POST /api/v1/recommendations
  Future<List<RecommendationRecord>> fetchRecommendations({String? focusCategory}) async {
    final payload = <String, dynamic>{};
    if (focusCategory != null) {
      payload['focusCategory'] = focusCategory;
    }
    final data = await _client.post('/api/v1/recommendations', body: payload);
    if (data is Map && data['recommendations'] is List) {
      final list = data['recommendations'] as List;
      return list
          .map((item) => RecommendationRecord.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  /// GET /api/v1/leaderboard
  Future<List<LeaderboardEntry>> fetchLeaderboard({int limit = 50}) async {
    final data = await _client.get('/api/v1/leaderboard?limit=$limit');
    if (data is Map && data['leaderboard'] is List) {
      final list = data['leaderboard'] as List;
      return list
          .map((item) => LeaderboardEntry.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  /// GET /api/v1/recycling-centers
  Future<List<RecyclingCenter>> fetchRecyclingCenters({String? material}) async {
    final path = material != null && material.isNotEmpty
        ? '/api/v1/recycling-centers?material=${Uri.encodeComponent(material)}'
        : '/api/v1/recycling-centers';
    final data = await _client.get(path);
    if (data is List) {
      return data
          .map((item) => RecyclingCenter.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }
}

/// Provider for EcoLoopApiService
final apiServiceProvider = Provider<EcoLoopApiService>((ref) {
  return EcoLoopApiService();
});
