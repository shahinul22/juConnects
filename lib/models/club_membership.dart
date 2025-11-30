class ClubMembership {
  final String clubId;    // Store the club ID
  final String clubName;  // Display name of the club
  final String role;      // Role of the user in that club

  ClubMembership({
    required this.clubId,
    required this.clubName,
    required this.role,
  });

  factory ClubMembership.fromMap(Map<String, dynamic> map) {
    return ClubMembership(
      clubId: map['clubId'] ?? '',
      clubName: map['clubName'] ?? 'Unknown Club',
      role: map['role'] ?? 'Member',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clubId': clubId,
      'clubName': clubName,
      'role': role,
    };
  }
}
