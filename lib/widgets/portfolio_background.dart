import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';

class PortfolioBackground extends StatelessWidget {
  const PortfolioBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PortfolioColors.cream,
                Color(0xFFFFF5F8),
                Color(0xFFF8F4FB),
              ],
            ),
          ),
        ),
        const Positioned(
          top: -140,
          left: -130,
          child: _PastelOrb(color: PortfolioColors.yellow, size: 360),
        ),
        const Positioned(
          top: 60,
          right: -180,
          child: _PastelOrb(color: PortfolioColors.pink, size: 440),
        ),
        const Positioned(
          bottom: -160,
          left: 60,
          child: _PastelOrb(color: PortfolioColors.lavender, size: 380),
        ),
        child,
      ],
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
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.45),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
