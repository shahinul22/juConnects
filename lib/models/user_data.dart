// lib/models/user_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final String bloodGroup;
  final String hall;
  final String idNumber;
  final String department;
  final String session;
  final String roll;
  final String school;
  final String college;
  final String address;
  final String phoneNumber;
  final String facebookId;
  final String whatsapp;
  final String instagram;
  final String profilePicUrl;
  final String coverPicUrl;

  UserData({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.bloodGroup,
    required this.hall,
    required this.idNumber,
    required this.department,
    required this.session,
    required this.roll,
    required this.school,
    required this.college,
    required this.address,
    required this.phoneNumber,
    required this.facebookId,
    required this.whatsapp,
    required this.instagram,
    required this.profilePicUrl,
    required this.coverPicUrl,
  });

  factory UserData.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return UserData(
      uid: doc.id,
      fullName: data['fullName'] ?? 'N/A',
      email: data['email'] ?? 'N/A',
      role: data['role'] ?? 'Student',
      bloodGroup: data['bloodGroup'] ?? 'N/A',
      hall: data['hall'] ?? 'N/A',
      idNumber: data['idNumber'] ?? 'N/A',
      department: data['department'] ?? 'N/A',
      session: data['session'] ?? 'N/A',
      roll: data['roll'] ?? '',
      school: data['school'] ?? '',
      college: data['college'] ?? '',
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      facebookId: data['facebookId'] ?? '',
      whatsapp: data['whatsapp'] ?? '',
      instagram: data['instagram'] ?? '',
      profilePicUrl: data['profilePicUrl'] ??
          'https://i.imgur.com/8x8gK4h.png',
      coverPicUrl: data['coverPicUrl'] ??
          'https://i.imgur.com/9k0JzGZ.png',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'role': role,
      'bloodGroup': bloodGroup,
      'hall': hall,
      'idNumber': idNumber,
      'department': department,
      'session': session,
      'roll': roll,
      'school': school,
      'college': college,
      'address': address,
      'phoneNumber': phoneNumber,
      'facebookId': facebookId,
      'whatsapp': whatsapp,
      'instagram': instagram,
      'profilePicUrl': profilePicUrl,
      'coverPicUrl': coverPicUrl,
    };
  }
}
