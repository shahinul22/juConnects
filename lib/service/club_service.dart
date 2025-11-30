import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/club_model.dart';

class ClubService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -----------------------------
  // CREATE NEW CLUB
  // -----------------------------
  Future<void> createClub(Club club) async {
    await _db.collection("clubs").doc(club.id).set(club.toMap());
  }

  // -----------------------------
  // UPDATE CLUB INFO
  // -----------------------------
  Future<void> updateClub(String clubId, Map<String, dynamic> data) async {
    await _db.collection("clubs").doc(clubId).update(data);
  }

  // -----------------------------
  // GET ALL CLUBS
  // -----------------------------
  Stream<List<Club>> getClubs() {
    return _db.collection("clubs").snapshots().map(
          (snap) => snap.docs.map((doc) => Club.fromFirestore(doc)).toList(),
    );
  }

  // -----------------------------
  // GET ACTIVE CLUB MEMBERS
  // -----------------------------
  Stream<List<ClubMember>> getMembers(String clubId) {
    return _db
        .collection("clubs")
        .doc(clubId)
        .collection("members")
        .where("leaveDate", isNull: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ClubMember.fromFirestore(doc)).toList());
  }

  // -----------------------------
  // GET PREVIOUS MEMBERS
  // -----------------------------
  Stream<List<ClubMember>> getPreviousMembers(String clubId) {
    return _db
        .collection("clubs")
        .doc(clubId)
        .collection("members")
        .where("leaveDate", isNull: false)
        .orderBy("leaveDate", descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ClubMember.fromFirestore(doc)).toList());
  }

  // -----------------------------
  // GET ACTIVE ADVISORS
  // -----------------------------
  Stream<List<ClubAdvisor>> getAdvisors(String clubId) {
    return _db
        .collection("clubs")
        .doc(clubId)
        .collection("advisors")
        .where("leaveDate", isNull: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ClubAdvisor.fromFirestore(doc)).toList());
  }

  // -----------------------------
  // GET PREVIOUS ADVISORS
  // -----------------------------
  Stream<List<ClubAdvisor>> getPreviousAdvisors(String clubId) {
    return _db
        .collection("clubs")
        .doc(clubId)
        .collection("advisors")
        .where("leaveDate", isNull: false)
        .orderBy("leaveDate", descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ClubAdvisor.fromFirestore(doc)).toList());
  }

  // -----------------------------
  // ADD MEMBER (ADMIN OR JOIN)
  // -----------------------------
  Future<void> addMember({
    required String clubId,
    required ClubMember member,
  }) async {
    final clubRef = _db.collection("clubs").doc(clubId);
    final userRef = _db.collection("users").doc(member.uid);

    final memberMap = member.toMap();

    // Ensure joinDate
    if (memberMap['joinDate'] == null || (memberMap['joinDate'] as String).isEmpty) {
      memberMap['joinDate'] = DateTime.now().toIso8601String();
    }

    // 1️⃣ Add member inside club document
    await clubRef.collection("members").doc(member.uid).set(memberMap, SetOptions(merge: true));

    // 2️⃣ Increment member count
    await clubRef.update({"memberCount": FieldValue.increment(1)});

    // 3️⃣ Update user's main fields
    await userRef.update({
      "clubRole": member.designation,
      "clubId": clubId,
    });

    // 4️⃣ Fetch club name
    final clubSnap = await clubRef.get();
    final clubName = clubSnap['clubName'] ?? "Unknown Club";

    // 5️⃣ Add to user.clubs[] list
    final clubEntry = {
      "clubId": clubId,
      "clubName": clubName,
      "role": member.designation,
    };

    await userRef.update({
      "clubs": FieldValue.arrayUnion([clubEntry])
    });

    // 6️⃣ Promote admin if needed
    if (_isAdminRole(member.designation)) {
      await promoteAdmin(clubId, member.uid);
    }
  }

  // -----------------------------
  // CHECK IF ROLE IS ADMIN
  // -----------------------------
  bool _isAdminRole(String role) {
    return [
      "President",
      "Vice President",
      "General Secretary",
      "Joint Secretary",
      "Organizing Secretary",
      "Office Secretary",
      "Treasurer",
    ].contains(role);
  }

  // -----------------------------
  // PROMOTE ADMIN
  // -----------------------------
  Future<void> promoteAdmin(String clubId, String uid) async {
    await _db.collection("clubs").doc(clubId).update({
      "admins": FieldValue.arrayUnion([uid]),
    });
  }

  // -----------------------------
  // DEMOTE ADMIN
  // -----------------------------
  Future<void> demoteAdmin(String clubId, String uid) async {
    await _db.collection("clubs").doc(clubId).update({
      "admins": FieldValue.arrayRemove([uid]),
    });
  }

  // -----------------------------
  // ADD ADVISOR
  // -----------------------------
  Future<void> addAdvisor({
    required String clubId,
    required ClubAdvisor advisor,
  }) async {
    final advisorMap = advisor.toMap();

    if (advisorMap['joinDate'] == null || (advisorMap['joinDate'] as String).isEmpty) {
      advisorMap['joinDate'] = DateTime.now().toIso8601String();
    }

    await _db.collection("clubs").doc(clubId).collection("advisors").add(advisorMap);
  }

  // -----------------------------
  // JOIN CLUB
  // -----------------------------
  Future<void> joinClub({
    required String clubId,
    required String uid,
    required String name,
    required String image,
  }) async {
    final member = ClubMember(
      uid: uid,
      name: name,
      imageUrl: image,
      designation: "Member",
      joinDate: DateTime.now(),
    );

    await addMember(clubId: clubId, member: member);
  }

  // -----------------------------
  // REMOVE MEMBER (with clubs[] removal)
  // -----------------------------
  Future<void> removeMember({
    required String clubId,
    required String uid,
  }) async {
    final clubRef = _db.collection("clubs").doc(clubId);
    final userRef = _db.collection("users").doc(uid);

    // Fetch club info (for removing from list)
    final clubSnap = await clubRef.get();
    final clubName = clubSnap['clubName'] ?? "Unknown Club";

    // Fetch member role
    final memberSnap = await clubRef.collection("members").doc(uid).get();
    final role = memberSnap['designation'] ?? "Member";

    // 1️⃣ Mark leaveDate
    await memberSnap.reference.update({
      "leaveDate": DateTime.now().toIso8601String(),
    });

    // 2️⃣ Decrement member count & remove admin if needed
    await clubRef.update({
      "memberCount": FieldValue.increment(-1),
      "admins": FieldValue.arrayRemove([uid]),
    });

    // 3️⃣ Remove from user clubs[]
    await userRef.update({
      "clubs": FieldValue.arrayRemove([
        {
          "clubId": clubId,
          "clubName": clubName,
          "role": role,
        }
      ]),
      "clubRole": FieldValue.delete(),
      "clubId": FieldValue.delete(),
    });
  }

  // -----------------------------
  // REMOVE ADVISOR
  // -----------------------------
  Future<void> removeAdvisor({
    required String clubId,
    required String advisorId,
  }) async {
    final advisorRef = _db.collection("clubs")
        .doc(clubId)
        .collection("advisors")
        .doc(advisorId);

    await advisorRef.update({
      "leaveDate": DateTime.now().toIso8601String(),
    });
  }

  // -----------------------------
  // UPDATE MEMBER ROLE
  // -----------------------------
  Future<void> updateMemberRole({
    required String clubId,
    required String uid,
    required String newRole,
  }) async {
    final clubRef = _db.collection("clubs").doc(clubId);
    final memberRef = clubRef.collection("members").doc(uid);

    // Update inside club
    await memberRef.update({'designation': newRole});

    // Update admin list
    if (_isAdminRole(newRole)) {
      await clubRef.update({'admins': FieldValue.arrayUnion([uid])});
    } else {
      await clubRef.update({'admins': FieldValue.arrayRemove([uid])});
    }

    // Update user role
    await _db.collection('users').doc(uid).update({'clubRole': newRole});
  }

  // -----------------------------
  // GET EXECUTIVE MEMBERS
  // -----------------------------
  Stream<List<ClubMember>> getExecutives(String clubId) {
    const executiveRoles = [
      "President",
      "Vice President",
      "General Secretary",
      "Joint Secretary",
      "Organizing Secretary",
      "Treasurer"
    ];

    final coll = _db.collection("clubs").doc(clubId).collection("members");

    return coll
        .where("leaveDate", isNull: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ClubMember.fromFirestore(doc))
        .where((m) => executiveRoles.contains(m.designation))
        .toList());
  }
}
