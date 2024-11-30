import 'package:flutter/material.dart';

class NewsDetailsScreen extends StatelessWidget {
  static const routeName = '/news-details-screen';
  const NewsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final newsItem =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    return const Placeholder();
  }
}
