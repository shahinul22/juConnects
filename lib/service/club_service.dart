import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/club_model.dart';

class ClubService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a new Club
  Future<void> createClub(Club club) async {
    await _db.collection('clubs').doc(club.id).set(club.toMap());
  }

  // Add an Executive Member (President, Advisor, etc.)
  Future<void> addMember(String clubId, ClubMember member) async {
    await _db.collection('clubs').doc(clubId).collection('executives').add(member.toMap());
  }

  // Get All Clubs Stream
  Stream<List<Club>> getClubs() {
    return _db.collection('clubs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Club.fromFirestore(doc)).toList();
    });
  }

  // Get Executives Stream
  Stream<List<ClubMember>> getExecutives(String clubId) {
    return _db.collection('clubs').doc(clubId).collection('executives')
    // Optional: Order by rank if you add a 'rank' field
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ClubMember.fromMap(doc.data())).toList();
    });
  }
}