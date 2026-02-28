import 'package:flutter/material.dart';
import 'package:gircik/theme/app_theme.dart';
import 'package:gircik/screens/home_screen.dart';

void main() {
  runApp(const GircikApp());
}

class GircikApp extends StatelessWidget {
  const GircikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GiyÇık',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
