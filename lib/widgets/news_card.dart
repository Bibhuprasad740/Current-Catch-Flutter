import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NewsCard extends StatelessWidget {
  final int index;
  final Function onTap;
  final Map<String, dynamic> article;

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.index,
  });

  // Function to save news to local storage
  Future<void> _saveToLocalStorage(Map<String, dynamic> news) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Get existing saved news
    List<String> savedNews = prefs.getStringList('savedNews') ?? [];
    // Add the current article to the list
    savedNews.add(jsonEncode(news));
    // Save back to local storage
    await prefs.setStringList('savedNews', savedNews);
  }

  String _calculatePublishTime(String publishedAt) {
    DateTime publishedTime = DateTime.parse(publishedAt);
    DateTime now = DateTime.now();
    Duration difference = now.difference(publishedTime);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlay
          if (article["image_url"] != null)
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: article["image_url"],
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 220,
                    color: Colors.grey[850],
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue.shade200,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 220,
                    color: Colors.grey[850],
                    child: Image.asset(
                      'assets/images/default_image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (article["image_url"] == null)
            Stack(
              children: [
                Image.asset('assets/images/default_image.png'),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade900.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${article["source_name"] ?? 'Unknown'}',
                        style: TextStyle(
                          color: Colors.blue.shade200,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Publish Time
                    Text(
                      _calculatePublishTime(article["pubDate"]),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  article["title"],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // Content Preview
                Text(
                  article["description"] != null
                      ? article["description"].split('[')[0]
                      : 'No content available',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Source and Read More
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Text(
                        index.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        // Outlined Read More Button
                        OutlinedButton(
                          onPressed: onTap as void Function(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue.shade200,
                            side: BorderSide(
                              color: Colors.blue.shade200,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'Read More',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _saveToLocalStorage(article),
                          icon: Icon(Icons.bookmark_border_outlined,
                              color: Colors.blue[300]),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
