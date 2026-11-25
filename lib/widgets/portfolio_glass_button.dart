import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';

/// A shared glass action with a visible focus ring and pressed feedback.
/// Its sheen uses gradients, avoiding a backdrop blur on every button.
class PortfolioGlassButton extends StatefulWidget {
  const PortfolioGlassButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  State<PortfolioGlassButton> createState() => _PortfolioGlassButtonState();
}

class _PortfolioGlassButtonState extends State<PortfolioGlassButton> {
  final _states = WidgetStatesController();
  final _visualRevision = ValueNotifier<int>(0);
  bool _rebuildScheduled = false;

  @override
  void initState() {
    super.initState();
    _states.addListener(_syncVisualState);
  }

  void _syncVisualState() {
    // Buttons update disabled state during build. Defer only those notifications;
    // pointer and keyboard feedback can still rebuild immediately between frames.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      if (_rebuildScheduled) return;
      _rebuildScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _rebuildScheduled = false;
        if (mounted) _visualRevision.value++;
      });
    } else {
      _visualRevision.value++;
    }
  }

  @override
  void dispose() {
    _states.removeListener(_syncVisualState);
    _states.dispose();
    _visualRevision.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return ListenableBuilder(
      listenable: _visualRevision,
      builder: (context, child) {
        final pressed = _states.value.contains(WidgetState.pressed);
        final focused = _states.value.contains(WidgetState.focused);
        final hovered = _states.value.contains(WidgetState.hovered);
        return AnimatedScale(
          scale: pressed ? 0.985 : 1,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF8FC),
                  PortfolioColors.pink,
                  Color(0xFFF8DCE6),
                  Color(0xFFFFF0C9),
                ],
                stops: [0, 0.32, 0.7, 1],
              ),
              boxShadow: [
                if (focused)
                  const BoxShadow(
                    color: PortfolioColors.roseInk,
                    spreadRadius: 3,
                  ),
                BoxShadow(
                  color: PortfolioColors.mauve.withValues(
                    alpha: pressed
                        ? 0.08
                        : hovered
                        ? 0.23
                        : 0.16,
                  ),
                  blurRadius: pressed ? 5 : 20,
                  offset: Offset(0, pressed ? 2 : 7),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: FilledButton.icon(
        statesController: _states,
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: const WidgetStatePropertyAll(
            PortfolioColors.roseInk,
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return PortfolioColors.roseInk.withValues(alpha: 0.16);
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return PortfolioColors.roseInk.withValues(alpha: 0.07);
            }
            return Colors.transparent;
          }),
          minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 56)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: Color(0xF2FFFFFF), width: 1.5),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: radius),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        onPressed: widget.onPressed,
        icon: Icon(widget.icon, size: 22),
        label: Text(widget.label),
      ),
    );
  }
}
