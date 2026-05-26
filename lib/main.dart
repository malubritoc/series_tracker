import 'package:flutter/material.dart';

import 'screens/root_shell.dart';

void main() {
  runApp(const SeriesTrackerApp());
}

class SeriesTrackerApp extends StatelessWidget {
  const SeriesTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF8000),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Series Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF14181C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B2228),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const RootShell(),
    );
  }
}
