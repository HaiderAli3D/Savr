import 'package:flutter/material.dart';
import '../theme.dart';

class CameraViewfinder extends StatefulWidget {
  const CameraViewfinder({super.key});

  @override
  State<CameraViewfinder> createState() => _CameraViewfinderState();
}

class _CameraViewfinderState extends State<CameraViewfinder>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ViewfinderPainter(opacity: _pulseAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class ViewfinderPainter extends CustomPainter {
  final double opacity;

  ViewfinderPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    const cornerSize = 32.0;
    const strokeWidth = 3.0;
    const radius = 16.0;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.85 * opacity)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Add glow effect
    final glowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3 * opacity)
      ..strokeWidth = strokeWidth + 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    void drawCorner(Offset start, bool isLeft, bool isTop) {
      final path = Path();
      
      if (isTop && isLeft) {
        // Top-left
        path.moveTo(start.dx, start.dy + cornerSize);
        path.lineTo(start.dx, start.dy + radius);
        path.arcToPoint(
          Offset(start.dx + radius, start.dy),
          radius: const Radius.circular(radius),
        );
        path.lineTo(start.dx + cornerSize, start.dy);
      } else if (isTop && !isLeft) {
        // Top-right
        path.moveTo(start.dx, start.dy);
        path.lineTo(start.dx - radius, start.dy);
        path.arcToPoint(
          Offset(start.dx, start.dy + radius),
          radius: const Radius.circular(radius),
        );
        path.lineTo(start.dx, start.dy + cornerSize);
      } else if (!isTop && isLeft) {
        // Bottom-left
        path.moveTo(start.dx, start.dy - cornerSize);
        path.lineTo(start.dx, start.dy - radius);
        path.arcToPoint(
          Offset(start.dx + radius, start.dy),
          radius: const Radius.circular(radius),
        );
        path.lineTo(start.dx + cornerSize, start.dy);
      } else {
        // Bottom-right
        path.moveTo(start.dx, start.dy);
        path.lineTo(start.dx - radius, start.dy);
        path.arcToPoint(
          Offset(start.dx, start.dy - radius),
          radius: const Radius.circular(radius),
        );
        path.lineTo(start.dx, start.dy - cornerSize);
      }

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }

    // Calculate viewfinder bounds (centered, with some margin)
    final margin = size.width * 0.08;
    final viewfinderRect = Rect.fromLTRB(
      margin,
      size.height * 0.25,
      size.width - margin,
      size.height * 0.75,
    );

    // Draw four corners
    drawCorner(viewfinderRect.topLeft, true, true);
    drawCorner(viewfinderRect.topRight, false, true);
    drawCorner(viewfinderRect.bottomLeft, true, false);
    drawCorner(viewfinderRect.bottomRight, false, false);
  }

  @override
  bool shouldRepaint(ViewfinderPainter oldDelegate) {
    return opacity != oldDelegate.opacity;
  }
}
