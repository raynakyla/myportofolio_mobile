import 'dart:ui';

import 'package:flutter/material.dart';

class _PortfolioColors {
  static const cream = Color(0xFFFFF9F3);
  static const pink = Color(0xFFF6CEDD);
  static const yellow = Color(0xFFFBE8A6);
  static const lavender = Color(0xFFDDD8F6);
  static const peach = Color(0xFFF7D4BF);
  static const blue = Color(0xFFDCEAF7);
  static const ink = Color(0xFF2F2A2D);
  static const muted = Color(0xFF746C70);
  static const mauve = Color(0xFF9D5F78);
}

class ItemHomepage {
  const ItemHomepage(this.name, this.icon, this.startColor, this.endColor);

  final String name;
  final IconData icon;
  final Color startColor;
  final Color endColor;
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  static const items = [
    ItemHomepage(
      'Lihat Proyek',
      Icons.folder_rounded,
      _PortfolioColors.pink,
      _PortfolioColors.lavender,
    ),
    ItemHomepage(
      'Tambah Proyek',
      Icons.add_circle_rounded,
      _PortfolioColors.yellow,
      _PortfolioColors.peach,
    ),
    ItemHomepage(
      'Logout',
      Icons.logout_rounded,
      _PortfolioColors.blue,
      _PortfolioColors.lavender,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 88,
        titleSpacing: screenWidth < 600 ? 16 : 28,
        backgroundColor: _PortfolioColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
                gradient: LinearGradient(
                  colors: [
                    _PortfolioColors.pink.withValues(alpha: 0.70),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rayna.',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      color: _PortfolioColors.mauve,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: _PortfolioColors.mauve,
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
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _PortfolioColors.cream,
                    Color(0xFFFFF5F8),
                    Color(0xFFFDF7FB),
                  ],
                  stops: [0, 0.46, 1],
                ),
              ),
            ),
          ),
          const Positioned(
            top: -160,
            left: -125,
            child: _PastelOrb(color: _PortfolioColors.yellow, size: 370),
          ),
          const Positioned(
            top: 60,
            right: -160,
            child: _PastelOrb(color: _PortfolioColors.pink, size: 430),
          ),
          const Positioned(
            bottom: -180,
            left: 80,
            child: _PastelOrb(color: _PortfolioColors.lavender, size: 390),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      screenWidth < 600 ? 16 : 28,
                      24,
                      screenWidth < 600 ? 16 : 28,
                      52,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _HeroCard(),
                        const SizedBox(height: 42),
                        const Text(
                          'EXPLORE',
                          style: TextStyle(
                            color: _PortfolioColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Where to next?',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            color: _PortfolioColors.ink,
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final columns = width >= 800
                                ? 3
                                : width >= 570
                                ? 2
                                : 1;
                            final tileWidth =
                                (width - (columns - 1) * 14) / columns;
                            final tileHeight = columns == 3 ? 142.0 : 108.0;

                            return GridView.count(
                              crossAxisCount: columns,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: tileWidth / tileHeight,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: items
                                  .map((item) => ItemCard(item: item))
                                  .toList(),
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
        ],
      ),
    );
  }
}

class _PastelOrb extends StatelessWidget {
  const _PastelOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.48),
                color.withValues(alpha: 0),
              ],
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
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final radius = BorderRadius.circular(isNarrow ? 25 : 32);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x2489536C),
            blurRadius: 60,
            offset: Offset(0, 22),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isNarrow ? 24 : 48),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
              borderRadius: radius,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xE6FFFDFE), Color(0xB8FFF0F7)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COMPUTER SCIENCE · UNIVERSITAS INDONESIA',
                  style: TextStyle(
                    color: Color(0xFF655D61),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.7,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Hi, I’m Vanka.',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    color: _PortfolioColors.ink,
                    fontSize: isNarrow ? 42 : 66,
                    fontWeight: FontWeight.w700,
                    letterSpacing: isNarrow ? -0.6 : -1.2,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Rayna Kayla Rayvanka',
                  style: TextStyle(
                    color: _PortfolioColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: const Text(
                    'Computer Science student at Universitas Indonesia who somehow keeps ending up in tech projects, events, and creative spaces — usually all at the same time.',
                    style: TextStyle(
                      color: _PortfolioColors.muted,
                      fontSize: 15,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(height: 1, color: const Color(0x1C4D4046)),
                const SizedBox(height: 22),
                const Text(
                  'AT A GLANCE',
                  style: TextStyle(
                    color: _PortfolioColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    const cards = [
                      InfoCard(label: 'NPM', value: '2506657283'),
                      InfoCard(label: 'Nama', value: 'Rayna Kayla Rayvanka'),
                      InfoCard(label: 'Kelas', value: 'PBP F'),
                    ];

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
          ),
        ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xC7FFFFFF), Color(0x92FFF2F8)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F89536C),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: _PortfolioColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: _PortfolioColors.ink,
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
    return Material(
      color: Colors.transparent,
      elevation: 3,
      shadowColor: const Color(0x3389536C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.82)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.72),
              item.startColor.withValues(alpha: 0.68),
              item.endColor.withValues(alpha: 0.72),
            ],
          ),
        ),
        child: InkWell(
          onTap: () {
            final messenger = ScaffoldMessenger.of(context);
            messenger.removeCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: _PortfolioColors.ink,
                content: Text('Kamu telah menekan tombol ${item.name}!'),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.56),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.76),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: _PortfolioColors.mauve,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _PortfolioColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: _PortfolioColors.mauve,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
