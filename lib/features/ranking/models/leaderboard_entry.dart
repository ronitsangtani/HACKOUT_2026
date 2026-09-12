/// Model representing a user's entry on the community leaderboard.
class LeaderboardEntry {
  final int rank;
  final String uid;
  final String name;
  final String city;
  final int ecoPoints;
  final double co2SavedKg;
  final int streak;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.uid,
    required this.name,
    required this.city,
    required this.ecoPoints,
    required this.co2SavedKg,
    required this.streak,
    required this.isCurrentUser,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      rank: (map['rank'] as num?)?.toInt() ?? 1,
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? 'Eco Member',
      city: map['city'] as String? ?? 'India',
      ecoPoints: (map['ecoPoints'] as num?)?.toInt() ?? 0,
      co2SavedKg: (map['co2SavedKg'] as num?)?.toDouble() ?? 0.0,
      streak: (map['streak'] as num?)?.toInt() ?? 1,
      isCurrentUser: map['isCurrentUser'] as bool? ?? false,
    );
  }
}
