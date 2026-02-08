import 'package:flutter/material.dart';
import '../theme.dart';

class CameraViewfinder extends StatefulWidget {
  const CameraViewfinder({super.key});

  @override
  State<CameraViewfinder> createState() => _CameraViewfinderState();
}

class _CameraViewfinderState extends State<CameraViewfinder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ViewfinderPainter(opacity: _animation.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  final double opacity;

  _ViewfinderPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(opacity)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final cornerLength = 24.0;
    final corners = [
      // Top-left
      [
        Offset(0, cornerLength),
        const Offset(0, 0),
        Offset(cornerLength, 0),
      ],
      // Top-right
      [
        Offset(size.width - cornerLength, 0),
        Offset(size.width, 0),
        Offset(size.width, cornerLength),
      ],
      // Bottom-right
      [
        Offset(size.width, size.height - cornerLength),
        Offset(size.width, size.height),
        Offset(size.width - cornerLength, size.height),
      ],
      // Bottom-left
      [
        Offset(cornerLength, size.height),
        Offset(0, size.height),
        Offset(0, size.height - cornerLength),
      ],
    ];

    for (final corner in corners) {
      final path = Path()
        ..moveTo(corner[0].dx, corner[0].dy)
        ..lineTo(corner[1].dx, corner[1].dy)
        ..lineTo(corner[2].dx, corner[2].dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ViewfinderPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
