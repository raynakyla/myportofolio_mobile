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
          colors: [Color(0xFAFFFEFF), Color(0xDEFFF2F8), Color(0xD9F3DCE8)],
          stops: [0, 0.55, 1],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1889536C),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x0D89536C),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xF2FFFFFF), width: 1.2),
          borderRadius: borderRadius,
          gradient: const RadialGradient(
            center: Alignment(-0.65, -1),
            radius: 1.4,
            colors: [Color(0xBFFFFFFF), Color(0x35FFF9FD), Color(0x00FFF9FD)],
            stops: [0, 0.5, 1],
          ),
        ),
        child: child,
      ),
    );
  }
}
