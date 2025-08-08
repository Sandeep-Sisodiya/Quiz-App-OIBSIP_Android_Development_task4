import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final Timestamp timestamp;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.timestamp,
  });

  // Convert QuizModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'timestamp': timestamp,
    };
  }

  // Create a QuizModel from a Firestore document snapshot
  factory QuizModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdBy: data['createdBy'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
