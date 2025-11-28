import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/club_model.dart';

class ClubService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create Club
  Future<void> createClub(Club club) async {
    await _db.collection('clubs').doc(club.id).set(club.toMap());
  }

  // Update Club (Admins Only)
  Future<void> updateClub(String clubId, Map<String, dynamic> data) async {
    await _db.collection('clubs').doc(clubId).update(data);
  }

  // Get Clubs
  Stream<List<Club>> getClubs() {
    return _db.collection('clubs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Club.fromFirestore(doc)).toList();
    });
  }

  // Executives
  Stream<List<ClubMember>> getExecutives(String clubId) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('executives')
        .snapshots()
        .map((s) => s.docs.map((d) => ClubMember.fromMap(d.data())).toList());
  }
}
