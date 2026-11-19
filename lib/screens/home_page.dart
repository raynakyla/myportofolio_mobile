import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/experience_form_page.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';
import 'package:myportofolio_mobile/widgets/portfolio_background.dart';
import 'package:myportofolio_mobile/widgets/portfolio_drawer.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_panel.dart';

const _compactWidth = 600.0;

void _openExperience(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (context) => const ExperienceFormPage()),
  );
}

class ItemHomepage {
  const ItemHomepage(this.name, this.icon, this.accent, this.accentInk);

  final String name;
  final IconData icon;
  final Color accent;
  final Color accentInk;
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  static const _maxContentWidth = 984.0;

  static const items = [
    ItemHomepage(
      'Lihat Proyek',
      Icons.folder_rounded,
      Color(0xFFF3D9EA),
      Color(0xFF884366),
    ),
    ItemHomepage(
      'Tambah Experience',
      Icons.add_circle_rounded,
      PortfolioColors.pink,
      PortfolioColors.roseInk,
    ),
    ItemHomepage(
      'Logout',
      Icons.logout_rounded,
      PortfolioColors.lavender,
      Color(0xFF605185),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < _compactWidth;
    final horizontalPadding = isNarrow ? 16.0 : 28.0;
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;

    return Scaffold(
      drawer: PortfolioDrawer(
        currentDestination: PortfolioDestination.home,
        onDestinationSelected: (_) => _openExperience(context),
      ),
      appBar: AppBar(
        leading: const DrawerButton(color: PortfolioColors.mauve),
        toolbarHeight: isNarrow ? (textScale > 1.5 ? 116 : 80) : 88,
        titleSpacing: horizontalPadding,
        backgroundColor: PortfolioColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Container(
              constraints: BoxConstraints(minHeight: isNarrow ? 52 : 58),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
                gradient: LinearGradient(
                  colors: [
                    PortfolioColors.pink.withValues(alpha: 0.70),
                    const Color(0xFFFDF1F7).withValues(alpha: 0.82),
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26824E66),
                    blurRadius: 28,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  const Text(
                    'Rayna.',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      color: PortfolioColors.mauve,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: PortfolioColors.mauve,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: PortfolioBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isNarrow ? 16 : 24,
                horizontalPadding,
                isNarrow ? 32 : 52,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HeroCard(),
                      SizedBox(height: isNarrow ? 22 : 42),
                      const Text(
                        'EXPLORE',
                        style: TextStyle(
                          color: PortfolioColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.2,
                        ),
                      ),
                      SizedBox(height: isNarrow ? 4 : 8),
                      Text(
                        'Where to next?',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          color: PortfolioColors.ink,
                          fontSize: isNarrow ? 26 : 30,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: isNarrow ? 12 : 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final columns = width >= 800
                              ? 3
                              : width >= 570
                              ? 2
                              : 1;
                          final gap = isNarrow ? 10.0 : 14.0;
                          final tileWidth =
                              (width - (columns - 1) * gap) / columns;
                          final minHeight = isNarrow
                              ? 76.0
                              : columns == 3
                              ? 142.0
                              : 108.0;

                          return Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: [
                              for (final item in items)
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: tileWidth,
                                    maxWidth: tileWidth,
                                    minHeight: minHeight,
                                  ),
                                  child: ItemCard(item: item),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
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

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < _compactWidth;
    final radius = BorderRadius.circular(isNarrow ? 25 : 32);

    return PortfolioGlassPanel(
      borderRadius: radius,
      padding: EdgeInsets.all(isNarrow ? 16 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMPUTER SCIENCE · UNIVERSITAS INDONESIA',
            style: TextStyle(
              color: Color(0xFF655D61),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: isNarrow ? 1.2 : 1.7,
              height: isNarrow ? 1.3 : 1.5,
            ),
          ),
          SizedBox(height: isNarrow ? 8 : 20),
          Text(
            'Hi, I’m Vanka.',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              color: PortfolioColors.ink,
              fontSize: isNarrow ? 34 : 66,
              fontWeight: FontWeight.w700,
              letterSpacing: isNarrow ? -0.6 : -1.2,
              height: 1.12,
            ),
          ),
          SizedBox(height: isNarrow ? 6 : 18),
          Text(
            'Rayna Kayla Rayvanka',
            style: TextStyle(
              color: PortfolioColors.ink,
              fontSize: isNarrow ? 16 : 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: isNarrow ? 8 : 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              'Computer Science student at Universitas Indonesia who somehow keeps ending up in tech projects, events, and creative spaces — usually all at the same time.',
              style: TextStyle(
                color: PortfolioColors.muted,
                fontSize: isNarrow ? 14 : 15,
                height: isNarrow ? 1.45 : 1.55,
              ),
            ),
          ),
          SizedBox(height: isNarrow ? 14 : 32),
          Container(height: 1, color: const Color(0x1C4D4046)),
          SizedBox(height: isNarrow ? 10 : 22),
          const Text(
            'AT A GLANCE',
            style: TextStyle(
              color: PortfolioColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          SizedBox(height: isNarrow ? 8 : 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              const npm = InfoCard(label: 'NPM', value: '2506657283');
              const name = InfoCard(
                label: 'Nama',
                value: 'Rayna Kayla Rayvanka',
              );
              const studentClass = InfoCard(label: 'Kelas', value: 'PBP F');
              const cards = [npm, name, studentClass];

              if (isNarrow) {
                const gap = 8.0;
                final halfWidth = (width - gap) / 2;
                final textScale =
                    MediaQuery.textScalerOf(context).scale(15) / 15;
                final shortCardWidth = halfWidth >= 120 * textScale
                    ? halfWidth
                    : width;

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    name,
                    SizedBox(width: shortCardWidth, child: npm),
                    SizedBox(width: shortCardWidth, child: studentClass),
                  ],
                );
              }

              if (width >= 720) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              }

              if (width >= 500) {
                final cardWidth = (width - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final card in cards)
                      SizedBox(width: cardWidth, child: card),
                  ],
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    cards[i],
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < _compactWidth;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 12 : 17,
        vertical: isNarrow ? 8 : 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0x68FFFEFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x2489506C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: PortfolioColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          SizedBox(height: isNarrow ? 3 : 7),
          Text(
            value,
            style: const TextStyle(
              color: PortfolioColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item});

  final ItemHomepage item;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < _compactWidth;
    final radius = BorderRadius.circular(20);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xF5FFFFFF),
            item.accent.withValues(alpha: 0.70),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1689536C),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: OutlinedButton(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18, vertical: isNarrow ? 12 : 18),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: radius),
          ),
          animationDuration: const Duration(milliseconds: 160),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return BorderSide(color: item.accentInk, width: 2);
            }
            final isHovered = states.contains(WidgetState.hovered);
            return BorderSide(
              color: item.accentInk.withValues(alpha: isHovered ? 0.45 : 0.20),
            );
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return item.accentInk.withValues(alpha: 0.16);
            }
            if (states.contains(WidgetState.hovered)) {
              return item.accentInk.withValues(alpha: 0.07);
            }
            return Colors.transparent;
          }),
        ),
        onPressed: () {
          final messenger = ScaffoldMessenger.of(context);
          messenger.removeCurrentSnackBar();
          if (item.name == 'Tambah Experience') {
            _openExperience(context);
            return;
          }
          messenger.showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: PortfolioColors.ink,
              content: Text('Kamu telah menekan tombol ${item.name}!'),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.accent.withValues(alpha: 0.70),
                border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.accentInk, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  color: PortfolioColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, color: item.accentInk, size: 18),
          ],
        ),
      ),
    );
  }
}
