import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz_model.dart';
import '../services/database_service.dart';
import '../widgets/custom_button.dart';

class QuestionData {
  TextEditingController questionController;
  List<TextEditingController> optionControllers;
  int correctOptionIndex;

  QuestionData({
    required this.questionController,
    required this.optionControllers,
    required this.correctOptionIndex,
  });
}

class EditQuizScreen extends StatefulWidget {
  @override
  _EditQuizScreenState createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  final _dbService = DatabaseService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  List<QuestionData> _questions = [];
  String error = '';
  late QuizModel _quiz;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as QuizModel;
    _quiz = args;
    _loadExistingData();
  }

  void _loadExistingData() async {
    _titleController.text = _quiz.title;
    _descController.text = _quiz.description;

    final rawQs = await _dbService.getQuizQuestions(_quiz.id);
    setState(() {
      _questions = rawQs.map((q) {
        return QuestionData(
          questionController: TextEditingController(text: q['question']),
          optionControllers: List.generate(
            (q['options'] as List).length,
                (i) => TextEditingController(text: (q['options'] as List)[i]),
          ),
          correctOptionIndex: q['answer'] as int,
        );
      }).toList();
    });
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        QuestionData(
          questionController: TextEditingController(),
          optionControllers: List.generate(4, (_) => TextEditingController()),
          correctOptionIndex: 0,
        ),
      );
    });
  }

  Future<void> _submitEdits() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => error = 'Title cannot be empty.');
      return;
    }

    List<Map<String, dynamic>> questionsMap = [];
    for (var q in _questions) {
      final text = q.questionController.text.trim();
      final opts = q.optionControllers.map((c) => c.text.trim()).toList();
      if (text.isEmpty || opts.any((o) => o.isEmpty)) continue;
      questionsMap.add({
        'question': text,
        'options': opts,
        'answer': q.correctOptionIndex,
      });
    }
    if (questionsMap.isEmpty) {
      setState(() => error = 'You must have at least one complete question.');
      return;
    }

    await _dbService.updateQuiz(
      quizId: _quiz.id,
      title: title,
      description: _descController.text.trim(),
      questions: questionsMap,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xffa42442),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/myProfile'),
        ),
        title: Text(
          '📝Edit Quiz',
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
      body: _questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child: Column(
          children: [
            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Quiz Title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_questions.length, (i) {
              final qData = _questions[i];
              return Card(
                color: Colors.white12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${i + 1}:',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: qData.questionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Question text',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Options (select correct):',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold),
                      ),
                      ...List.generate(
                        qData.optionControllers.length,
                            (optIdx) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Radio<int>(
                              value: optIdx,
                              groupValue: qData.correctOptionIndex,
                              onChanged: (val) {
                                setState(() =>
                                qData.correctOptionIndex = val!);
                              },
                              activeColor: Colors.green,
                            ),
                            title: TextField(
                              controller:
                              qData.optionControllers[optIdx],
                              style:
                              const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Option ${optIdx + 1}',
                                labelStyle: const TextStyle(
                                    color: Colors.white54),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Add Question',
              onPressed: _addQuestion,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Save Changes',
              onPressed: _submitEdits,
            ),
            const SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }
}
