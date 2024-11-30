import 'package:flutter/material.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash-screen';
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;

  Future<Widget> buildPageAsync() async {
    return Future.microtask(() {
      return const HomeScreen();
    });
  }

  @override
  void initState() {
    super.initState();
    navigateToHomeScreen();
  }

  void navigateToHomeScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    var dHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'News!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: dHeight * 0.05,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'All the information you need!',
              style: TextStyle(
                color: Colors.white30,
                letterSpacing: 1,
              ),
            )
          ],
        ),
      ),
    );
  }
}

/**
 * https://newsapi.org/docs/get-started#top-headlines
 * https://www.youtube.com/watch?v=JVpFNfnuOZM
 */
