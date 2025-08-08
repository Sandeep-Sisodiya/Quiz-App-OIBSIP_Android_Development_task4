import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../models/quiz_model.dart';

class MyProfileScreen extends StatefulWidget {
  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _db = DatabaseService();
  late Future<List<QuizModel>> _myQuizzes;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _loadMyQuizzes();
  }

  void _loadMyQuizzes() {
    _myQuizzes = _db.getUserQuizzes(_user.uid);
  }

  Future<void> _deleteQuiz(String quizId) async {
    await _db.deleteQuiz(quizId);
    setState(_loadMyQuizzes);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff1c1c1e),
      appBar: AppBar(
        backgroundColor: const Color(0xffa42442),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
        title: Text(
          '✌️My Profile',
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
        body: Stack(
          children: [
            Container(
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
            ),
            ListView(
              children: [
                Column(
                  children: [
                    Padding(padding: EdgeInsets.all(16)),
                    Image.asset('assets/icons/logo5.png', height: size.height * 0.25),
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white24,
                            backgroundImage:
                            _user.photoURL != null ? NetworkImage(_user.photoURL!) : null,
                            child: _user.photoURL == null
                                ? Text(
                              (_user.displayName?.isNotEmpty ?? false)
                                  ? _user.displayName![0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(fontSize: 28, color: Colors.white),
                            )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user.displayName ?? 'Anonymous',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _user.email ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // White Line
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        height: 4.0,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: const [
                          Icon(Icons.quiz, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'My Quizzes',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: FutureBuilder<List<QuizModel>>(
                        future: _myQuizzes,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final quizzes = snapshot.data ?? [];

                          if (quizzes.isEmpty) {
                            return const Center(
                              child: Text(
                                'You haven’t created any quizzes yet.',
                                style: TextStyle(color: Colors.white60),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: quizzes.length,
                            itemBuilder: (context, index) {
                              final quiz = quizzes[index];
                              return Card(
                                color: Colors.white12,
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    quiz.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    quiz.description,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  children: [
                                    FutureBuilder<List<Map<String, dynamic>>>(
                                      future: _db.getQuizQuestions(quiz.id),
                                      builder: (context, qsnap) {
                                        if (qsnap.connectionState == ConnectionState.waiting) {
                                          return const Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Center(child: CircularProgressIndicator()),
                                          );
                                        }

                                        final questions = qsnap.data ?? [];

                                        return Column(
                                          children: questions.map((q) {
                                            final opts = List<String>.from(q['options']);
                                            final ansIndex = q['answer'] as int;

                                            return ListTile(
                                              title: Text(
                                                q['question'],
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: List.generate(opts.length, (i) {
                                                  final isCorrect = i == ansIndex;
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          isCorrect
                                                              ? Icons.check_circle
                                                              : Icons.circle_outlined,
                                                          size: 16,
                                                          color: isCorrect ? Colors.green : Colors.grey,
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          opts[i],
                                                          style: TextStyle(
                                                            color: isCorrect ? Colors.green : Colors.white70,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                    ButtonBar(
                                      alignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                          label: const Text(
                                            'Edit',
                                            style: TextStyle(color: Colors.blueAccent),
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/editQuiz',
                                              arguments: quiz,
                                            ).then((_) => setState(_loadMyQuizzes));
                                          },
                                        ),
                                        TextButton.icon(
                                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                                          label: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.redAccent),
                                          ),
                                          onPressed: () => _deleteQuiz(quiz.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

    );
  }
}
