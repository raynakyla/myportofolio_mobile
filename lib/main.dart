import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/home_page.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: PortfolioColors.pink)
        .copyWith(
          primary: PortfolioColors.mauve,
          secondary: PortfolioColors.yellow,
          surface: PortfolioColors.cream,
          onSurface: PortfolioColors.ink,
        );

    return MaterialApp(
      title: 'MyPortfolio',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'DM Sans',
        colorScheme: colorScheme,
        scaffoldBackgroundColor: PortfolioColors.cream,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xE6FFFCFA),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(color: PortfolioColors.ink),
          helperMaxLines: 3,
          errorMaxLines: 3,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0x669D5F78)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: PortfolioColors.mauve,
              width: 2,
            ),
          ),
        ),
      ),
      home: const MyHomePage(title: 'MyPortfolio'),
    );
  }
}
