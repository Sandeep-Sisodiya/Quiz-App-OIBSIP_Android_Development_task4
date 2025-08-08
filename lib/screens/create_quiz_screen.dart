import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../services/database_service.dart';
import 'available_quizzes.dart';
import '../services/auth_service.dart';
import '../widgets/custom_drawer.dart';


class QuestionData {
  final questionController = TextEditingController();
  final optionControllers = List.generate(4, (_) => TextEditingController());
  int correctOptionIndex = -1;
  bool isExpanded = true;
}

class CreateQuizScreen extends StatefulWidget {
  @override
  _CreateQuizScreenState createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dbService = DatabaseService();
  final _authService = AuthService();

  List<QuestionData> _questions = [QuestionData()];
  String _error = '';

  Future<void> _submitQuiz() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = 'You must be logged in to create a quiz.');
      return;
    }
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Quiz title is required.');
      return;
    }

    final questionsMap = <Map<String, dynamic>>[];
    for (var q in _questions) {
      final qText = q.questionController.text.trim();
      final opts = q.optionControllers.map((c) => c.text.trim()).toList();
      if (qText.isEmpty ||
          opts.any((o) => o.isEmpty) ||
          q.correctOptionIndex < 0)
        continue;
      questionsMap.add({
        'question': qText,
        'options': opts,
        'answer': q.correctOptionIndex,
      });
    }
    if (questionsMap.isEmpty) {
      setState(
        () => _error =
            'Each question needs text, 4 options, and one selected answer.',
      );
      return;
    }

    await _dbService.createQuiz(
      title: title,
      description: _descController.text.trim(),
      createdBy: user.uid,
      questions: questionsMap,
    );
    Navigator.pop(context);
  }

  void _addQuestion() => setState(() => _questions.add(QuestionData()));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Create Quiz',
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Color(0xffa42442)),
        ),
      ),
      drawer: buildAppDrawer(
        context,
        FirebaseAuth.instance.currentUser,
            () async {
          await _authService.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        },
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const SizedBox(height: 10),
                Image.asset(
                  'assets/icons/logo3.png',
                  height: size.height * 0.2,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 20),
                if (_error.isNotEmpty)
                  Text(
                    _error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _titleController,
                  label: 'Quiz Title',
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _descController,
                  label: 'Description (optional)',
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                ..._questions.asMap().entries.map((entry) {
                  final i = entry.key;
                  final q = entry.value;
                  return _buildQuestionPanel(q, i);
                }).toList(),
                const SizedBox(height: 40),
                _buildMainButton(
                  text: 'Submit Quiz',
                  icon: Icons.send,
                  onTap: _submitQuiz,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addQuestion,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Question',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Color(0xffa42442),
        elevation: 8,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildQuestionPanel(QuestionData qd, int index) {
    return Card(
      color: Colors.white12,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: qd.isExpanded,
        onExpansionChanged: (v) => setState(() => qd.isExpanded = v),
        title: Text(
          'Question ${index + 1}',
          style: GoogleFonts.orbitron(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInputField(
                  controller: qd.questionController,
                  label: 'Question Text',
                ),
                const SizedBox(height: 12),
                ...List.generate(4, (j) {
                  final selected = qd.correctOptionIndex == j;
                  return ListTile(
                    tileColor: selected ? Colors.green.withOpacity(0.2) : null,
                    leading: Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      color: selected ? Colors.green : Colors.white70,
                    ),
                    title: TextField(
                      controller: qd.optionControllers[j],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Option ${j + 1}',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                    ),
                    onTap: () => setState(() => qd.correctOptionIndex = j),
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => setState(() => _questions.removeAt(index)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xffc21c55), Color(0xffe8bd38)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
