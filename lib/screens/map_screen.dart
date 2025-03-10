import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './model/game_state.dart';
import './widgets/hexagon_node.dart';
import './widgets/map_connector.dart';
import 'question_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Map 1',
          style: TextStyle(
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
          Consumer<GameState>(
            builder: (context, gameState, child) {
              return FutureBuilder<int>(
                future: _fetchLastCompletedLevel(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  int lastCompletedLevel = snapshot.data ?? 1;
                  int nextLevel = lastCompletedLevel + 1;
                  gameState.setCurrentLevel(nextLevel);

                  return _buildMap(context, gameState, lastCompletedLevel, nextLevel);
                },
              );
            },
          ),
        ],
      ),

    );
  }

  Future<int> _fetchLastCompletedLevel() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return doc['lastCompletedLevel'] ?? 1;
      }
    }
    return 1; // Default to level 1 if no user data found
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
    if (levelId == lastCompletedLevel) {
      return HexagonNodeStatus.completed; // Allow user to open the last completed level
    } else if (levelId == nextLevel) {
      return HexagonNodeStatus.unlocked; // Unlock next level
    } else if (levelId < lastCompletedLevel) {
      return HexagonNodeStatus.completed; // Mark older levels as completed
    } else {
      return HexagonNodeStatus.locked; // Lock future levels
    }
  }

  void _handleNodeTap(BuildContext context, GameState gameState, int levelId, int lastCompletedLevel, int nextLevel) {
    if (levelId == lastCompletedLevel || levelId == nextLevel || lastCompletedLevel >= levelId) {
      gameState.setCurrentLevel(levelId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionScreen(levelId: levelId),
        ),
      );
    } else {
      // Optionally, add a shake animation or alert for locked levels
    }
  }
}
