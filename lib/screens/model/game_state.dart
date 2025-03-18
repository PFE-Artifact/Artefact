import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import the Level class from your existing level.dart file
import 'level.dart';

class GameState extends ChangeNotifier {
  List<Level> _levels = [];
  int _currentLevel = 1;
  String _currentTheme = 'punic_carthaginian';
  Map<String, int> _themeProgress = {};
  bool _isLoadingProgress = false;
  bool _isLoadingLevels = false;
  String _error = '';

  // Getters
  List<Level> get levels => _levels;
  int get currentLevel => _currentLevel;
  String get currentTheme => _currentTheme;
  Map<String, int> get themeProgress => _themeProgress;
  bool get isLoadingProgress => _isLoadingProgress;
  bool get isLoadingLevels => _isLoadingLevels;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;

  // Set current level
  void setCurrentLevel(int level) {
    _currentLevel = level;
    notifyListeners();
  }

  // Set current theme and load its levels
  Future<void> setCurrentTheme(String theme) async {
    if (_currentTheme == theme) return; // No change needed

    _currentTheme = theme;
    _levels = []; // Clear current levels
    notifyListeners();

    // Load levels for the new theme
    await fetchLevels();
  }

  // Clear any error message
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Update the updateThemeProgress method to fix the issue with "Colonial and Modern" theme
  Future<void> updateThemeProgress(String themeId, int level) async {
    try {
      _error = '';
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _error = "No user logged in";
        debugPrint("⚠️ $_error");
        notifyListeners();
        return;
      }

      // Debug the incoming parameters
      debugPrint("🔍 Updating theme progress for: $themeId to level: $level");

      // Normalize the theme ID to match what's in the database
      String normalizedThemeId = themeId;

      // Check if we need to fix the "Colonial and Modern" theme ID
      if (themeId == "Colonial_and_Modern") {
        normalizedThemeId = "Colonial and Modern";
        debugPrint("🔄 Normalized theme ID from $themeId to $normalizedThemeId");
      }

      // Only update if the new level is higher than the current level
      int currentProgress = _themeProgress[normalizedThemeId] ?? 0;
      debugPrint("📊 Current progress for $normalizedThemeId: $currentProgress");

      if (level <= currentProgress) {
        debugPrint("ℹ️ Level $level is not higher than current progress $currentProgress for $normalizedThemeId");
        return;
      }

      // Update local state with the normalized theme ID
      _themeProgress[normalizedThemeId] = level;
      notifyListeners();

      // Update Firestore with the normalized theme ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'themeProgress.$normalizedThemeId': level});

      debugPrint("✅ Updated progress for $normalizedThemeId to level $level");
    } catch (e, stacktrace) {
      _error = "Error updating theme progress: $e";
      debugPrint("🔥 $_error");
      debugPrint(stacktrace.toString());
      notifyListeners();
    }
  }

// Also update the fetchThemeProgress method to ensure consistent theme IDs
  Future<void> fetchThemeProgress() async {
    if (_isLoadingProgress) return; // Prevent multiple calls

    try {
      _isLoadingProgress = true;
      _error = '';

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _error = "No user logged in";
        debugPrint("⚠️ $_error");
        notifyListeners();
        return;
      }

      // ❗ CLEAR OLD DATA BEFORE LOADING NEW USER'S PROGRESS
      _themeProgress = {};

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint("🆕 Creating new user document with NO progress");

        // Initialize with all themes locked (progress = 0)
        _themeProgress = {
          'punic_carthaginian': 0,
          'Islamic_Period': 0,
          'Roman_and_Byzantine': 0,
          'Colonial and Modern': 0,
        };

        // Create new user document with initialized theme progress
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'themeProgress': _themeProgress,
          'createdAt': FieldValue.serverTimestamp(),
          'email': user.email ?? '',
          'username': user.displayName ?? '',
        });

      } else {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Check if themeProgress exists in the document
        if (userData.containsKey('themeProgress')) {
          // Convert the data to the correct type
          Map<String, dynamic> progress = userData['themeProgress'] as Map<String, dynamic>;
          _themeProgress = progress.map((key, value) => MapEntry(key, (value as num).toInt()));
        } else {
          debugPrint("🆕 Initializing theme progress for existing user");

          // Initialize theme progress for existing user
          _themeProgress = {
            'punic_carthaginian': 0,
            'Islamic_Period': 0,
            'Roman_and_Byzantine': 0,
            'Colonial and Modern': 0,
          };

          // Update the user document with theme progress
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'themeProgress': _themeProgress});
        }
      }

      debugPrint("✅ Theme progress loaded: $_themeProgress");
      notifyListeners();
    } catch (e, stacktrace) {
      _error = "Error loading theme progress: $e";
      debugPrint("🔥 $_error");
      debugPrint(stacktrace.toString());
      notifyListeners();
    } finally {
      _isLoadingProgress = false;
    }
  }

// Add this method to clear the game state when signing out
  void clearGameState() {
    _levels = [];
    _currentLevel = 1;
    _themeProgress = {};
    _error = '';
    notifyListeners();
  }


