import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Satu item pada [CurvedBottomNav].
class CurvedNavItem {
  const CurvedNavItem({
    required this.icon,
    required this.label,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;

  /// Jika > 0, tampil lencana angka di pojok ikon.
  final int badgeCount;
}

/// Navigasi bawah: bar putih dengan lekukan yang mengikuti item aktif,
/// dan item aktif tampil sebagai lingkaran gradasi ungu-pink yang menonjol.
///
/// [animation] dipakai agar lekukan ikut bergerak mulus saat tab digeser
/// (mis. dari `TabController.animation`).
class CurvedBottomNav extends StatelessWidget {
  const CurvedBottomNav({
    super.key,
    required this.items,
    required this.animation,
    required this.onTap,
  });

  final List<CurvedNavItem> items;
  final Animation<double> animation;
  final ValueChanged<int> onTap;

  static const double _barHeight = 66;
  static const double _bumpHeight = 34;
  static const double _circleSize = 54;

  static const Color _inactive = Color(0xFF5E5873);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final totalHeight = _bumpHeight + _barHeight + bottomInset;

    return SizedBox(
      height: totalHeight,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final value =
              animation.value.clamp(0.0, items.length - 1.0).toDouble();

          return LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / items.length;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _NavBarPainter(
                        centerX: (value + 0.5) * itemWidth,
                        bumpHeight: _bumpHeight,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: _bumpHeight,
                    height: _barHeight,
                    child: Row(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Expanded(
                            child: _NavItem(
                              item: items[i],
                              // 1.0 = aktif penuh, 0.0 = tidak aktif.
                              t: (1 - (value - i).abs()).clamp(0.0, 1.0).toDouble(),
                              onTap: () => onTap(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.item, required this.t, required this.onTap});

  final CurvedNavItem item;
  final double t;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const circle = CurvedBottomNav._circleSize;
    final labelColor = Color.lerp(
      CurvedBottomNav._inactive,
      AppColors.pinkDeep,
      t,
    )!;

    Widget icon = Icon(
      item.icon,
      size: 24,
      color: Color.lerp(CurvedBottomNav._inactive, Colors.white, t),
    );
    if (item.badgeCount > 0) {
      icon = Badge(
        label: Text('${item.badgeCount}'),
        backgroundColor: Color.lerp(AppColors.pinkDeep, Colors.white, t),
        textColor: Color.lerp(Colors.white, AppColors.pinkDeep, t),
        child: icon,
      );
    }

    return Semantics(
      button: true,
      selected: t > 0.5,
      label: item.label,
      child: InkResponse(
        onTap: onTap,
        radius: 40,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Lingkaran gradasi yang membesar + naik saat item aktif.
            Positioned(
              top: 8 - 36 * t, // naik hingga sejajar garis bar
              child: Transform.scale(
                scale: t,
                child: Container(
                  width: circle,
                  height: circle,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.headerGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pink.withValues(alpha: .45),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Ikon: ikut naik ke dalam lingkaran saat aktif.
            Positioned(
              top: 14 - 27 * t, // berpindah ke pusat lingkaran
              child: icon,
            ),
            // Label tetap di bawah.
            Positioned(
              left: 4,
              right: 4,
              bottom: 8,
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.1,
                  color: labelColor,
                  fontWeight: FontWeight.lerp(
                    FontWeight.w500,
                    FontWeight.w800,
                    t,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menggambar bar putih bersudut atas membulat dengan tonjolan halus
/// di atas posisi [centerX].
class _NavBarPainter extends CustomPainter {
  _NavBarPainter({required this.centerX, required this.bumpHeight});

  final double centerX;
  final double bumpHeight;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 20.0;
    const halfBump = 44.0;
    final top = bumpHeight;
    final w = size.width;
    final h = size.height;

    // Tonjolan boleh dekat tepi: ujungnya dijepit ke akhir sudut membulat.
    final cx = centerX.clamp(radius, w - radius).toDouble();
    final left = (cx - halfBump).clamp(radius, cx).toDouble();
    final right = (cx + halfBump).clamp(cx, w - radius).toDouble();
    final hl = cx - left;
    final hr = right - cx;

    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, top + radius)
      ..quadraticBezierTo(0, top, radius, top)
      ..lineTo(left, top)
      ..cubicTo(left + hl * 0.45, top, cx - hl * 0.4, 0, cx, 0)
      ..cubicTo(cx + hr * 0.4, 0, right - hr * 0.45, top, right, top)
      ..lineTo(w - radius, top)
      ..quadraticBezierTo(w, top, w, top + radius)
      ..lineTo(w, h)
      ..close();

    canvas.drawShadow(
      path,
      AppColors.purple.withValues(alpha: .55),
      10,
      false,
    );
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_NavBarPainter old) =>
      old.centerX != centerX || old.bumpHeight != bumpHeight;
}
