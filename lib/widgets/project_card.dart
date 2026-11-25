import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_panel.dart';
import 'package:myportofolio_mobile/widgets/project_thumbnail.dart';

class ProjectBadges extends StatelessWidget {
  const ProjectBadges({super.key, required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      _badge(project.category.label, PortfolioColors.lavender),
      if (project.isFeatured) _badge('Pilihan', PortfolioColors.yellow),
    ],
  );

  Widget _badge(String label, Color color) => DecoratedBox(
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: PortfolioColors.roseInk,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          height: 1.4,
        ),
      ),
    ),
  );
}

class ProjectCard extends StatefulWidget {
  const ProjectCard({super.key, required this.project, required this.onTap});
  final Project project;
  final VoidCallback onTap;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  final _states = WidgetStatesController();

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _states,
    builder: (context, _) {
      final focused = _states.value.contains(WidgetState.focused);
      final hovered = _states.value.contains(WidgetState.hovered);
      final pressed = _states.value.contains(WidgetState.pressed);
      final radius = BorderRadius.circular(26);
      return AnimatedScale(
        scale: pressed ? 0.99 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              if (focused)
                const BoxShadow(
                  color: PortfolioColors.roseInk,
                  spreadRadius: 3,
                ),
              BoxShadow(
                color: PortfolioColors.mauve.withValues(
                  alpha: hovered ? 0.20 : 0.08,
                ),
                blurRadius: pressed ? 6 : 24,
                offset: Offset(0, pressed ? 2 : 8),
              ),
            ],
          ),
          child: PortfolioGlassPanel(
            padding: EdgeInsets.zero,
            borderRadius: radius,
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                statesController: _states,
                onTap: widget.onTap,
                borderRadius: radius,
                focusColor: PortfolioColors.lavender.withValues(alpha: 0.3),
                hoverColor: Colors.white.withValues(alpha: 0.35),
                splashColor: PortfolioColors.pink.withValues(alpha: 0.5),
                child: Container(
                  decoration: BoxDecoration(
                    border: const Border(
                      top: BorderSide(color: Colors.white, width: 2),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0x30FFFFFF),
                        PortfolioColors.lavender.withValues(alpha: 0.10),
                        PortfolioColors.pink.withValues(alpha: 0.12),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final image = ProjectThumbnail(
                        url: widget.project.thumbnail,
                        title: widget.project.title,
                      );
                      final content = _content();
                      if (constraints.maxWidth >= 680) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 235, child: image),
                            const SizedBox(width: 26),
                            Expanded(child: content),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [image, const SizedBox(height: 20), content],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _content() {
    final project = widget.project;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProjectBadges(project: project),
        const SizedBox(height: 14),
        Text(
          project.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: PortfolioColors.ink,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          project.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: PortfolioColors.ink, height: 1.6),
        ),
        if (project.role.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            project.role,
            style: const TextStyle(
              color: PortfolioColors.roseInk,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '★ ${project.starCount} apresiasi',
              style: const TextStyle(
                color: PortfolioColors.roseInk,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lihat detail',
                  style: TextStyle(
                    color: PortfolioColors.roseInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: PortfolioColors.roseInk,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
