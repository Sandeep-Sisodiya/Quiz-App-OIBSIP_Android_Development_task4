import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../models/quiz_model.dart';
import '../services/database_service.dart';

class AvailableQuizzesScreen extends StatelessWidget {
  final _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffa42442),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
        title: Text(
          '👇Avail Quizzes',
          style: GoogleFonts.orbitron(
            textStyle: TextStyle(
              fontSize: size.width * 0.06,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF1F1F1F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            SizedBox(height: 28),
            // Lottie Animation
            Lottie.asset(
              'assets/lottie/Its_a_quiz.json',
              height: size.height * 0.25,
              repeat: true,
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FutureBuilder<List<QuizModel>>(
                future: _dbService.getAllQuizzes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xffa42442)),
                    );
                  }

                  final allQuizzes = snapshot.data ?? [];
                  final quizzes = allQuizzes
                      .where((q) => q.createdBy != currentUid)
                      .toList();

                  if (quizzes.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'No quizzes available.',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: quizzes.map((quiz) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xffa1125a), Color(0xffb9532e)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          title: Text(
                            quiz.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              quiz.description,
                              style: const TextStyle(color: Colors.white60),
                            ),
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.play_circle_outlined),
                                tooltip: 'Attempt Quiz',
                                color: const Color(0xff46b627),
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/attemptQuiz',
                                  arguments: {
                                    'quizId': quiz.id,
                                    'quizTitle': quiz.title,
                                  },
                                ),
                              ),
                              SizedBox(height: 5),
                              IconButton(
                                icon: const Icon(Icons.leaderboard),
                                tooltip: 'Leaderboard',
                                color: Colors.amber,
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/leaderboard',
                                  arguments: quiz.id,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            SizedBox(height: 80,)
          ],
        ),
      ),
    );
  }
}
