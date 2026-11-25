import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/experience_form_page.dart';
import 'package:myportofolio_mobile/screens/home_page.dart';
import 'package:myportofolio_mobile/screens/project_form_page.dart';
import 'package:myportofolio_mobile/screens/project_list_page.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';
import 'package:myportofolio_mobile/widgets/portfolio_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.apiClient});

  final ApiClient? apiClient;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: PortfolioColors.pink)
        .copyWith(
          primary: PortfolioColors.mauve,
          secondary: PortfolioColors.yellow,
          surface: PortfolioColors.cream,
          onSurface: PortfolioColors.ink,
          error: PortfolioColors.error,
        );

    return MaterialApp(
      title: 'MyPortfolio',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'DM Sans',
        colorScheme: colorScheme,
        scaffoldBackgroundColor: PortfolioColors.cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: PortfolioColors.cream,
          foregroundColor: PortfolioColors.roseInk,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              return PortfolioColors.roseInk.withValues(
                alpha: states.contains(WidgetState.pressed) ? 0.18 : 0.09,
              );
            }),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xE6FFFCFA),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(
            color: PortfolioColors.ink,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: const TextStyle(
            color: PortfolioColors.roseInk,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: const TextStyle(
            color: PortfolioColors.muted,
            fontSize: 14,
          ),
          helperStyle: const TextStyle(
            color: PortfolioColors.muted,
            height: 1.5,
          ),
          errorStyle: const TextStyle(
            color: PortfolioColors.error,
            fontSize: 13,
            height: 1.4,
          ),
          helperMaxLines: 8,
          errorMaxLines: 8,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: PortfolioColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: PortfolioColors.roseInk,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: PortfolioColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: PortfolioColors.error,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: PortfolioColors.line),
          ),
        ),
      ),
      home: const MyHomePage(title: 'MyPortfolio'),
      routes: {
        PortfolioDestination.projects.routeName: (_) =>
            ProjectListPage(apiClient: apiClient),
        PortfolioDestination.experience.routeName: (_) =>
            const ExperienceFormPage(),
        PortfolioDestination.project.routeName: (_) => const ProjectFormPage(),
      },
    );
  }
}
