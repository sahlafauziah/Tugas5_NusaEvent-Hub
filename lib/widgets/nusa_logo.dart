import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Logo NusaEvent Hub: huruf "N" bergradasi ungu-pink di atas tile putih,
/// dengan kilau kecil di pojok kanan atas.
class NusaLogo extends StatelessWidget {
  const NusaLogo({super.key, this.size = 46});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo NusaEvent Hub',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _NusaLogoPainter()),
      ),
    );
  }
}

class _NusaLogoPainter extends CustomPainter {
  /// Seluruh gambar dirancang pada kanvas 48 x 48, lalu diskalakan.
  static const double _base = 48;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _base, size.height / _base);

    // Tile putih dengan bayangan lembut.
    final tile = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, _base, _base),
      const Radius.circular(15),
    );
    canvas.drawShadow(
      Path()..addRRect(tile),
      const Color(0x668E6FD8),
      4,
      false,
    );
    canvas.drawRRect(tile, Paint()..color = Colors.white);

    // Huruf N: satu goresan bersambung dengan ujung membulat.
    final n = Path()
      ..moveTo(14.5, 33)
      ..lineTo(14.5, 17)
      ..lineTo(30.5, 33)
      ..lineTo(30.5, 17);
    canvas.drawPath(
      n,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E6FD8), Color(0xFFE48DC2)],
        ).createShader(const Rect.fromLTWH(10, 14, 24, 22)),
    );

    // Kilau empat sudut.
    const cx = 37.0;
    const cy = 11.5;
    const r = 5.2;
    final spark = Path()
      ..moveTo(cx, cy - r)
      ..quadraticBezierTo(cx, cy, cx + r, cy)
      ..quadraticBezierTo(cx, cy, cx, cy + r)
      ..quadraticBezierTo(cx, cy, cx - r, cy)
      ..quadraticBezierTo(cx, cy, cx, cy - r)
      ..close();
    canvas.drawPath(spark, Paint()..color = AppColors.pink);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
