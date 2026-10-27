import 'package:flutter/material.dart';

/// A rich, vibrant, full-color vector Ballot Box Emoji (🗳️).
///
/// Guaranteed to render with authentic, high-resolution emoji colors
/// (royal blue box, crisp white ballot paper, emerald checkmark, 3D shading)
/// across all iOS, Android, web, and desktop viewports, avoiding monochrome
/// font character fallback issues.
class ColorBallotBoxEmoji extends StatelessWidget {
  final double size;

  const ColorBallotBoxEmoji({
    super.key,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _BallotBoxEmojiPainter(),
      ),
    );
  }
}

class _BallotBoxEmojiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Base coordinate system: 100 x 100
    canvas.save();
    canvas.scale(w / 100.0, h / 100.0);

    // 1. Soft ground shadow
    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      const Rect.fromLTRB(14, 84, 86, 96),
      shadowPaint,
    );

    // 2. Ballot Paper being inserted into slot
    // White paper slip tilted slightly
    final paperPath = Path()
      ..moveTo(36, 12)
      ..lineTo(64, 8)
      ..lineTo(60, 48)
      ..lineTo(32, 52)
      ..close();

    // Paper drop shadow
    final paperShadowPaint = Paint()
      ..color = const Color(0x22000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(paperPath.shift(const Offset(1, 2)), paperShadowPaint);

    // Paper fill with subtle gradient
    final paperGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
    ).createShader(const Rect.fromLTRB(32, 8, 64, 52));

    final paperPaint = Paint()
      ..shader = paperGradient
      ..style = PaintingStyle.fill;
    canvas.drawPath(paperPath, paperPaint);

    // Paper border
    final paperBorderPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(paperPath, paperBorderPaint);

    // Emerald Green checkmark on the ballot paper
    final checkmarkPaint = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path()
      ..moveTo(42, 26)
      ..lineTo(47, 32)
      ..lineTo(55, 20);
    canvas.drawPath(checkPath, checkmarkPaint);

    // 3. Ballot Box Top Face (Perspective Trapeze)
    final topFace = Path()
      ..moveTo(18, 54)
      ..lineTo(50, 42)
      ..lineTo(82, 54)
      ..lineTo(50, 66)
      ..close();

    final topGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    ).createShader(const Rect.fromLTRB(18, 42, 82, 66));

    canvas.drawPath(topFace, Paint()..shader = topGradient);

    // Top face subtle highlight border
    canvas.drawPath(
      topFace,
      Paint()
        ..color = const Color(0x40FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Slot (where the paper enters)
    final slotPath = Path()
      ..moveTo(36, 52)
      ..lineTo(64, 56)
      ..lineTo(62, 58)
      ..lineTo(34, 54)
      ..close();
    canvas.drawPath(
      slotPath,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.fill,
    );

    // 4. Ballot Box Front-Left Face
    final leftFace = Path()
      ..moveTo(18, 54)
      ..lineTo(50, 66)
      ..lineTo(50, 88)
      ..lineTo(18, 76)
      ..close();

    final leftGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    ).createShader(const Rect.fromLTRB(18, 54, 50, 88));

    canvas.drawPath(leftFace, Paint()..shader = leftGradient);

    // 5. Ballot Box Front-Right Face
    final rightFace = Path()
      ..moveTo(50, 66)
      ..lineTo(82, 54)
      ..lineTo(82, 76)
      ..lineTo(50, 88)
      ..close();

    final rightGradient = const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
    ).createShader(const Rect.fromLTRB(50, 54, 82, 88));

    canvas.drawPath(rightFace, Paint()..shader = rightGradient);

    // 6. Box Edges & Corner Highlight
    final edgePaint = Paint()
      ..color = const Color(0x30FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(const Offset(50, 66), const Offset(50, 88), edgePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
