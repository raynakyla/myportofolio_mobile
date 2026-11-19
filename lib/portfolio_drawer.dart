import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/portfolio_style.dart';

enum PortfolioDestination {
  home('Home', Icons.home_outlined),
  experience('Tambah Experience', Icons.work_outline_rounded);

  const PortfolioDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}

class PortfolioDrawer extends StatelessWidget {
  const PortfolioDrawer({
    super.key,
    required this.currentDestination,
    required this.onDestinationSelected,
  });

  final PortfolioDestination currentDestination;
  final ValueChanged<PortfolioDestination> onDestinationSelected;

  void _select(BuildContext context, PortfolioDestination destination) {
    // Close the drawer via Scaffold so this never pops the page underneath it.
    Scaffold.of(context).closeDrawer();
    if (destination != currentDestination) {
      onDestinationSelected(destination);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: math.min(320, MediaQuery.sizeOf(context).width * 0.9),
      backgroundColor: PortfolioColors.cream,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Rayna.',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: PortfolioColors.mauve,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup navigasi',
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: () => Scaffold.of(context).closeDrawer(),
                  icon: const Icon(Icons.close_rounded),
                  color: PortfolioColors.ink,
                ),
              ],
            ),
            const SizedBox(height: 24),
            PortfolioGlassPanel(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(22),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MyPortfolio',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: PortfolioColors.ink,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ruang untuk cerita dan pengalaman.',
                    style: TextStyle(color: PortfolioColors.muted, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.only(left: 12, bottom: 12),
              child: Text(
                'JELAJAHI',
                style: TextStyle(
                  color: PortfolioColors.muted,
                  fontSize: 11,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final destination in PortfolioDestination.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DestinationTile(
                  destination: destination,
                  selected: destination == currentDestination,
                  onTap: () => _select(context, destination),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final PortfolioDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: selected
            ? const LinearGradient(
                colors: [PortfolioColors.pink, Color(0xFFFCE7EE)],
              )
            : null,
        border: Border.all(
          color: selected ? PortfolioColors.mauve : const Color(0x30746C70),
        ),
      ),
      child: ListTile(
        selected: selected,
        minTileHeight: 64,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textColor: PortfolioColors.ink,
        iconColor: PortfolioColors.ink,
        selectedColor: PortfolioColors.ink,
        focusColor: PortfolioColors.mauve.withValues(alpha: 0.18),
        hoverColor: PortfolioColors.mauve.withValues(alpha: 0.10),
        leading: Icon(destination.icon),
        title: Text(
          destination.label,
          style: const TextStyle(fontWeight: FontWeight.w700, height: 1.4),
        ),
        trailing: selected
            ? const DecoratedBox(
                decoration: BoxDecoration(
                  color: PortfolioColors.yellow,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.check_rounded, size: 18),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
