import 'package:artefacts/screens/model/game_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => _firebaseAuth.currentUser ;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword ({
    required String email ,
    required String password ,
}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password ,
    );
  }

  Future<void> createUserWithEmailAndPassword ({
    required String email ,
    required String password ,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password ,
    );
  }

  // Add this to your authentication service
  Future<void> signOut() async {
    final gameState = Provider.of<GameState>(context as BuildContext, listen: false);
    gameState.clearGameState(); // Clear the game state before signing out
    await FirebaseAuth.instance.signOut();
  }




}