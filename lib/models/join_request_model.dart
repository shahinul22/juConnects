import 'package:cloud_firestore/cloud_firestore.dart';

class JoinRequest {
  final String uid;
  final String name;
  final String email;
  final String image;
  final String hall;
  final String studentId;
  final String department;
  final String session;
  final String phone;
  final DateTime timestamp;
  final String status;

  JoinRequest({
    required this.uid,
    required this.name,
    required this.email,
    required this.image,
    required this.hall,
    required this.studentId,
    required this.department,
    required this.session,
    required this.phone,
    required this.timestamp,
    this.status = "pending",
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "image": image,
      "hall": hall,
      "studentId": studentId,
      "department": department,
      "session": session,
      "phone": phone,
      "timestamp": timestamp.toIso8601String(),
      "status": status,
    };
  }

  factory JoinRequest.fromMap(Map<String, dynamic> data) {
    return JoinRequest(
      uid: data["uid"] ?? "",
      name: data["name"] ?? "",
      email: data["email"] ?? "",
      image: data["image"] ?? "",
      hall: data["hall"] ?? "",
      studentId: data["studentId"] ?? "",
      department: data["department"] ?? "",
      session: data["session"] ?? "",
      phone: data["phone"] ?? "",
      timestamp: DateTime.tryParse(data["timestamp"] ?? "") ?? DateTime.now(),
      status: data["status"] ?? "pending",
    );
  }
}
