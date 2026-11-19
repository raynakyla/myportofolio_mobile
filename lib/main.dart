import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/menu.dart';
import 'package:myportofolio_mobile/portfolio_style.dart';

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
      ),
      home: const MyHomePage(title: 'MyPortfolio'),
    );
  }
}
