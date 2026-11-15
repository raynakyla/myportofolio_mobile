import 'dart:ui';

import 'package:flutter/material.dart';

const _compactWidth = 600.0;

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

  static const _maxContentWidth = 984.0;

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
    final isNarrow = MediaQuery.sizeOf(context).width < _compactWidth;
    final horizontalPadding = isNarrow ? 16.0 : 28.0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isNarrow ? 72 : 88,
        titleSpacing: horizontalPadding,
        backgroundColor: _PortfolioColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Container(
              height: isNarrow ? 48 : 58,
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
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  isNarrow ? 16 : 24,
                  horizontalPadding,
                  isNarrow ? 32 : 52,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _HeroCard(),
                        SizedBox(height: isNarrow ? 22 : 42),
                        const Text(
                          'EXPLORE',
                          style: TextStyle(
                            color: _PortfolioColors.muted,
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
                            color: _PortfolioColors.ink,
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
    final isNarrow = MediaQuery.sizeOf(context).width < _compactWidth;
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
            padding: EdgeInsets.all(isNarrow ? 16 : 48),
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
                    color: _PortfolioColors.ink,
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
                    color: _PortfolioColors.ink,
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
                      color: _PortfolioColors.muted,
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
                    color: _PortfolioColors.muted,
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
                    const studentClass = InfoCard(
                      label: 'Kelas',
                      value: 'PBP F',
                    );
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
    final isNarrow = MediaQuery.sizeOf(context).width < _compactWidth;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 12 : 17,
        vertical: isNarrow ? 8 : 15,
      ),
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
          SizedBox(height: isNarrow ? 3 : 7),
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
    final isNarrow = MediaQuery.sizeOf(context).width < _compactWidth;

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
            padding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: isNarrow ? 12 : 18,
            ),
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
