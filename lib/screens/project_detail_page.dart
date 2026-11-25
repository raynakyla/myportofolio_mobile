import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';
import 'package:myportofolio_mobile/widgets/portfolio_background.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_button.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_panel.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:myportofolio_mobile/widgets/project_thumbnail.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key, required this.project, this.openUrl});
  final Project project;
  final Future<bool> Function(Uri)? openUrl;

  Future<void> _visit(BuildContext context, Uri uri) async {
    var opened = false;
    try {
      opened =
          await (openUrl?.call(uri) ??
              launchUrl(uri, mode: LaunchMode.externalApplication));
    } catch (_) {
      /* Show only a friendly message below. */
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tautan belum dapat dibuka. Silakan coba lagi.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uri = projectWebUri(project.projectUrl);
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail proyek')),
      body: PortfolioBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(narrow ? 16 : 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProjectBadges(project: project),
                    const SizedBox(height: 20),
                    Text(
                      project.title,
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: narrow ? 32 : 46,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: PortfolioColors.ink,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ProjectThumbnail(
                      url: project.thumbnail,
                      title: project.title,
                    ),
                    const SizedBox(height: 28),
                    PortfolioGlassPanel(
                      padding: EdgeInsets.all(narrow ? 22 : 36),
                      borderRadius: BorderRadius.circular(26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tentang proyek',
                            style: TextStyle(
                              fontFamily: 'Playfair Display',
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: PortfolioColors.ink,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SelectableText(
                            project.description.isEmpty
                                ? 'Deskripsi belum ditambahkan.'
                                : project.description,
                            style: const TextStyle(
                              color: PortfolioColors.ink,
                              height: 1.7,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _attribute('Peran', project.role),
                          _attribute('Keahlian', project.skills),
                          _attribute(
                            'Apresiasi',
                            '${project.starCount} bintang${project.isStarred ? ' · Anda memberi bintang' : ''}',
                          ),
                          if (project.starredByNames.isNotEmpty)
                            _attribute(
                              'Diberi bintang oleh',
                              project.starredByNames,
                            ),
                          if (uri != null) ...[
                            _attribute('Tautan proyek', uri.toString()),
                            PortfolioGlassButton(
                              label: 'Kunjungi proyek',
                              icon: Icons.open_in_new_rounded,
                              onPressed: () => _visit(context, uri),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _attribute(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: PortfolioColors.roseInk,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        SelectableText(
          value.isEmpty ? 'Belum ditambahkan' : value,
          style: const TextStyle(
            color: PortfolioColors.ink,
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ],
    ),
  );
}
