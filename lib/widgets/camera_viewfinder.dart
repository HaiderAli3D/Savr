import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

class CameraViewfinder extends StatelessWidget {
  const CameraViewfinder({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Corner brackets
        Positioned(
          top: 0,
          left: 0,
          child: _ViewfinderCorner(
            alignment: Alignment.topLeft,
          ).animate().scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.0, 1.0),
            duration: 400.ms,
            delay: 100.ms,
            curve: Curves.elasticOut,
          ).fade(duration: 400.ms, delay: 100.ms),
        ),
        
        Positioned(
          top: 0,
          right: 0,
          child: _ViewfinderCorner(
            alignment: Alignment.topRight,
          ).animate().scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.0, 1.0),
            duration: 400.ms,
            delay: 150.ms,
            curve: Curves.elasticOut,
          ).fade(duration: 400.ms, delay: 150.ms),
        ),
        
        Positioned(
          bottom: 0,
          left: 0,
          child: _ViewfinderCorner(
            alignment: Alignment.bottomLeft,
          ).animate().scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.0, 1.0),
            duration: 400.ms,
            delay: 250.ms,
            curve: Curves.elasticOut,
          ).fade(duration: 400.ms, delay: 250.ms),
        ),
        
        Positioned(
          bottom: 0,
          right: 0,
          child: _ViewfinderCorner(
            alignment: Alignment.bottomRight,
          ).animate().scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.0, 1.0),
            duration: 400.ms,
            delay: 200.ms,
            curve: Curves.elasticOut,
          ).fade(duration: 400.ms, delay: 200.ms),
        ),
      ],
    );
  }
}

class _ViewfinderCorner extends StatelessWidget {
  final Alignment alignment;
  
  const _ViewfinderCorner({required this.alignment});

  @override
  Widget build(BuildContext context) {
    const cornerSize = 32.0;
    const strokeWidth = 3.0;
    const cornerRadius = 16.0;
    
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    
    return Container(
      width: cornerSize,
      height: cornerSize,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.25),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _CornerPainter(
          isTop: isTop,
          isLeft: isLeft,
          strokeWidth: strokeWidth,
          cornerRadius: cornerRadius,
          color: Colors.white.withOpacity(0.85),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final double strokeWidth;
  final double cornerRadius;
  final Color color;
  
  _CornerPainter({
    required this.isTop,
    required this.isLeft,
    required this.strokeWidth,
    required this.cornerRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    if (isTop && isLeft) {
      // Top-left corner
      path.moveTo(strokeWidth / 2, size.height);
      path.lineTo(strokeWidth / 2, cornerRadius + strokeWidth / 2);
      path.quadraticBezierTo(
        strokeWidth / 2, 
        strokeWidth / 2, 
        cornerRadius + strokeWidth / 2, 
        strokeWidth / 2
      );
      path.lineTo(size.width, strokeWidth / 2);
    } else if (isTop && !isLeft) {
      // Top-right corner
      path.moveTo(size.width - strokeWidth / 2, size.height);
      path.lineTo(size.width - strokeWidth / 2, cornerRadius + strokeWidth / 2);
      path.quadraticBezierTo(
        size.width - strokeWidth / 2,
        strokeWidth / 2,
        size.width - cornerRadius - strokeWidth / 2,
        strokeWidth / 2
      );
      path.lineTo(0, strokeWidth / 2);
    } else if (!isTop && isLeft) {
      // Bottom-left corner
      path.moveTo(strokeWidth / 2, 0);
      path.lineTo(strokeWidth / 2, size.height - cornerRadius - strokeWidth / 2);
      path.quadraticBezierTo(
        strokeWidth / 2,
        size.height - strokeWidth / 2,
        cornerRadius + strokeWidth / 2,
        size.height - strokeWidth / 2
      );
      path.lineTo(size.width, size.height - strokeWidth / 2);
    } else {
      // Bottom-right corner
      path.moveTo(size.width - strokeWidth / 2, 0);
      path.lineTo(size.width - strokeWidth / 2, size.height - cornerRadius - strokeWidth / 2);
      path.quadraticBezierTo(
        size.width - strokeWidth / 2,
        size.height - strokeWidth / 2,
        size.width - cornerRadius - strokeWidth / 2,
        size.height - strokeWidth / 2
      );
      path.lineTo(0, size.height - strokeWidth / 2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}