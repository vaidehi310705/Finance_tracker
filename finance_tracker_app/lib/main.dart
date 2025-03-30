import 'package:flutter/material.dart';
import 'home.dart'; // Import your home screen

void main() {
  runApp(FinanceTrackerApp());
}

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: HomePage(), // Your main home screen
    );
  }
}
