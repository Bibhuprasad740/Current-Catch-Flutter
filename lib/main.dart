import 'package:flutter/material.dart';
import 'package:news/screens/news_details_screen.dart';

import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.white,
        secondary: Colors.red[900],
      )
          //color
          ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        NewsDetailsScreen.routeName: (context) => const NewsDetailsScreen(),
      },
    );
  }
}
