import 'package:cloud_firestore/cloud_firestore.dart';

/// 1. Activity Record: Stored in `activities/{activityId}`
class ActivityRecord {
  final String activityId;
  final String userId; // Firebase Auth UID
  final String category; // transport, energy, shopping, waste
  final String activityType;
  final double quantity;
  final String unit;
  final double co2Kg;
  final DateTime createdAt;

  const ActivityRecord({
    required this.activityId,
    required this.userId,
    required this.category,
    required this.activityType,
    required this.quantity,
    required this.unit,
    required this.co2Kg,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'activityId': activityId,
      'userId': userId,
      'category': category,
      'activityType': activityType,
      'quantity': quantity,
      'unit': unit,
      'co2Kg': co2Kg,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ActivityRecord.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parsedCreatedAt;
    final raw = map['createdAt'];
    if (raw is Timestamp) {
      parsedCreatedAt = raw.toDate();
    } else if (raw is String) {
      parsedCreatedAt = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return ActivityRecord(
      activityId: docId ?? (map['activityId'] as String? ?? ''),
      userId: map['userId'] as String? ?? '',
      category: map['category'] as String? ?? '',
      activityType: map['activityType'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] as String? ?? '',
      co2Kg: (map['co2Kg'] as num?)?.toDouble() ?? 0.0,
      createdAt: parsedCreatedAt,
    );
  }

  factory ActivityRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return ActivityRecord.fromMap(doc.data() ?? {}, docId: doc.id);
  }
}

/// 2. Recommendation Record: Stored in `recommendations/{recommendationId}`
class RecommendationRecord {
  final String recommendationId;
  final String category;
  final String title;
  final String description;
  final String estimatedCo2Saving;
  final String estimatedCostImpact;

  const RecommendationRecord({
    required this.recommendationId,
    required this.category,
    required this.title,
    required this.description,
    required this.estimatedCo2Saving,
    required this.estimatedCostImpact,
  });

  Map<String, dynamic> toMap() {
    return {
      'recommendationId': recommendationId,
      'category': category,
      'title': title,
      'description': description,
      'estimatedCo2Saving': estimatedCo2Saving,
      'estimatedCostImpact': estimatedCostImpact,
    };
  }

  factory RecommendationRecord.fromMap(Map<String, dynamic> map, {String? docId}) {
    return RecommendationRecord(
      recommendationId: docId ?? (map['recommendationId'] as String? ?? ''),
      category: map['category'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      estimatedCo2Saving: map['estimatedCo2Saving']?.toString() ?? '',
      estimatedCostImpact: map['estimatedCostImpact']?.toString() ?? '',
    );
  }

  factory RecommendationRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return RecommendationRecord.fromMap(doc.data() ?? {}, docId: doc.id);
  }
}

/// 3. User Action Record: Stored in `user_actions/{actionId}`
class UserActionRecord {
  final String actionId;
  final String userId; // Firebase Auth UID
  final String recommendationId;
  final String status; // adopted, completed
  final double co2Saved;
  final int pointsEarned;
  final DateTime completedAt;

  const UserActionRecord({
    required this.actionId,
    required this.userId,
    required this.recommendationId,
    required this.status,
    required this.co2Saved,
    required this.pointsEarned,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'actionId': actionId,
      'userId': userId,
      'recommendationId': recommendationId,
      'status': status,
      'co2Saved': co2Saved,
      'pointsEarned': pointsEarned,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  factory UserActionRecord.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parsedCompletedAt;
    final raw = map['completedAt'];
    if (raw is Timestamp) {
      parsedCompletedAt = raw.toDate();
    } else if (raw is String) {
      parsedCompletedAt = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      parsedCompletedAt = DateTime.now();
    }

    return UserActionRecord(
      actionId: docId ?? (map['actionId'] as String? ?? ''),
      userId: map['userId'] as String? ?? '',
      recommendationId: map['recommendationId'] as String? ?? '',
      status: map['status'] as String? ?? 'adopted',
      co2Saved: (map['co2Saved'] as num?)?.toDouble() ?? 0.0,
      pointsEarned: (map['pointsEarned'] as num?)?.toInt() ?? 0,
      completedAt: parsedCompletedAt,
    );
  }

  factory UserActionRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserActionRecord.fromMap(doc.data() ?? {}, docId: doc.id);
  }
}

/// 4. Reward Record: Stored in `rewards/{rewardId}`
class RewardRecord {
  final String rewardId;
  final String userId; // Firebase Auth UID
  final int points;
  final String reason;
  final DateTime createdAt;

  const RewardRecord({
    required this.rewardId,
    required this.userId,
    required this.points,
    required this.reason,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'rewardId': rewardId,
      'userId': userId,
      'points': points,
      'reason': reason,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RewardRecord.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parsedCreatedAt;
    final raw = map['createdAt'];
    if (raw is Timestamp) {
      parsedCreatedAt = raw.toDate();
    } else if (raw is String) {
      parsedCreatedAt = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return RewardRecord(
      rewardId: docId ?? (map['rewardId'] as String? ?? ''),
      userId: map['userId'] as String? ?? '',
      points: (map['points'] as num?)?.toInt() ?? 0,
      reason: map['reason'] as String? ?? '',
      createdAt: parsedCreatedAt,
    );
  }

  factory RewardRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return RewardRecord.fromMap(doc.data() ?? {}, docId: doc.id);
  }
}

/// 5. Alternative suggestion with estimated carbon reduction
class AlternativeSuggestion {
  final String title;
  final String category;
  final String alternativeType;
  final double estimatedCo2Kg;
  final double co2ReductionKg;
  final double percentageReduction;
  final String explanation;

  const AlternativeSuggestion({
    required this.title,
    required this.category,
    required this.alternativeType,
    required this.estimatedCo2Kg,
    required this.co2ReductionKg,
    required this.percentageReduction,
    required this.explanation,
  });

  factory AlternativeSuggestion.fromMap(Map<String, dynamic> map) {
    return AlternativeSuggestion(
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? '',
      alternativeType: map['alternativeType'] as String? ?? '',
      estimatedCo2Kg: (map['estimatedCo2Kg'] as num?)?.toDouble() ?? 0.0,
      co2ReductionKg: (map['co2ReductionKg'] as num?)?.toDouble() ?? 0.0,
      percentageReduction: (map['percentageReduction'] as num?)?.toDouble() ?? 0.0,
      explanation: map['explanation'] as String? ?? '',
    );
  }
}

/// 6. Analysis response returned when an activity is logged
class ActivityAnalysisResult {
  final ActivityRecord activity;
  final String formulaUsed;
  final List<AlternativeSuggestion> alternatives;

  const ActivityAnalysisResult({
    required this.activity,
    required this.formulaUsed,
    required this.alternatives,
  });

  factory ActivityAnalysisResult.fromMap(Map<String, dynamic> map) {
    final activity = ActivityRecord.fromMap(map);
    final formula = map['formulaUsed'] as String? ?? '';
    final rawAlts = map['alternatives'] as List? ?? [];
    final alts = rawAlts
        .map((a) => AlternativeSuggestion.fromMap(Map<String, dynamic>.from(a as Map)))
        .toList();

    return ActivityAnalysisResult(
      activity: activity,
      formulaUsed: formula,
      alternatives: alts,
    );
  }
}
