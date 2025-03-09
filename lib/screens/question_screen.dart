import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './model/game_state.dart';
import './model/level.dart';
import './model/question.dart';
import '../screens/widgets/option_button.dart';
import 'map_screen.dart';

class QuestionScreen extends StatefulWidget {
  final int levelId;

  const QuestionScreen({super.key, required this.levelId});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _currentQuestionIndex = 0;
  int _selectedOptionIndex = -1;
  bool _showResult = false;
  int _correctAnswers = 0;
  Level? _level;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final gameState = Provider.of<GameState>(context, listen: false);

    if (_level == null) {
      await gameState.fetchLevels();
      setState(() {
        _level = gameState.getLevelById(widget.levelId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_level == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final Question currentQuestion = _level!.questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF90ADFF), // Set the background color here
      appBar: AppBar(
        title: Text(
          _level!.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _level!.questions.length,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${_currentQuestionIndex + 1}/${_level!.questions.length}',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
            const SizedBox(height: 24),
            Text(
              currentQuestion.text,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  return OptionButton(
                    text: currentQuestion.options[index],
                    isSelected: _selectedOptionIndex == index,
                    isCorrect: index == currentQuestion.correctAnswerIndex,
                    showResult: _showResult,
                    onTap: _showResult
                        ? () {} // Empty function instead of null
                        : () {
                      setState(() {
                        _selectedOptionIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedOptionIndex == -1
                    ? null
                    : () {
                  if (_showResult) {
                    if (_currentQuestionIndex < _level!.questions.length - 1) {
                      setState(() {
                        _currentQuestionIndex++;
                        _selectedOptionIndex = -1;
                        _showResult = false;
                      });
                    } else {
                      _finishLevel();
                    }
                  } else {
                    setState(() {
                      _showResult = true;
                      if (_selectedOptionIndex == currentQuestion.correctAnswerIndex) {
                        _correctAnswers++;
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _showResult
                      ? (_currentQuestionIndex < _level!.questions.length - 1 ? 'Next Question' : 'Finish')
                      : 'Check Answer',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles level completion and saves progress to Firestore
  void _finishLevel() async {
    final gameState = Provider.of<GameState>(context, listen: false);
    bool success = _correctAnswers >= 3;

    if (success) {
      gameState.completeLevel(widget.levelId);
      await _updateUserProgress(widget.levelId); // ✅ Save progress in Firestore
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          success ? 'Level Completed!' : 'Try Again',
          style: TextStyle(color: success ? Colors.green : Colors.red),
        ),
        content: Text(
          success ? 'Great job! You\'ve unlocked the next level.' : 'You need at least 3 correct answers to pass.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()),
                    (route) => false,
              );
            },
            child: Text(success ? 'Go to Map' : 'Retry'),
          ),
        ],
      ),
    );
  }

  /// Updates the last completed level in Firestore for the user
  Future<void> _updateUserProgress(int levelId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Get the current user progress
        DocumentSnapshot userSnapshot = await userRef.get();
        int currentLevel = userSnapshot.exists && userSnapshot['lastCompletedLevel'] != null
            ? userSnapshot['lastCompletedLevel']
            : 0;

        // Only update if the completed level is greater than the saved one
        if (levelId > currentLevel) {
          await userRef.update({'lastCompletedLevel': levelId});
          print("🔥 Level $levelId saved in Firestore!");
        }
      }
    } catch (e) {
      print("❌ Error updating level progress: $e");
    }
  }

}
