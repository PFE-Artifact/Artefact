import 'question.dart';

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