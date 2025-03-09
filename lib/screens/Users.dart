import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> Users(User user, String name, String phoneNumber) async {
  // Check if the user already has a document in Firestore
  DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

  // Store or update user data in Firestore
  await userDocRef.set({
    'name': name,
    'email': user.email,  // From FirebaseAuth
    'phoneNumber': phoneNumber,
    'score': 0,  // Default score
    'timestamp': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true)); // Merge to avoid overwriting existing data
}
