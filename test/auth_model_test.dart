import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoloop/features/auth/models/user_model.dart';
import 'package:ecoloop/models/firestore_models.dart';

void main() {
  group('UserModel Phase 4 Tests', () {
    test('toMap and fromMap serialize all 8 Firestore fields', () {
      final now = DateTime(2026, 9, 12, 10, 30);
      final user = UserModel(
        uid: 'user123',
        name: 'Eco Warrior',
        email: 'eco@example.com',
        city: 'Bengaluru, India',
        carbonGoal: 'Reduce footprint by 25% by Dec 2026',
        ecoPoints: 120,
        streak: 5,
        createdAt: now,
      );

      final map = user.toMap();
      expect(map['uid'], 'user123');
      expect(map['name'], 'Eco Warrior');
      expect(map['email'], 'eco@example.com');
      expect(map['city'], 'Bengaluru, India');
      expect(map['carbonGoal'], 'Reduce footprint by 25% by Dec 2026');
      expect(map['ecoPoints'], 120);
      expect(map['streak'], 5);
      expect(map['createdAt'], isA<Timestamp>());

      final deserialized = UserModel.fromMap(map);
      expect(deserialized.uid, 'user123');
      expect(deserialized.ecoPoints, 120);
      expect(deserialized.streak, 5);
      expect(deserialized, equals(user));
    });
  });

  group('Firestore Collections Models Tests', () {
    test('ActivityRecord serializes properly with Firebase UID', () {
      final now = DateTime(2026, 9, 12, 11, 00);
      final activity = ActivityRecord(
        activityId: 'act_001',
        userId: 'user_xyz',
        category: 'transport',
        activityType: 'Metro Commute',
        quantity: 15.0,
        unit: 'km',
        co2Kg: 0.75,
        createdAt: now,
      );

      final map = activity.toMap();
      expect(map['activityId'], 'act_001');
      expect(map['userId'], 'user_xyz');
      expect(map['category'], 'transport');
      expect(map['co2Kg'], 0.75);

      final fromMap = ActivityRecord.fromMap(map);
      expect(fromMap.activityId, 'act_001');
      expect(fromMap.userId, 'user_xyz');
      expect(fromMap.quantity, 15.0);
    });

    test('UserActionRecord and RewardRecord serialize properly', () {
      final now = DateTime(2026, 9, 12, 11, 00);
      final userAction = UserActionRecord(
        actionId: 'act_101',
        userId: 'user_xyz',
        recommendationId: 'rec_501',
        status: 'completed',
        co2Saved: 18.5,
        pointsEarned: 50,
        completedAt: now,
      );

      final map = userAction.toMap();
      expect(map['userId'], 'user_xyz');
      expect(map['status'], 'completed');
      expect(map['pointsEarned'], 50);

      final reward = RewardRecord(
        rewardId: 'rew_001',
        userId: 'user_xyz',
        points: 50,
        reason: 'First repair completed',
        createdAt: now,
      );
      final rewardMap = reward.toMap();
      expect(rewardMap['userId'], 'user_xyz');
      expect(rewardMap['points'], 50);
    });
  });
}
