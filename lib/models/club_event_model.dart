import 'package:cloud_firestore/cloud_firestore.dart';

class ClubEvent {
  final String id;
  final String title;
  final String? description;
  final String? location;

  final DateTime date;          // Only event date
  final DateTime startTime;     // Only start time
  final DateTime endTime;       // Only end time

  final int? participantLimit;  // number of participants allowed
  final bool registrationRequired;
  final Map<String, dynamic>? registrationForm; // custom fields

  ClubEvent({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.participantLimit,
    this.registrationRequired = false,
    this.registrationForm,
  });

  /// Helper to parse timestamp OR ISO string OR DateTime
  static DateTime parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    throw FormatException('Unsupported date format: ${value.runtimeType}');
  }

  /// ------- FIRESTORE FROM MAP -------
  factory ClubEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ClubEvent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      location: data['location'],
      date: parseDate(data['date']),
      startTime: parseDate(data['startTime']),
      endTime: parseDate(data['endTime']),
      participantLimit: data['participantLimit'],
      registrationRequired: data['registrationRequired'] ?? false,
      registrationForm: data['registrationForm'],
    );
  }

  /// ------- FIRESTORE TO MAP -------
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'participantLimit': participantLimit,
      'registrationRequired': registrationRequired,
      'registrationForm': registrationForm,
    };
  }
}