// Add this method to verify theme progress
  bool isLevelUnlocked(int levelId) {
    int currentProgress = _themeProgress[_currentTheme] ?? 0;
    return levelId <= currentProgress + 1; // Current progress + next level
  }

// Update getLastCompletedLevel to handle both formats of the theme ID
  int getLastCompletedLevel() {
    // Try with the current theme ID first
    int progress = _themeProgress[_currentTheme] ?? 0;

    // If the current theme is "Colonial_and_Modern", also check "Colonial and Modern"
    if (_currentTheme == "Colonial_and_Modern" && progress == 0) {
      progress = _themeProgress["Colonial and Modern"] ?? 0;
      debugPrint("🔍 Using alternate theme ID format. Progress: $progress");
    }

    return progress;
  }

  // Get available themes
  Future<List<Map<String, dynamic>>> getAvailableThemes() async {
    try {
      _error = '';
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Unknown Theme',
          'imageUrl': data['imageUrl'] ?? '',
          'isLocked': data['isLocked'] ?? false,
        };
      }).toList();
    } catch (e) {
      _error = "Error loading themes: $e";
      debugPrint("🔥 $_error");
      return [];
    }
  }

  // Fetch levels for the current theme
  Future<void> fetchLevels() async {
    // Prevent multiple simultaneous calls
    if (_isLoadingLevels) return;

    try {
      _isLoadingLevels = true;
      _error = '';

      debugPrint("🔍 Fetching questions for theme: $_currentTheme");

      // Check if theme exists
      DocumentSnapshot themeDoc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(_currentTheme)
          .get();

      if (!themeDoc.exists) {
        _error = "Theme $_currentTheme does not exist";
        debugPrint("⚠️ $_error");
        _levels = [];
        notifyListeners();
        return;
      }

      QuerySnapshot questionSnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(_currentTheme)
          .collection('questions')
          .get();

      if (questionSnapshot.docs.isEmpty) {
        debugPrint("⚠️ No questions found for theme: $_currentTheme");
        _levels = [];
        notifyListeners();
        return;
      }

      Map<int, List<Question>> levelQuestionsMap = {};

      for (var doc in questionSnapshot.docs) {
        debugPrint("📄 Processing document: ${doc.id}");

        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data == null) {
          debugPrint("⚠️ Skipping invalid doc: ${doc.id}");
          continue;
        }

        if (!data.containsKey('levelId')) {
          debugPrint("⚠️ Skipping ${doc.id}: Missing 'levelId'");
          continue;
        }

        var levelId = data['levelId'];
        if (levelId is! int) {
          debugPrint("🚨 Invalid levelId in ${doc.id}: ${levelId.runtimeType}");
          continue;
        }

        if (!data.containsKey('question') || !data.containsKey('options') || !data.containsKey('correct')) {
          debugPrint("⚠️ Skipping ${doc.id}: Missing question fields");
          continue;
        }

        List<String> options;
        try {
          options = List<String>.from(data['options']);
        } catch (e) {
          debugPrint("🚨 Error parsing options in ${doc.id}: ${e.toString()}");
          continue;
        }

        String correctAnswer = data['correct'];
        if (!options.contains(correctAnswer)) {
          debugPrint("⚠️ Correct answer not in options for ${doc.id}");
          continue;
        }

        Question question = Question(
          id: int.tryParse(doc.id.replaceAll('q', '')) ?? 0,
          text: data['question'],
          options: options,
          correctAnswerIndex: options.indexOf(correctAnswer),
        );

        levelQuestionsMap.putIfAbsent(levelId, () => []).add(question);
      }

      if (levelQuestionsMap.isEmpty) {
        debugPrint("⚠️ No levels were created!");
        _levels = [];
        notifyListeners();
        return;
      }

      List<Level> newLevels = levelQuestionsMap.entries
          .map((entry) => Level(id: entry.key, name: "Level ${entry.key}", questions: entry.value))
          .toList();

      // Sort levels by ID
      newLevels.sort((a, b) => a.id.compareTo(b.id));

      _levels = newLevels;

      notifyListeners();
      debugPrint("🎉 Levels loaded for theme $_currentTheme! Total: ${_levels.length}");
    } catch (e, stacktrace) {
      _error = "Error loading levels: $e";
      debugPrint("🔥 $_error");
      debugPrint(stacktrace.toString());
      _levels = [];
      notifyListeners();
    } finally {
      _isLoadingLevels = false;
    }
  }

  // Initialize the game state
  Future<void> initialize() async {
    await fetchThemeProgress();
    await fetchLevels();
  }
  // Add this method to your GameState class if it doesn't already exist

  Level? getLevelById(int levelId) {
    try {
      return _levels.firstWhere((level) => level.id == levelId);
    } catch (e) {
      debugPrint("⚠️ Level with ID $levelId not found: $e");
      return null;
    }
  }

// Add this method to your GameState class if it doesn't already exist
  void completeLevel(int levelId) {
    // This is just a placeholder for any additional logic you might want to add
    // when a level is completed, beyond updating the theme progress
    debugPrint("🎮 Level $levelId completed!");
  }




}

