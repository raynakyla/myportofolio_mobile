import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/experience_data.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_button.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_panel.dart';

class ExperienceSummaryDialog extends StatelessWidget {
  const ExperienceSummaryDialog({super.key, required this.experience});

  final ExperienceDraft experience;

  String _formatUtc(DateTime value) {
    final date = value.toUtc();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-'
        '${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)} UTC';
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      // The blur is clipped to this panel, not the entire screen.
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: ColoredBox(
          color: PortfolioColors.cream.withValues(alpha: 0.94),
          child: PortfolioGlassPanel(
            padding: EdgeInsets.zero,
            borderRadius: radius,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: PortfolioColors.yellow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'PREVIEW LOKAL',
                          style: TextStyle(
                            color: PortfolioColors.ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Semantics(
                        namesRoute: true,
                        header: true,
                        child: const Text(
                          'Ringkasan Experience',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            color: PortfolioColors.ink,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: PortfolioColors.line),
                Flexible(
                  child: SingleChildScrollView(
                    key: const ValueKey('summary_scroll'),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Periksa kembali isianmu. Data ini belum dikirim ke server.',
                          style: TextStyle(
                            color: PortfolioColors.muted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _SummaryField(
                          name: 'title',
                          label: 'Judul',
                          value: experience.title,
                        ),
                        _SummaryField(
                          name: 'description',
                          label: 'Deskripsi',
                          value: experience.description,
                        ),
                        _SummaryField(
                          name: 'category',
                          label: 'Kategori',
                          value: experience.category.label,
                        ),
                        _SummaryField(
                          name: 'thumbnail',
                          label: 'URL thumbnail',
                          value: experience.thumbnail ?? 'Tidak diisi',
                        ),
                        _SummaryField(
                          name: 'started_at',
                          label: 'Tanggal mulai',
                          value: experience.startedAt == null
                              ? 'Tidak diisi'
                              : _formatUtc(experience.startedAt!),
                        ),
                        _SummaryField(
                          name: 'is_ongoing',
                          label: 'Masih berlangsung',
                          value: experience.isOngoing ? 'Ya' : 'Tidak',
                        ),
                        _SummaryField(
                          name: 'ended_at',
                          label: 'Tanggal akhir',
                          value: experience.endedAt == null
                              ? 'Belum berakhir — masih berlangsung'
                              : _formatUtc(experience.endedAt!),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xEFFFF9F3),
                    border: Border(
                      top: BorderSide(color: PortfolioColors.line),
                    ),
                  ),
                  child: PortfolioGlassButton(
                    label: 'Tutup',
                    icon: Icons.close_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryField extends StatelessWidget {
  const _SummaryField({
    required this.name,
    required this.label,
    required this.value,
  });

  final String name;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: PortfolioColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            key: ValueKey('summary_$name'),
            style: const TextStyle(
              color: PortfolioColors.ink,
              fontFamily: 'DM Sans',
              fontSize: 15,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
