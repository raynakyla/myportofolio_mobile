import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFFF6CEDD))
        .copyWith(
          primary: const Color(0xFF9D5F78),
          secondary: const Color(0xFFFBE8A6),
          surface: const Color(0xFFFFF9F3),
          onSurface: const Color(0xFF2F2A2D),
        );

    return MaterialApp(
      title: 'MyPortfolio',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'DM Sans',
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFFFF9F3),
      ),
      home: const MyHomePage(title: 'MyPortfolio'),
    );
  }
}
