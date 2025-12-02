import 'package:cloud_firestore/cloud_firestore.dart';

// =====================================================
// CLUB MODEL
// =====================================================
class Club {
  final String id;
  final String name;
  final String moto;
  final String type;
  final String logoUrl;
  final String bannerUrl;
  final String description;
  final String mission;
  final String vision;

  final String whoCanJoin;
  final String membershipCriteria;
  final String rulesAndRegulations;
  final String electionProcess;
  final String meetingRules;

  final int memberCount;
  final List<String> admins;
  final String createdBy;
  final bool recruitmentOpen;

  bool isMember;

  /// NEW: toggle controlled by admins to expose "Join" button to users
  final bool joinButtonEnabled;

  /// NEW: list of uids (keeps quick membership checks if you prefer)
  final List<String> members;

  Club({
    required this.id,
    required this.name,
    required this.moto,
    required this.type,
    required this.logoUrl,
    required this.bannerUrl,
    required this.description,
    required this.mission,
    required this.vision,
    required this.whoCanJoin,
    required this.membershipCriteria,
    required this.rulesAndRegulations,
    required this.electionProcess,
    required this.meetingRules,
    required this.memberCount,
    required this.admins,
    required this.createdBy,
    this.recruitmentOpen = false,
    this.isMember = false,
    this.joinButtonEnabled = false,
    this.members = const [],
  });

  // =========================================
  // toMap() METHOD
  // =========================================
  Map<String, dynamic> toMap() => {
    'name': name,
    'moto': moto,
    'type': type,
    'logoUrl': logoUrl,
    'bannerUrl': bannerUrl,
    'description': description,
    'mission': mission,
    'vision': vision,
    'whoCanJoin': whoCanJoin,
    'membershipCriteria': membershipCriteria,
    'rulesAndRegulations': rulesAndRegulations,
    'electionProcess': electionProcess,
    'meetingRules': meetingRules,
    'memberCount': memberCount,
    'admins': admins,
    'createdBy': createdBy,
    'recruitmentOpen': recruitmentOpen,
    'isMember': isMember,
    // NEW FIELDS
    'joinButtonEnabled': joinButtonEnabled,
    'members': members,
  };

  factory Club.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Club(
      id: doc.id,
      name: data['name'] ?? '',
      moto: data['moto'] ?? '',
      type: data['type'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      bannerUrl: data['bannerUrl'] ?? '',
      description: data['description'] ?? '',
      mission: data['mission'] ?? '',
      vision: data['vision'] ?? '',
      whoCanJoin: data['whoCanJoin'] ?? '',
      membershipCriteria: data['membershipCriteria'] ?? '',
      rulesAndRegulations: data['rulesAndRegulations'] ?? '',
      electionProcess: data['electionProcess'] ?? '',
      meetingRules: data['meetingRules'] ?? '',
      memberCount: data['memberCount'] ?? 0,
      admins: List<String>.from(data['admins'] ?? []),
      createdBy: data['createdBy'] ?? '',
      recruitmentOpen: data['recruitmentOpen'] ?? false,
      isMember: data['isMember'] ?? false,
      // NEW FIELDS with safe defaults
      joinButtonEnabled: data['joinButtonEnabled'] ?? false,
      members: List<String>.from(data['members'] ?? []),
    );
  }
}

// =====================================================
// CLUB MEMBER MODEL
// =====================================================
class ClubMember {
  final String uid;
  final String name;
  final String imageUrl;
  final String designation;
  final DateTime joinDate;
  final DateTime? leaveDate;

  ClubMember({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.designation,
    required this.joinDate,
    this.leaveDate,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'imageUrl': imageUrl,
    'designation': designation,
    'joinDate': joinDate.toIso8601String(),
    'leaveDate': leaveDate?.toIso8601String(),
  };

  factory ClubMember.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ClubMember(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      designation: data['designation'] ?? '',
      joinDate: _toDate(data['joinDate']),
      leaveDate:
      data['leaveDate'] != null ? _toDate(data['leaveDate']) : null,
    );
  }
}

// =====================================================
// ADVISOR MODEL
// =====================================================
class ClubAdvisor {
  final String name;
  final String designation;
  final String department;
  final String imageUrl;
  final bool isFaculty;

  final DateTime joinDate;
  final DateTime? leaveDate;

  ClubAdvisor({
    required this.name,
    required this.designation,
    required this.department,
    required this.imageUrl,
    required this.isFaculty,
    required this.joinDate,
    this.leaveDate,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'designation': designation,
    'department': department,
    'imageUrl': imageUrl,
    'isFaculty': isFaculty,
    'joinDate': joinDate.toIso8601String(),
    'leaveDate': leaveDate?.toIso8601String(),
  };

  factory ClubAdvisor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ClubAdvisor(
      name: data['name'] ?? '',
      designation: data['designation'] ?? '',
      department: data['department'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isFaculty: data['isFaculty'] ?? false,
      joinDate: _toDate(data['joinDate']),
      leaveDate:
      data['leaveDate'] != null ? _toDate(data['leaveDate']) : null,
    );
  }
}

// =====================================================
// DateTime FIX FUNCTION (supports Firestore Timestamp)
// =====================================================
DateTime _toDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}
