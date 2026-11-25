import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_detail_page.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';
import 'package:myportofolio_mobile/widgets/portfolio_background.dart';
import 'package:myportofolio_mobile/widgets/portfolio_drawer.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_button.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_panel.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key, this.apiClient});
  final ApiClient? apiClient;

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  late ApiClient _client;
  late Future<List<Project>> _projects;

  @override
  void initState() {
    super.initState();
    _client = widget.apiClient ?? ApiClient();
    _projects = _client.getProjects();
  }

  @override
  void didUpdateWidget(covariant ProjectListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.apiClient != widget.apiClient) {
      if (oldWidget.apiClient == null) _client.close();
      _client = widget.apiClient ?? ApiClient();
      _projects = _client.getProjects();
    }
  }

  @override
  void dispose() {
    if (widget.apiClient == null) _client.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    final updated = _client.getProjects();
    setState(() {
      _projects = updated;
    });
    try {
      await updated;
    } catch (_) {
      // FutureBuilder renders the failure; RefreshIndicator can finish normally.
    }
  }

  Widget _bounded(Widget child) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1040),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const PortfolioDrawer(
      currentDestination: PortfolioDestination.projects,
    ),
    appBar: AppBar(
      leading: const BackButton(),
      title: const Text('Proyek'),
      actions: [
        IconButton(
          tooltip: 'Muat ulang proyek',
          onPressed: _refresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
        Builder(
          builder: (context) => IconButton(
            tooltip: 'Buka navigasi',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded),
          ),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: PortfolioBackground(
      child: SafeArea(
        child: FutureBuilder<List<Project>>(
          future: _projects,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState != ConnectionState.done;
            final projects = snapshot.data ?? const <Project>[];
            final error = snapshot.error;
            final horizontal = MediaQuery.sizeOf(context).width < 600
                ? 16.0
                : 28.0;
            return RefreshIndicator(
              onRefresh: _refresh,
              color: PortfolioColors.roseInk,
              child: CustomScrollView(
                key: const PageStorageKey('project-list-scroll'),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      24,
                      horizontal,
                      24,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _bounded(
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SELECTED WORK',
                              style: TextStyle(
                                color: PortfolioColors.roseInk,
                                letterSpacing: 2,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Proyek & cerita',
                              style: TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 36,
                                height: 1.2,
                                fontWeight: FontWeight.w600,
                                color: PortfolioColors.ink,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Karya, peran, dan hal-hal yang saya pelajari di sepanjang perjalanan.',
                              style: TextStyle(
                                color: PortfolioColors.ink,
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tarik ke bawah untuk memperbarui.',
                              style: TextStyle(
                                color: PortfolioColors.roseInk,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (loading || error != null || projects.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontal,
                          8,
                          horizontal,
                          40,
                        ),
                        child: _bounded(
                          _status(
                            loading: loading,
                            title: error != null
                                ? 'Belum bisa memuat proyek'
                                : 'Belum ada proyek',
                            message: error != null
                                ? (error is ApiException
                                      ? error.message
                                      : 'Proyek belum dapat dimuat. Silakan coba lagi.')
                                : 'Proyek yang dipublikasikan akan tampil di sini. Tarik ke bawah untuk memeriksa lagi.',
                            retry: error != null,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontal,
                        0,
                        horizontal,
                        40,
                      ),
                      sliver: SliverList.builder(
                        itemCount: projects.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _bounded(
                            ProjectCard(
                              project: projects[index],
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    settings: const RouteSettings(
                                      name: '/projects/detail',
                                    ),
                                    builder: (_) => ProjectDetailPage(
                                      project: projects[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );

  Widget _status({
    required bool loading,
    required String title,
    required String message,
    required bool retry,
  }) => PortfolioGlassPanel(
    padding: const EdgeInsets.all(28),
    borderRadius: BorderRadius.circular(26),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loading) ...[
          const CircularProgressIndicator(semanticsLabel: 'Memuat proyek'),
          const SizedBox(height: 20),
          const Text(
            'Memuat proyek…',
            style: TextStyle(color: PortfolioColors.ink),
          ),
        ] else ...[
          Icon(
            retry ? Icons.cloud_off_rounded : Icons.auto_awesome_outlined,
            size: 38,
            color: PortfolioColors.roseInk,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: PortfolioColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: PortfolioColors.ink, height: 1.6),
          ),
          if (retry) ...[
            const SizedBox(height: 24),
            PortfolioGlassButton(
              label: 'Coba Lagi',
              icon: Icons.refresh_rounded,
              onPressed: _refresh,
            ),
          ],
        ],
      ],
    ),
  );
}
