import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/portfolio_drawer.dart';
import 'package:myportofolio_mobile/portfolio_style.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      drawer: PortfolioDrawer(
        currentDestination: PortfolioDestination.experience,
        onDestinationSelected: (_) {
          // Home stays at the bottom of the stack; reuse it instead of pushing.
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      appBar: AppBar(
        leading: const BackButton(),
        actions: const [DrawerButton()],
        title: const Text('Tambah Experience'),
        titleTextStyle: const TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: PortfolioColors.ink,
        ),
        toolbarHeight: isNarrow ? 72 : 88,
        backgroundColor: PortfolioColors.cream,
        surfaceTintColor: Colors.transparent,
        foregroundColor: PortfolioColors.mauve,
        elevation: 0,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [PortfolioColors.cream, Color(0xFFFFF5F8)],
          ),
        ),
        child: SizedBox.expand(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isNarrow ? 16 : 28,
                isNarrow ? 16 : 24,
                isNarrow ? 16 : 28,
                40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: PortfolioGlassPanel(
                    padding: EdgeInsets.all(isNarrow ? 24 : 40),
                    borderRadius: BorderRadius.circular(isNarrow ? 25 : 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: PortfolioColors.yellow,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white),
                          ),
                          child: const Icon(
                            Icons.work_outline_rounded,
                            color: Color(0xFF765621),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Setiap pengalaman punya cerita.',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: isNarrow ? 30 : 40,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            color: PortfolioColors.ink,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Halaman ini akan digunakan untuk menambahkan '
                          'pengalaman ke portofolio. Formulirnya akan '
                          'tersedia pada tahap berikutnya.',
                          style: TextStyle(
                            color: PortfolioColors.muted,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
