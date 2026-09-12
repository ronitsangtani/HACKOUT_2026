import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  /// GET /api/v1/leaderboard with resilient hybrid fallback to Cloud Firestore & community champions
  Future<List<LeaderboardEntry>> fetchLeaderboard({int limit = 50}) async {
    // 1. Attempt FastAPI backend fetch
    try {
      final data = await _client.get('/api/v1/leaderboard?limit=$limit');
      if (data is Map && data['leaderboard'] is List) {
        final list = data['leaderboard'] as List;
        final entries = list
            .map((item) => LeaderboardEntry.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
        if (entries.isNotEmpty) return entries;
      }
    } catch (_) {
      // Backend not running or unreachable — gracefully fallback to Firestore
    }

    // 2. Query Cloud Firestore 'users' collection
    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('ecoPoints', descending: true)
          .limit(limit)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final List<LeaderboardEntry> firestoreEntries = [];
        int currentRank = 1;
        int? prevPoints;

        for (int i = 0; i < snapshot.docs.length; i++) {
          final doc = snapshot.docs[i];
          final data = doc.data();
          final uid = data['uid'] as String? ?? doc.id;
          final name = data['name'] as String? ?? 'Eco Member';
          final city = data['city'] as String? ?? 'India';
          final ecoPoints = (data['ecoPoints'] as num?)?.toInt() ?? 0;
          final streak = (data['streak'] as num?)?.toInt() ?? 1;

          if (prevPoints != null && ecoPoints < prevPoints) {
            currentRank = i + 1;
          }
          prevPoints = ecoPoints;

          firestoreEntries.add(LeaderboardEntry(
            rank: currentRank,
            uid: uid,
            name: name,
            city: city,
            ecoPoints: ecoPoints,
            co2SavedKg: (ecoPoints * 0.12).clamp(0.0, 9999.0),
            streak: streak,
            isCurrentUser: currentUid != null && uid == currentUid,
          ));
        }

        if (firestoreEntries.length >= 3) {
          return firestoreEntries;
        }

        // If only 1 or 2 users in Firestore, merge with mock champions
        final currentUserEntry = firestoreEntries.firstWhere(
          (e) => e.isCurrentUser,
          orElse: () => firestoreEntries.first,
        );
        return _mergeWithMockChampions(currentUserEntry);
      }
    } catch (_) {
      // Firestore offline or permission issue
    }

    // 3. Fallback: Return mock community champions with personalized current user
    return _buildMockLeaderboardWithCurrentUser();
  }

  List<LeaderboardEntry> _mergeWithMockChampions(LeaderboardEntry myEntry) {
    final list = [
      ...LeaderboardEntry.mockEntries.where((e) => e.uid != myEntry.uid),
      myEntry,
    ];
    list.sort((a, b) => b.ecoPoints.compareTo(a.ecoPoints));

    final List<LeaderboardEntry> ranked = [];
    int rank = 1;
    for (int i = 0; i < list.length; i++) {
      if (i > 0 && list[i].ecoPoints < list[i - 1].ecoPoints) {
        rank = i + 1;
      }
      final e = list[i];
      ranked.add(LeaderboardEntry(
        rank: rank,
        uid: e.uid,
        name: e.name,
        city: e.city,
        ecoPoints: e.ecoPoints,
        co2SavedKg: e.co2SavedKg,
        streak: e.streak,
        isCurrentUser: e.isCurrentUser,
      ));
    }
    return ranked;
  }

  List<LeaderboardEntry> _buildMockLeaderboardWithCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    final currentUid = user?.uid ?? 'current_user';
    final currentName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : 'Eco Champion';

    final myEntry = LeaderboardEntry(
      rank: 4,
      uid: currentUid,
      name: currentName,
      city: 'Bengaluru',
      ecoPoints: 2150,
      co2SavedKg: 86.0,
      streak: 7,
      isCurrentUser: true,
    );

    return _mergeWithMockChampions(myEntry);
  }

  /// GET /api/v1/recycling-centers with graceful mock fallback
  Future<List<RecyclingCenter>> fetchRecyclingCenters({String? material}) async {
    try {
      final path = material != null && material.isNotEmpty
          ? '/api/v1/recycling-centers?material=${Uri.encodeComponent(material)}'
          : '/api/v1/recycling-centers';
      final data = await _client.get(path);
      if (data is List) {
        final list = data
            .map((item) => RecyclingCenter.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {
      // Backend offline
    }
    return RecyclingCenter.mockCenters;
  }
}

/// Provider for EcoLoopApiService
final apiServiceProvider = Provider<EcoLoopApiService>((ref) {
  return EcoLoopApiService();
});
