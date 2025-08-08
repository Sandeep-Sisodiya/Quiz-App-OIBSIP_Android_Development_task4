import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class QuizHistoryScreen extends StatefulWidget {
  @override
  _QuizHistoryScreenState createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  final _dbService = DatabaseService();
  late Future<List<Map<String, dynamic>>> _historyFuture;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _historyFuture = _dbService.getUserAttempts(_userId);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
        backgroundColor: const Color(0xffa42442),
        title: Text(
          'My Quiz Attempts',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: size.width * 0.06,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading history',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            final attempts = snapshot.data ?? [];
            if (attempts.isEmpty) {
              return Center(
                child: Text(
                  'No quiz history found.',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                ),
              );
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Image.asset(
                      'assets/icons/attempted.png',
                      width: MediaQuery.of(context).size.width * 0.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    itemCount: attempts.length,
                    itemBuilder: (context, index) {
                      final att = attempts[index];
                      final score = (att['score'] as num).toDouble();
                      final total = (att['totalQuestions'] as num?) ?? 1;
                      final percent = ((score / total) * 100).clamp(0, 100).toInt();
                      final date = (att['timestamp'] as Timestamp).toDate();
                      final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(date);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xffa42442), Color(0xff203A43)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(3, 3),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/attemptQuiz',
                                  arguments: {
                                    'quizId': att['quizId'],
                                    'quizTitle': att['quizTitle'],
                                  },
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      att['quizTitle'],
                                      style: GoogleFonts.orbitron(
                                        color: Colors.white,
                                        fontSize: MediaQuery.of(context).size.width * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [Colors.white70, Colors.white],
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$percent%',
                                              style: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            dateStr,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.replay,
                                          color: Colors.white70,
                                          size: 28,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: percent / 100,
                                        minHeight: 8,
                                        backgroundColor: Colors.white24,
                                        valueColor: const AlwaysStoppedAnimation<Color>(
                                            Colors.white70),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),

    );
  }
}