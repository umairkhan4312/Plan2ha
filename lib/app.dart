import 'package:flutter/material.dart';

import 'screens/converter_screen.dart';

class SmartFloorPlanApp extends StatelessWidget {
  const SmartFloorPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF29B6F6),
      brightness: Brightness.dark,
      surface: const Color(0xFF101820),
    );
    return MaterialApp(
      title: 'Smart Floor Plan – Home Assistant',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF0B1117),
        cardTheme: const CardThemeData(
          color: Color(0xFF121C25),
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Color(0xFF111A22),
        ),
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0784B5)),
      ),
      home: const ConverterScreen(),
    );
  }
}
