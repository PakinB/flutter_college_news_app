import 'package:flutter/material.dart';

import 'dashboard.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniAnnounce Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F1E8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B57D8),
          primary: const Color(0xFF5B57D8),
          secondary: const Color(0xFF3AA88C),
          surface: Colors.white,
        ),
        fontFamily: 'Noto Sans Thai',
      ),
      home: const DashboardPage(),
    );
  }
}
