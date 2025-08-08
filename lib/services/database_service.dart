import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    await _db.collection(Constants.USERS).doc(user.uid).set(user.toMap());
  }

  Future<void> createQuiz({
    required String title,
    required String description,
    required String createdBy,
    required List<Map<String, dynamic>> questions,
  }) async {
    DocumentReference quizRef = await _db.collection(Constants.QUIZZES).add({
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'timestamp': FieldValue.serverTimestamp(),
    });
    String quizId = quizRef.id;
    for (var q in questions) {
      await _db
          .collection(Constants.QUIZZES)
          .doc(quizId)
          .collection(Constants.QUESTIONS)
          .add(q);
    }
  }

  Future<List<QuizModel>> getAllQuizzes() async {
    QuerySnapshot snap = await _db.collection(Constants.QUIZZES).get();
    return snap.docs.map((d) => QuizModel.fromDocument(d)).toList();
  }

  Future<List<Map<String, dynamic>>> getQuizQuestions(String quizId) async {
    QuerySnapshot snap = await _db
        .collection(Constants.QUIZZES)
        .doc(quizId)
        .collection(Constants.QUESTIONS)
        .get();
    return snap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
  }
  Future<void> addQuizAttempt({
    required String quizId,
    required String quizTitle,
    required int score,
    required int totalQuestions,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection(Constants.ATTEMPTS)
        .add({
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': user.uid,
      'userEmail': user.email,
    });
  }

  Future<List<Map<String, dynamic>>> getUserAttempts(String userId) async {
    try {
      print('DatabaseService.getUserAttempts → querying for userId: $userId');
      QuerySnapshot snap = await _db
          .collection(Constants.ATTEMPTS)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      print('DatabaseService.getUserAttempts → fetched ${snap.docs.length} docs');
      return snap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('DatabaseService.getUserAttempts ERROR: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTopScoresForQuiz(String quizId) async {
    try {
      print('🔍 getTopScoresForQuiz → querying for quizId: $quizId');
      QuerySnapshot snap = await _db
          .collection(Constants.ATTEMPTS)
          .where('quizId', isEqualTo: quizId)
          .orderBy('score', descending: true)
          .limit(10)
          .get();
      print('✅ getTopScoresForQuiz → fetched ${snap.docs.length} docs for $quizId');
      return snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        print('   • ${d.id}: $data');
        return data;
      }).toList();
    } catch (e) {
      print('❌ getTopScoresForQuiz ERROR for $quizId: $e');
      return [];
    }
  }

  /// Fetch all quizzes created by a specific user
  Future<List<QuizModel>> getUserQuizzes(String userId) async {
    try {
      print('🔍 getUserQuizzes → querying for createdBy: $userId');
      // Remove orderBy to avoid index requirement; we'll sort in code
      QuerySnapshot snap = await _db
          .collection(Constants.QUIZZES)
          .where('createdBy', isEqualTo: userId)
          .get();

      print('✅ getUserQuizzes → fetched ${snap.docs.length} docs');
      List<QuizModel> list = snap.docs.map((d) {
        final quiz = QuizModel.fromDocument(d);
        print('   • quiz ${quiz.id}: createdBy=${quiz.createdBy}');
        return quiz;
      }).toList();

      // Sort by timestamp descending client‐side
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return list;
    } catch (e) {
      print('❌ getUserQuizzes ERROR: $e');
      return [];
    }
  }


  /// Delete a quiz and all its questions subcollection
  Future<void> deleteQuiz(String quizId) async {
    final quizRef = _db.collection(Constants.QUIZZES).doc(quizId);
    final qSnap = await quizRef.collection(Constants.QUESTIONS).get();
    for (var doc in qSnap.docs) {
      await quizRef.collection(Constants.QUESTIONS).doc(doc.id).delete();
    }
    await quizRef.delete();
    print('✅ Deleted quiz $quizId and its questions');
  }

  Future<void> updateQuiz({
    required String quizId,
    required String title,
    required String description,
    required List<Map<String, dynamic>> questions,
  }) async {
    final quizRef = _db.collection(Constants.QUIZZES).doc(quizId);

    await quizRef.update({
      'title': title,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final oldQs = await quizRef.collection(Constants.QUESTIONS).get();
    for (var doc in oldQs.docs) {
      await quizRef.collection(Constants.QUESTIONS).doc(doc.id).delete();
    }

    for (var q in questions) {
      await quizRef.collection(Constants.QUESTIONS).add(q);
    }

    print('✅ Updated quiz $quizId');
  }


}
