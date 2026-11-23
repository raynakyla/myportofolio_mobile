import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';
import 'package:myportofolio_mobile/widgets/portfolio_drawer.dart';

const _compactWidth = 600.0;

class ItemHomepage {
  const ItemHomepage(this.name, this.icon, this.accent, this.accentInk);

  final String name;
  final IconData icon;
  final Color accent;
  final Color accentInk;
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
            openPortfolioDestination(context, PortfolioDestination.experience);
            return;
          }
          if (item.name == 'Tambah Project') {
            openPortfolioDestination(context, PortfolioDestination.project);
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
