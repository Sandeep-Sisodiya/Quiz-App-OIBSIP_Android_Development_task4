import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../widgets/option_tile.dart';

class AttemptQuizScreen extends StatefulWidget {
  @override
  _AttemptQuizScreenState createState() => _AttemptQuizScreenState();
}

class _AttemptQuizScreenState extends State<AttemptQuizScreen> {
  final _dbService = DatabaseService();
  List<Map<String, dynamic>> _questions = [];
  List<int?> _selectedAnswers = [];
  int _currentIndex = 0;
  String quizId = '';
  String quizTitle = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    quizId = args['quizId'];
    quizTitle = args['quizTitle'];
    _dbService.getQuizQuestions(quizId).then((list) {
      setState(() {
        _questions = list;
        _selectedAnswers = List<int?>.filled(_questions.length, null);
      });
    });
  }

  void _onOptionTap(int idx) {
    setState(() {
      _selectedAnswers[_currentIndex] = idx;
    });
  }

  void _navigate(int offset) {
    final newIndex = _currentIndex + offset;
    if (newIndex >= 0 && newIndex < _questions.length) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  void _submitQuiz() {
    Navigator.pushReplacementNamed(context, '/result', arguments: {
      'questions': _questions,
      'answers': _selectedAnswers,
      'quizTitle': quizTitle,
      'quizId': quizId,
    });
  }


  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F2027),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    final currentQ = _questions[_currentIndex];
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
          '🎯Be Focused',
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                quizTitle,
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.05,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Q${_currentIndex + 1}/${_questions.length}',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Text(
              currentQ['question'],
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.055,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate((currentQ['options'] as List).length, (i) {
              return OptionTile(
                option: currentQ['options'][i],
                isSelected: _selectedAnswers[_currentIndex] == i,
                isCorrect: false,
                onTap: () => _onOptionTap(i),
              );
            }),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentIndex > 0) ...[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffa42442),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _navigate(-1),
                    child: Text(
                      'Previous',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffa42442),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_selectedAnswers[_currentIndex] != null) {
                      if (_currentIndex == _questions.length - 1) {
                        _submitQuiz();
                      } else {
                        _navigate(1);
                      }
                    }
                  },
                  child: Text(
                    _currentIndex == _questions.length - 1
                        ? 'Submit'
                        : 'Save & Next',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
