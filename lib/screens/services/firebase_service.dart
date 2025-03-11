import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/blog_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all blogs
  Stream<List<Blog>> getBlogs() {
    return _firestore
        .collection('blogs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Blog.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Get a single blog by ID
  Future<Blog?> getBlogById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('blogs').doc(id).get();
      if (doc.exists) {
        return Blog.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting blog: $e');
      return null;
    }
  }

  // Increment view count
  Future<void> incrementViewCount(String blogId) async {
    try {
      await _firestore.collection('blogs').doc(blogId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }
  }
}

