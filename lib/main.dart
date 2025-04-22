import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MovieTrackerApp());
}

class MovieTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Tracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
