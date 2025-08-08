import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final int index;

  QuestionCard({required this.question, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          '$index. $question',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
