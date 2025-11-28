import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Policies
  final String whoCanJoin;
  final String membershipCriteria;
  final String rulesAndRegulations;
  final String electionProcess;
  final String meetingRules;

  // Membership
  final bool isMember;
  final int memberCount;

  // NEW FIELDS
  final String createdBy;           // Creator UID
  final List<String> admins;        // Admin list (UIDs)

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
    this.isMember = false,
    this.memberCount = 0,
    required this.createdBy,
    required this.admins,
  });

  Map<String, dynamic> toMap() {
    return {
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
      'isMember': isMember,
      'memberCount': memberCount,

      // new
      'createdBy': createdBy,
      'admins': admins,
    };
  }

  factory Club.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return Club(
      id: doc.id,
      name: data['name'] ?? '',
      moto: data['moto'] ?? '',
      type: data['type'] ?? 'General',
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
      isMember: data['isMember'] ?? false,
      memberCount: data['memberCount'] ?? 0,

      // new
      createdBy: data['createdBy'] ?? '',
      admins: List<String>.from(data['admins'] ?? []),
    );
  }
}

class ClubMember {
  final String name;
  final String designation;
  final String imageUrl;
  final bool isFaculty;

  ClubMember({
    required this.name,
    required this.designation,
    required this.imageUrl,
    this.isFaculty = false,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'designation': designation,
    'imageUrl': imageUrl,
    'isFaculty': isFaculty,
  };

  factory ClubMember.fromMap(Map data) => ClubMember(
    name: data['name'] ?? '',
    designation: data['designation'] ?? '',
    imageUrl: data['imageUrl'] ?? '',
    isFaculty: data['isFaculty'] ?? false,
  );
}
