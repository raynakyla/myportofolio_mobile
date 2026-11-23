import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project_data.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_button.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_panel.dart';

class ProjectSummaryDialog extends StatelessWidget {
  const ProjectSummaryDialog({super.key, required this.project});

  final ProjectDraft project;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: PortfolioColors.cream,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      constraints: const BoxConstraints(maxWidth: 640),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text(
        'Ringkasan Project',
        style: TextStyle(
          fontFamily: 'Playfair Display',
          fontWeight: FontWeight.w600,
          color: PortfolioColors.ink,
        ),
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          key: const ValueKey('project_summary_scroll'),
          child: PortfolioGlassPanel(
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Preview lokal. Data ini belum dikirim ke Django.',
                  style: TextStyle(color: PortfolioColors.roseInk, height: 1.5),
                ),
                const SizedBox(height: 24),
                for (final field in [
                  ('title', 'Judul', project.title),
                  ('description', 'Deskripsi', project.description),
                  ('category', 'Kategori', project.category.label),
                  ('role', 'Peran', project.role),
                  ('skills', 'Keahlian', project.skills),
                ]) ...[
                  Text(
                    field.$2,
                    style: const TextStyle(
                      color: PortfolioColors.roseInk,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    field.$3,
                    key: ValueKey('project_summary_${field.$1}'),
                    style: const TextStyle(
                      color: PortfolioColors.ink,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        PortfolioGlassButton(
          label: 'Tutup',
          icon: Icons.close_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
