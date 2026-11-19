import 'package:flutter/material.dart';

class PortfolioGlassPanel extends StatelessWidget {
  const PortfolioGlassPanel({
    super.key,
    required this.child,
    required this.padding,
    required this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xE0FFFDFE), Color(0xCCFFF0F7), Color(0xA6F5D1E5)],
          stops: [0, 0.5, 1],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1C89536C),
            blurRadius: 42,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xF2FFFFFF)),
          borderRadius: borderRadius,
          gradient: const RadialGradient(
            center: Alignment(0.78, -0.9),
            radius: 1.05,
            colors: [Color(0xF5FFFFFF), Color(0x70FFF9FD), Color(0x00FFF9FD)],
            stops: [0, 0.40, 1],
          ),
        ),
        child: child,
      ),
    );
  }
}
