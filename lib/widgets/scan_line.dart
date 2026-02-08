import 'package:flutter/material.dart';
import '../theme.dart';

class ScanLine extends StatefulWidget {
  final bool active;

  const ScanLine({super.key, required this.active});

  @override
  State<ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<ScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.1, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.active) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ScanLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ScanLinePainter(progress: _animation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class ScanLinePainter extends CustomPainter {
  final double progress;

  ScanLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final lineY = size.height * progress;
    final margin = size.width * 0.08;

    final gradient = LinearGradient(
      colors: [
        Colors.transparent,
        AppColors.primary.withOpacity(0.3),
        AppColors.primary,
        AppColors.primary.withOpacity(0.3),
        Colors.transparent,
      ],
      stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(margin, lineY - 1, size.width - (margin * 2), 2),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawRect(
      Rect.fromLTWH(margin, lineY - 1, size.width - (margin * 2), 2),
      paint,
    );

    // Add stronger glow
    final glowPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(margin, lineY - 1, size.width - (margin * 2), 2),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);

    canvas.drawRect(
      Rect.fromLTWH(margin, lineY - 1, size.width - (margin * 2), 2),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
