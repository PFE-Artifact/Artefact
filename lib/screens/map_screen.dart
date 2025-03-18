import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './model/game_state.dart';
import './widgets/hexagon_node.dart';
import './widgets/map_connector.dart';
import 'question_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _themeTitle = 'Map';
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _initializeTheme();
      _isInitialized = true;
    }
  }

  Future<void> _initializeTheme() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get theme data from route arguments if available
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        // Set the theme title
        if (args.containsKey('title')) {
          setState(() {
            _themeTitle = args['title'];
          });
        }

        // Get the GameState
        final gameState = Provider.of<GameState>(context, listen: false);

        // If themeId is directly provided, use it
        if (args.containsKey('themeId')) {
          String themeId = args['themeId'];
          await gameState.setCurrentTheme(themeId);
        }
        // Otherwise, try to derive it from the title
        else if (args.containsKey('title')) {
          String themeId = _getThemeIdFromTitle(args['title']);
          await gameState.setCurrentTheme(themeId);
        }

        // Fetch theme progress if not already loaded
        if (gameState.themeProgress.isEmpty) {
          await gameState.fetchThemeProgress();
        }
      }
    } catch (e) {
      debugPrint("Error initializing theme: $e");
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading theme: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Update the _getThemeIdFromTitle method to ensure consistent theme IDs
  String _getThemeIdFromTitle(String title) {
    // Map theme titles to their corresponding IDs in Firestore
    switch (title) {
      case 'Punic Carthaginian':
        return 'punic_carthaginian';
      case 'Islamic_Period':
        return 'Islamic_Period';
      case 'Roman and Byzantine':
        return 'Roman_and_Byzantine';
      case 'Colonial and Modern':
      // Return the exact format used in the database
        return 'Colonial and Modern';
      default:
        return title.replaceAll(' ', '_').toLowerCase(); // Default conversion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _themeTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, "/accueil");
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () async {
              // Reload levels
              final gameState = Provider.of<GameState>(context, listen: false);
              setState(() {
                _isLoading = true;
              });
              await gameState.fetchLevels();
              setState(() {
                _isLoading = false;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Handle menu button
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://i.pinimg.com/736x/ba/63/77/ba6377e9bd66d11c17a9f884e20bf63f.jpg',
            fit: BoxFit.cover,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Consumer<GameState>(
              builder: (context, gameState, child) {
                if (gameState.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${gameState.error}',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            gameState.clearError();
                            await gameState.fetchLevels();
                            setState(() {
                              _isLoading = false;
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (gameState.levels.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No levels found for this theme',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/accueil");
                          },
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  );
                }

                int lastCompletedLevel = gameState.getLastCompletedLevel();
                int nextLevel = lastCompletedLevel + 1;

                return _buildMap(context, gameState, lastCompletedLevel, nextLevel);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context, GameState gameState, int lastCompletedLevel, int nextLevel) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLevelRow(context, gameState, lastCompletedLevel, nextLevel, 5),
              const MapConnector(length: 40),
              _buildLevelRow(context, gameState, lastCompletedLevel, nextLevel, 4),
              const MapConnector(length: 40),
              _buildLevelWithReward(context, gameState, lastCompletedLevel, nextLevel, 3),
              const MapConnector(length: 40),
              _buildLevelRow(context, gameState, lastCompletedLevel, nextLevel, 2),
              const MapConnector(length: 40),
              _buildLevelWithReward(context, gameState, lastCompletedLevel, nextLevel, 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelRow(BuildContext context, GameState gameState, int lastCompletedLevel, int nextLevel, int levelId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HexagonNode(
          levelNumber: levelId,
          status: _getNodeStatus(gameState, levelId, lastCompletedLevel, nextLevel),
          onTap: () => _handleNodeTap(context, gameState, levelId, lastCompletedLevel, nextLevel),
        ),
      ],
    );
  }

  Widget _buildLevelWithReward(BuildContext context, GameState gameState, int lastCompletedLevel, int nextLevel, int levelId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HexagonNode(
          levelNumber: -levelId,
          status: lastCompletedLevel >= levelId
              ? HexagonNodeStatus.completed
              : HexagonNodeStatus.locked,
          onTap: () {},
          showNumber: false,
          showReward: true,
        ),
        const MapConnector(direction: Axis.horizontal, length: 40),
        HexagonNode(
          levelNumber: levelId,
          status: _getNodeStatus(gameState, levelId, lastCompletedLevel, nextLevel),
          onTap: () => _handleNodeTap(context, gameState, levelId, lastCompletedLevel, nextLevel),
        ),
      ],
    );
  }

  HexagonNodeStatus _getNodeStatus(GameState gameState, int levelId, int lastCompletedLevel, int nextLevel) {
    // Get the current theme progress (0 if no progress)
    int themeProgress = gameState.themeProgress[gameState.currentTheme] ?? 0;

    // If level is already completed
    if (levelId <= themeProgress) {
      return HexagonNodeStatus.completed;
    }

    // If this is the next level after the last completed one
    if (levelId == themeProgress + 1) {
      return HexagonNodeStatus.unlocked;
    }

    // All other levels should be locked
    return HexagonNodeStatus.locked;
  }

// Also update the _handleNodeTap method to add debug logging
  void _handleNodeTap(BuildContext context, GameState gameState, int levelId, int lastCompletedLevel, int nextLevel) {
    // Get the current theme progress
    int themeProgress = gameState.themeProgress[gameState.currentTheme] ?? 0;

    // Debug print to help diagnose issues
    debugPrint("🎮 Tapped level $levelId in theme ${gameState.currentTheme}");
    debugPrint("📊 Current theme progress: $themeProgress");
    debugPrint("🔓 Last completed level: $lastCompletedLevel");

    // Allow access if the level is completed or is the next unlocked level
    if (levelId <= themeProgress || levelId == themeProgress + 1) {
      gameState.setCurrentLevel(levelId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionScreen(levelId: levelId),
        ),
      );
    } else {
      // Show a message for locked levels
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complete level ${themeProgress + 1} first!')),
      );
    }
  }
}

