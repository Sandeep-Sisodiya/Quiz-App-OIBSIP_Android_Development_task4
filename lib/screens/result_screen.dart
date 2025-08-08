import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';

class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _saved = false;
  late List<Map<String, dynamic>> questions;
  late List<int?> answers;
  late String quizTitle;
  late String quizId;
  late int correctCount;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_saved) {
      final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      questions = args['questions'] as List<Map<String, dynamic>>;
      answers = args['answers'] as List<int?>;
      quizTitle = args['quizTitle'] as String;
      quizId = args['quizId'] as String;

      correctCount = 0;
      for (int i = 0; i < questions.length; i++) {
        if (answers[i] == questions[i]['answer']) correctCount++;
      }

      DatabaseService().getQuizQuestions(quizId).then((questionList) {
        int totalQuestions = questionList.length;

        DatabaseService().addQuizAttempt(
          quizId: quizId,
          quizTitle: quizTitle,
          score: correctCount,
          totalQuestions: totalQuestions,
        );
      });

      _saved = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/available'),
        ),
        backgroundColor: const Color(0xffa42442),
        title: Text(
          'Result',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: size.width * 0.06,
            fontWeight: FontWeight.w900
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Image.asset(
                'assets/icons/result.png',
                height: size.height * 0.35,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You scored  ▶  $correctCount / ${questions.length}',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: size.width * 0.055,
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 18),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: questions.length,
              itemBuilder: (context, i) {
                final q = questions[i];
                final correctIdx = q['answer'] as int;
                final selectedIdx = answers[i];

                return Card(
                  color: Colors.white12,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q['question'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Answer: ${q['options'][correctIdx]}',
                          style: GoogleFonts.poppins(
                            color: Colors.greenAccent,
                            fontSize: size.width * 0.04,
                          ),
                        ),
                        if (selectedIdx != null && selectedIdx != correctIdx)
                          Text(
                            'Your Answer: ${q['options'][selectedIdx]}',
                            style: GoogleFonts.poppins(
                              color: Colors.redAccent,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: size.width * 0.5,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffa42442),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/leaderboard',
                      arguments: quizId,
                    );
                  },
                  child: Text(
                    'Leaderboard',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

    );
  }
}
