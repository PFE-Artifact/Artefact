class ThemeModel {
  final String id;
  final String title;
  final String imageUrl;
  final bool isLocked;
  final String category;

  ThemeModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.isLocked = false,
    this.category = "History",
  });

  factory ThemeModel.fromFirestore(Map<String, dynamic> data) {
    return ThemeModel(
      id: data['id'] ?? '',
      title: data['title'] ?? 'Unknown Theme',
      imageUrl: data['image'] ?? 'https://via.placeholder.com/300',
      isLocked: data['isLocked'] ?? false,
      category: data['category'] ?? 'History',
    );
  }
  @override
  String toString() {
    return 'ThemeModel(id: $id, title: $title, isLocked: $isLocked)';
  }
}

