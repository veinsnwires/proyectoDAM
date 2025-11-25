import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final String category; // Stores the name: "Charla", "Workshop"
  final String userId; // The author's UID

  Event({
    this.id = '',
    required this.title,
    required this.date,
    required this.location,
    required this.category,
    required this.userId,
  });

  // 1. READ: From Firebase (Map) -> To App (Event)
  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Event(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      // Critical conversion: Timestamp -> DateTime
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? 'No Location',
      category: data['category'] ?? 'General',
      userId: data['userId'] ?? '',
    );
  }

  // 2. WRITE: From App (Event) -> To Firebase (Map)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(
          date), // Critical conversion: DateTime -> Timestamp
      'location': location,
      'category': category,
      'userId': userId,
    };
  }
}
