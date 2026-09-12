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

  static const List<LeaderboardEntry> mockEntries = [
    LeaderboardEntry(
      rank: 1,
      uid: 'user_mock_1',
      name: 'Aarav Sharma',
      city: 'Bengaluru',
      ecoPoints: 3420,
      co2SavedKg: 142.5,
      streak: 14,
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 2,
      uid: 'user_mock_2',
      name: 'Diya Patel',
      city: 'Mumbai',
      ecoPoints: 2890,
      co2SavedKg: 118.0,
      streak: 11,
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 3,
      uid: 'user_mock_3',
      name: 'Rohan Verma',
      city: 'Delhi',
      ecoPoints: 2450,
      co2SavedKg: 95.2,
      streak: 8,
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 4,
      uid: 'user_mock_4',
      name: 'Ananya Rao',
      city: 'Hyderabad',
      ecoPoints: 1980,
      co2SavedKg: 78.4,
      streak: 6,
      isCurrentUser: false,
    ),
    LeaderboardEntry(
      rank: 5,
      uid: 'user_mock_5',
      name: 'Kabir Mehta',
      city: 'Pune',
      ecoPoints: 1650,
      co2SavedKg: 64.0,
      streak: 5,
      isCurrentUser: false,
    ),
  ];
}
