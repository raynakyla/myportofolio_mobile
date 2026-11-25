import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';

Uri? projectWebUri(String value) {
  final uri = Uri.tryParse(value.trim());
  return uri != null &&
          (uri.scheme == 'https' || uri.scheme == 'http') &&
          uri.host.isNotEmpty
      ? uri
      : null;
}

class ProjectThumbnail extends StatelessWidget {
  const ProjectThumbnail({super.key, required this.url, required this.title});

  final String url;
  final String title;

  Widget _fallback() => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF8FC),
          PortfolioColors.lavender,
          Color(0xFFFFEDC2),
        ],
      ),
    ),
    child: Center(
      child: Semantics(
        label: 'Pratinjau belum tersedia',
        image: true,
        child: const Icon(
          Icons.layers_outlined,
          size: 44,
          color: PortfolioColors.roseInk,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final uri = projectWebUri(url);
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: uri == null
            ? _fallback()
            : Image.network(
                uri.toString(),
                fit: BoxFit.cover,
                semanticLabel: 'Pratinjau $title',
                frameBuilder: (context, child, frame, synchronous) =>
                    synchronous || frame != null ? child : _fallback(),
                errorBuilder: (context, error, stack) => _fallback(),
              ),
      ),
    );
  }
}
