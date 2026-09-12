import 'package:cloud_firestore/cloud_firestore.dart';

/// User representation for EcoLoop stored in Cloud Firestore at `users/{uid}`.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String city;
  final String carbonGoal;
  final int ecoPoints;
  final int streak;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.city = 'Bengaluru, India',
    this.carbonGoal = 'Reduce footprint by 25% by Dec 2026',
    this.ecoPoints = 50, // Welcome signup bonus
    this.streak = 1,
    required this.createdAt,
  });

  /// Convert model to a map for Firestore writes.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'city': city,
      'carbonGoal': carbonGoal,
      'ecoPoints': ecoPoints,
      'streak': streak,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create model from Firestore document map.
  factory UserModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parsedCreatedAt;
    final rawCreatedAt = map['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return UserModel(
      uid: docId ?? (map['uid'] as String? ?? ''),
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      city: map['city'] as String? ?? 'Bengaluru, India',
      carbonGoal: map['carbonGoal'] as String? ?? 'Reduce footprint by 25% by Dec 2026',
      ecoPoints: (map['ecoPoints'] as num?)?.toInt() ?? 0,
      streak: (map['streak'] as num?)?.toInt() ?? 1,
      createdAt: parsedCreatedAt,
    );
  }

  /// Create model from Firestore DocumentSnapshot.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel.fromMap(data, docId: doc.id);
  }

  /// Copy with modifications.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? city,
    String? carbonGoal,
    int? ecoPoints,
    int? streak,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      city: city ?? this.city,
      carbonGoal: carbonGoal ?? this.carbonGoal,
      ecoPoints: ecoPoints ?? this.ecoPoints,
      streak: streak ?? this.streak,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.city == city &&
        other.carbonGoal == carbonGoal &&
        other.ecoPoints == ecoPoints &&
        other.streak == streak &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(uid, name, email, city, carbonGoal, ecoPoints, streak, createdAt);

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, email: $email, ecoPoints: $ecoPoints)';
}
