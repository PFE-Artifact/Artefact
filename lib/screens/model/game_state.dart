import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'level.dart';
import 'question.dart';

class GameState extends ChangeNotifier {
  int _currentLevel = 1;
  final Set<int> _unlockedLevels = {1}; // Level 1 is unlocked by default
  final Set<int> _completedLevels = {};
  List<Level> _levels = [];
  String? _userId; // Store the user ID to track progress


  int get currentLevel => _currentLevel;
  Set<int> get unlockedLevels => _unlockedLevels;
  Set<int> get completedLevels => _completedLevels;
  List<Level> get levels => _levels;
  String? get userId => _userId;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // **Set the User ID**
  void setUserId(String userId) {
    _userId = userId;
    loadUserProgress(); // Load progress when userId is set
  }

  // **Load user progress from Firestore**
  Future<void> loadUserProgress() async {
    if (_userId == null) return;
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(_userId).get();

      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('progress')) {
          Map<String, dynamic> progressData = data['progress'];
          if (progressData.isNotEmpty) {
            // Load user progress levels (level completion status)
            progressData.forEach((levelId, levelStatus) {
              int id = int.tryParse(levelId) ?? 0;
              if (levelStatus == 'completed') {
                _completedLevels.add(id);
              } else if (levelStatus == 'unlocked') {
                _unlockedLevels.add(id);
              }
            });
          }
        }
      }
      _currentLevel = _unlockedLevels.isNotEmpty ? _unlockedLevels.last : 1;
      notifyListeners();
    } catch (e) {
      debugPrint("🔥 Error loading user progress: $e");
    }
  }

  // **Save user progress to Firestore**
  Future<void> saveUserProgress() async {
    if (_userId == null) return;
    try {
      Map<String, String> progressMap = {};

      _unlockedLevels.forEach((level) {
        progressMap[level.toString()] = 'unlocked';
      });

      _completedLevels.forEach((level) {
        progressMap[level.toString()] = 'completed';
      });

      await _db.collection('users').doc(_userId).set({
        'currentLevel': _currentLevel,
        'progress': progressMap, // Saving progress as a map
      }, SetOptions(merge: true)); // Merge existing data
    } catch (e) {
      debugPrint("🔥 Error saving user progress: $e");
    }
  }

  // **Fetch levels & questions from Firestore**
  Future<void> fetchLevels() async {
    try {
      debugPrint("🔍 Fetching questions...");
      QuerySnapshot questionSnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc('punic_carthaginian')
          .collection('questions')
          .get();

      if (questionSnapshot.docs.isEmpty) {
        debugPrint("⚠️ No questions found.");
        return;
      }

      _levels.clear();
      Map<int, List<Question>> levelQuestionsMap = {};

      for (var doc in questionSnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data == null || !data.containsKey('levelId')) {
          debugPrint("⚠️ Skipping invalid doc: ${doc.id}");
          continue;
        }

        int? levelId = data['levelId'];
        if (levelId is! int) {
          debugPrint("🚨 Invalid levelId in ${doc.id}: ${levelId.runtimeType}");
          continue;
        }

        debugPrint("✅ Loaded question ${doc.id} for Level $levelId");

        Question question = Question(
          id: int.tryParse(doc.id.replaceAll('q', '')) ?? 0,
          text: data['question'],
          options: List<String>.from(data['options']),
          correctAnswerIndex: data['options'].indexOf(data['correct']),
        );

        levelQuestionsMap.putIfAbsent(levelId, () => []).add(question);
      }

      if (levelQuestionsMap.isEmpty) {
        debugPrint("⚠️ No levels were created!");
        return;
      }

      levelQuestionsMap.forEach((levelId, questions) {
        _levels.add(Level(id: levelId, name: "Level $levelId", questions: questions));
      });

      notifyListeners();
      debugPrint("🎉 Levels loaded! Total: ${_levels.length}");
    } catch (e) {
      debugPrint("🔥 Error loading levels: $e");
    }
  }

  // **Sets the current level (only if unlocked)**
  void setCurrentLevel(int levelId) {
    if (_unlockedLevels.contains(levelId)) {
      _currentLevel = levelId;
      notifyListeners();
      saveUserProgress(); // Save progress when current level is set
    } else {
      debugPrint("⚠️ Level $levelId is locked.");
    }
  }

  // **Gets a level by ID**
  Level getLevelById(int levelId) {
    try {
      return _levels.firstWhere(
            (level) => level.id == levelId,
        orElse: () => throw Exception("Level $levelId not found."),
      );
    } catch (e) {
      debugPrint("🔥 Error: $e");
      rethrow;
    }
  }

  // **Checks if a level is unlocked**
  bool isLevelUnlocked(int levelId) => _unlockedLevels.contains(levelId);

  // **Checks if a level is completed**
  bool isLevelCompleted(int levelId) => _completedLevels.contains(levelId);

  // **Completes a level and unlocks the next one**
  void completeLevel(int levelId) {
    if (!_completedLevels.contains(levelId)) {
      _completedLevels.add(levelId);

      int nextLevelId = levelId + 1;
      if (_levels.any((level) => level.id == nextLevelId)) {
        _unlockedLevels.add(nextLevelId);
      }

      _currentLevel = nextLevelId; // Increment level

      notifyListeners();
      saveUserProgress(); // Save progress when a level is completed
    }
  }
}