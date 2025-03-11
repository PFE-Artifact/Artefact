import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/blog_model.dart';
import '../services/firebase_service.dart';

class LatestBlogsSection extends StatelessWidget {
  final bool isRTL;
  final Function(String) onBlogTap;

  const LatestBlogsSection({
    Key? key,
    required this.isRTL,
    required this.onBlogTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return StreamBuilder<List<Blog>>(
      stream: firebaseService.getBlogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading blogs: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No blogs available'),
          );
        }

        // Take only the latest 3 blogs
        final latestBlogs = snapshot.data!.take(3).toList();

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: latestBlogs.length,
            itemBuilder: (context, index) {
              final blog = latestBlogs[index];
              return GestureDetector(
                onTap: () => onBlogTap(blog.id),
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image section
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: blog.images.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: blog.images[0],
                          height: 120,
                          width: 160,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 120,
                            color: Colors.blue.shade50,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 120,
                            color: Colors.blue.shade50,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.blue,
                            ),
                          ),
                        )
                            : Container(
                          height: 120,
                          color: Colors.blue.shade50,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      // Text section
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: isRTL
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                blog.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                blog.excerpt,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
