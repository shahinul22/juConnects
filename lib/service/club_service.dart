import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/club_model.dart';
import '../models/club_event_model.dart';


class ClubService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -----------------------------
  // CREATE CLUB
  // -----------------------------
  Future<void> createClub(Club club) async {
    await _db.collection("clubs").doc(club.id).set(club.toMap());
  }

  // -----------------------------
  // UPDATE CLUB
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
  // GET MEMBERS
  // -----------------------------
  Stream<List<ClubMember>> getMembers(String clubId) {
    return _db
        .collection("clubs")
        .doc(clubId)
        .collection("members")
        .where("leaveDate", isNull: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => ClubMember.fromFirestore(doc)).toList());
  }

  Stream<List<ClubMember>> getPreviousMembers(String clubId) {
    return _db
        .collection("clubs")
        .doc(clubId)
        .collection("members")
        .where("leaveDate", isNull: false)
        .orderBy("leaveDate", descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => ClubMember.fromFirestore(doc)).toList());
  }

  // -----------------------------
  // GET ADVISORS
  // -----------------------------
  Stream<List<ClubAdvisor>> getAdvisors(String clubId) {
    return _db
        .collection("clubs")
        .doc(clubId)
        .collection("advisors")
        .where("leaveDate", isNull: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => ClubAdvisor.fromFirestore(doc)).toList());
  }

  Stream<List<ClubAdvisor>> getPreviousAdvisors(String clubId) {
    return _db
        .collection("clubs")
        .doc(clubId)
        .collection("advisors")
        .where("leaveDate", isNull: false)
        .orderBy("leaveDate", descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => ClubAdvisor.fromFirestore(doc)).toList());
  }

  // -----------------------------
  // ADD MEMBER
  // -----------------------------
  Future<void> addMember({
    required String clubId,
    required ClubMember member,
  }) async {
    final clubRef = _db.collection("clubs").doc(clubId);
    final userRef = _db.collection("users").doc(member.uid);

    final memberMap = member.toMap();

    // Ensure joinDate exists
    if (memberMap['joinDate'] == null ||
        (memberMap['joinDate'] as String).isEmpty) {
      memberMap['joinDate'] = DateTime.now().toIso8601String();
    }

    await clubRef
        .collection("members")
        .doc(member.uid)
        .set(memberMap, SetOptions(merge: true));

    await clubRef.update({"memberCount": FieldValue.increment(1)});

    // Update user document
    await userRef.update({
      "clubRole": member.designation,
      "clubId": clubId,
      "clubs": FieldValue.arrayUnion([
        {
          "clubId": clubId,
          "clubName": (await clubRef.get()).data()?['name'] ?? "Unknown Club",
          "role": member.designation
        }
      ])
    });

    // Promote to admin if executive
    if (_isAdminRole(member.designation)) {
      await promoteAdmin(clubId, member.uid);
    }

    // Add UID to members list
    await clubRef.update({
      "members": FieldValue.arrayUnion([member.uid])
    });
  }

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

  Future<void> promoteAdmin(String clubId, String uid) async {
    await _db.collection("clubs").doc(clubId).update({
      "admins": FieldValue.arrayUnion([uid]),
    });
  }

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
    if (advisorMap['joinDate'] == null ||
        (advisorMap['joinDate'] as String).isEmpty) {
      advisorMap['joinDate'] = DateTime.now().toIso8601String();
    }

    await _db
        .collection("clubs")
        .doc(clubId)
        .collection("advisors")
        .add(advisorMap);
  }

  // -----------------------------
  // JOIN CLUB (instant)
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
  // REMOVE MEMBER
  // -----------------------------
  Future<void> removeMember({
    required String clubId,
    required String uid,
  }) async {
    final clubRef = _db.collection("clubs").doc(clubId);
    final userRef = _db.collection("users").doc(uid);
    final memberSnap = await clubRef.collection("members").doc(uid).get();
    final role =
        (memberSnap.data()?['designation'] ?? "Member") as String? ?? "Member";
    final clubName = (await clubRef.get()).data()?['name'] ?? "Unknown Club";

    await memberSnap.reference.update({
      "leaveDate": DateTime.now().toIso8601String(),
    });

    await clubRef.update({
      "memberCount": FieldValue.increment(-1),
      "admins": FieldValue.arrayRemove([uid]),
      "members": FieldValue.arrayRemove([uid]),
    });

    await userRef.update({
      "clubs": FieldValue.arrayRemove([
        {"clubId": clubId, "clubName": clubName, "role": role}
      ]),
      "clubRole": FieldValue.delete(),
      "clubId": FieldValue.delete(),
    });
  }

  Future<void> removeAdvisor({
    required String clubId,
    required String advisorId,
  }) async {
    final advisorRef = _db
        .collection("clubs")
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

    await memberRef.update({'designation': newRole});

    if (_isAdminRole(newRole)) {
      await promoteAdmin(clubId, uid);
    } else {
      await demoteAdmin(clubId, uid);
    }

    await _db.collection('users').doc(uid).update({'clubRole': newRole});
  }

  Stream<List<ClubMember>> getExecutives(String clubId) {
    const roles = [
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
        .where((m) => roles.contains(m.designation))
        .toList());
  }

  // -----------------------------
  // TOGGLE JOIN BUTTON
  // -----------------------------
  Future<void> toggleJoinButton(String clubId, bool value) async {
    await _db
        .collection('clubs')
        .doc(clubId)
        .update({'joinButtonEnabled': value});
  }

  // -----------------------------
  // MEMBERSHIP REQUESTS
  // -----------------------------
  Future<void> sendJoinRequest({
    required String clubId,
    required String uid,
    required String name,
    required String email,
    required String image,
    required String department,
    required String session,
    required String studentId,
    required String hall,
    required String phone,
  }) async {
    final reqRef = _db
        .collection('clubs')
        .doc(clubId)
        .collection('membership_requests')
        .doc(uid);

    await reqRef.set({
      'uid': uid,
      'name': name,
      'email': email,
      'image': image,
      'department': department,
      'session': session,
      'studentId': studentId,
      'hall': hall,
      'phone': phone,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<Map<String, dynamic>>> getJoinRequests(String clubId) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('membership_requests')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  Future<void> approveRequest({
    required String clubId,
    required String uid,
    String designation = "Member",
  }) async {
    final reqRef = _db
        .collection('clubs')
        .doc(clubId)
        .collection('membership_requests')
        .doc(uid);

    final reqSnap = await reqRef.get();
    if (!reqSnap.exists) return;

    final data = reqSnap.data()!;
    final member = ClubMember(
      uid: data['uid'] ?? uid,
      name: data['name'] ?? '',
      imageUrl: data['image'] ?? '',
      designation: designation,
      joinDate: DateTime.now(),
    );

    await addMember(clubId: clubId, member: member);
    await reqRef.delete();
  }

  Future<void> rejectRequest({
    required String clubId,
    required String uid,
  }) async {
    final reqRef = _db
        .collection('clubs')
        .doc(clubId)
        .collection('membership_requests')
        .doc(uid);

    await reqRef.delete();
  }

  // -----------------------------
  // EVENT MANAGEMENT
  // -----------------------------
  // -----------------------------
// EVENT MANAGEMENT
// -----------------------------
  Future<void> createEvent({
    required String clubId,
    required ClubEvent event,
  }) async {
    final eventsRef = _db.collection('clubs').doc(clubId).collection('events');
    await eventsRef.add(event.toMap());
  }

  Stream<List<ClubEvent>> getEvents(String clubId, {String? type}) {
    Query<Map<String, dynamic>> coll = _db.collection('clubs').doc(clubId).collection('events');
    if (type != null) coll = coll.where('type', isEqualTo: type); // fixed

    return coll.snapshots().map(
          (snap) => snap.docs.map((doc) => ClubEvent.fromFirestore(doc)).toList(),
    );
  }

  // -----------------------------
  // REGISTER FOR EVENT
  // -----------------------------
  Future<void> registerForEvent({
    required String clubId,
    required String eventId,
    required String userId,
  }) async {
    final eventRef =
    _db.collection('clubs').doc(clubId).collection('events').doc(eventId);

    final eventSnap = await eventRef.get();
    if (!eventSnap.exists) throw Exception("Event not found");

    final event = ClubEvent.fromFirestore(eventSnap);

    // Check participant limit
    final currentParticipants = event.registrationForm?.length ?? 0;
    if (event.participantLimit != null &&
        currentParticipants >= event.participantLimit!) {
      throw Exception("Participant limit reached");
    }

    // Update registration map in Firestore
    final registration = event.registrationForm ?? {};
    registration[userId] = {
      "userId": userId,
      "timestamp": FieldValue.serverTimestamp(),
    };

    await eventRef.update({"registrationForm": registration});
  }

  Future<void> unregisterFromEvent({
    required String clubId,
    required String eventId,
    required String userId,
  }) async {
    final eventRef =
    _db.collection('clubs').doc(clubId).collection('events').doc(eventId);

    final eventSnap = await eventRef.get();
    if (!eventSnap.exists) throw Exception("Event not found");

    final event = ClubEvent.fromFirestore(eventSnap);
    final registration = event.registrationForm ?? {};
    registration.remove(userId);

    await eventRef.update({"registrationForm": registration});
  }

  // -----------------------------
  // GET MEMBERS OF EVENT
  // -----------------------------
  Future<List<String>> getEventParticipants({
    required String clubId,
    required String eventId,
  }) async {
    final eventRef =
    _db.collection('clubs').doc(clubId).collection('events').doc(eventId);
    final snap = await eventRef.get();
    if (!snap.exists) return [];

    final event = ClubEvent.fromFirestore(snap);
    return event.registrationForm?.keys.toList() ?? [];
  }


}
