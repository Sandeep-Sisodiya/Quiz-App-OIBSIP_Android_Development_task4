import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback onTap;

  OptionTile({
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color tileColor = Colors.white;
    if (isSelected && isCorrect) {
      tileColor = Colors.greenAccent.shade100;
    } else if (isSelected && !isCorrect) {
      tileColor = Colors.redAccent.shade100;
    }

    return Card(
      color: tileColor,
      child: ListTile(
        title: Text(option),
        onTap: onTap,
      ),
    );
  }
}
