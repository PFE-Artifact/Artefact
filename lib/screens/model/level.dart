// This file should contain your existing Level and Question classes
// Make sure this is the ONLY place where Level is defined

class Question {
  final int id;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class Level {
  final int id;
  final String name;
  final List<Question> questions;

  Level({
    required this.id,
    required this.name,
    required this.questions,
  });
}

