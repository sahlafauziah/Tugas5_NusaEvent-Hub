import 'package:flutter/material.dart';

/// Denah venue yang bisa digeser dan di-zoom memakai [InteractiveViewer].
/// Letakkan gambar denah di assets/images/venue_map.png.
/// Jika belum ada, ditampilkan denah placeholder.
class VenueMapViewer extends StatefulWidget {
  const VenueMapViewer({
    super.key,
    this.assetPath = 'assets/images/venue_map.png',
  });

  final String assetPath;

  @override
  State<VenueMapViewer> createState() => _VenueMapViewerState();
}

class _VenueMapViewerState extends State<VenueMapViewer> {
  static const double _minScale = 0.8;
  static const double _maxScale = 5.0;

  final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Zoom terhadap titik tengah viewport.
  void _zoom(double factor, Size viewport) {
    final current = _controller.value;
    final currentScale = current.getMaxScaleOnAxis();
    final target =
        (currentScale * factor).clamp(_minScale, _maxScale).toDouble();
    final applied = target / currentScale;
    final cx = viewport.width / 2;
    final cy = viewport.height / 2;
    _controller.value = Matrix4.translationValues(cx, cy, 0) *
        Matrix4.diagonal3Values(applied, applied, 1) *
        Matrix4.translationValues(-cx, -cy, 0) *
        current;
  }

  void _reset() => _controller.value = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 2, 2, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Peta Area NusaEvent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        SizedBox(height: 3),
                        Text('Kenali fasilitas dan titik registrasi.', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(20)),
                    child: Row(children: [Icon(Icons.touch_app_rounded, size: 15, color: scheme.onSecondaryContainer), const SizedBox(width: 5), Text('Interaktif', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: scheme.onSecondaryContainer))]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: scheme.outlineVariant),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      InteractiveViewer(
                        transformationController: _controller,
                        minScale: _minScale,
                        maxScale: _maxScale,
                        boundaryMargin: const EdgeInsets.all(64),
                        child: Center(
                          child: Image.asset(
                            widget.assetPath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const _PlaceholderVenueMap(),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton.filledTonal(
                              tooltip: 'Perbesar',
                              onPressed: () => _zoom(1.4, viewport),
                              icon: const Icon(Icons.add_rounded),
                            ),
                            const SizedBox(height: 6),
                            IconButton.filledTonal(
                              tooltip: 'Perkecil',
                              onPressed: () => _zoom(1 / 1.4, viewport),
                              icon: const Icon(Icons.remove_rounded),
                            ),
                            const SizedBox(height: 6),
                            IconButton.filledTonal(
                              tooltip: 'Reset tampilan',
                              onPressed: _reset,
                              icon: const Icon(Icons.center_focus_strong_rounded),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cubit untuk memperbesar • Geser untuk melihat area lain',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        );
      },
    );
  }
}

class _Room {
  const _Room(this.label, this.left, this.top, this.width, this.height);

  final String label;
  final double left;
  final double top;
  final double width;
  final double height;
}

/// Denah sederhana (rasio 4:3) yang dipakai sampai gambar denah asli tersedia.
class _PlaceholderVenueMap extends StatelessWidget {
  const _PlaceholderVenueMap();

  static const List<_Room> _rooms = [
    _Room('Aula Utama', 0.04, 0.05, 0.56, 0.42),
    _Room('Workshop A', 0.64, 0.05, 0.32, 0.20),
    _Room('Workshop B', 0.64, 0.29, 0.32, 0.18),
    _Room('Lab Komputer', 0.04, 0.56, 0.30, 0.24),
    _Room('Lobi Registrasi', 0.38, 0.56, 0.26, 0.24),
    _Room('Food Court', 0.68, 0.56, 0.28, 0.24),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = [
      scheme.primaryContainer,
      scheme.secondaryContainer,
      scheme.tertiaryContainer,
    ];

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          return Stack(
            children: [
              // Koridor
              Positioned(
                left: w * 0.04,
                top: h * 0.485,
                width: w * 0.92,
                height: h * 0.05,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              for (var i = 0; i < _rooms.length; i++)
                Positioned(
                  left: w * _rooms[i].left,
                  top: h * _rooms[i].top,
                  width: w * _rooms[i].width,
                  height: h * _rooms[i].height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          _rooms[i].label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: w * 0.30,
                top: h * 0.85,
                width: w * 0.40,
                height: h * 0.09,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Pintu Masuk',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Text(
                  'Placeholder – simpan venue_map.png di assets/images/',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 9,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
