import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  final String id;
  final String title;
  final String content;
  final String excerpt;
  final String author;
  final DateTime createdAt;
  final List<String> images;
  final int views;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.author,
    required this.createdAt,
    required this.images,
    required this.views,
  });

  factory Blog.fromMap(String id, Map<String, dynamic> map) {
    return Blog(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      excerpt: map['excerpt'] ?? '',
      author: map['author'] ?? '',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      images: List<String>.from(map['images'] ?? []),
      views: map['views'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'author': author,
      'createdAt': createdAt,
      'images': images,
      'views': views,
    };
  }
}

