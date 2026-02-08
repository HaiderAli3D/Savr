import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

class ScanLine extends StatelessWidget {
  final bool isActive;
  
  const ScanLine({
    super.key,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Animated scan line that moves up and down
        Positioned.fill(
          child: _AnimatedScanLine(),
        ),
        
        // Subtle gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.primary.withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedScanLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Main scanning line
            Positioned(
              left: 0,
              right: 0,
              child: _ScanLineContent(
                color: AppColors.primary.withOpacity(0.8),
                thickness: 2.0,
                glowRadius: 8.0,
              ).animate(onPlay: (controller) => controller.repeat())
                .moveY(
                  begin: -20,
                  end: constraints.maxHeight + 20,
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                ),
            ),
            
            // Secondary subtle line for depth
            Positioned(
              left: 0,
              right: 0,
              child: _ScanLineContent(
                color: Colors.white.withOpacity(0.3),
                thickness: 1.0,
                glowRadius: 4.0,
              ).animate(onPlay: (controller) => controller.repeat())
                .moveY(
                  begin: -15,
                  end: constraints.maxHeight + 15,
                  duration: 2200.ms,
                  curve: Curves.easeInOut,
                ),
            ),
          ],
        );
      },
    );
  }
}

class _ScanLineContent extends StatelessWidget {
  final Color color;
  final double thickness;
  final double glowRadius;
  
  const _ScanLineContent({
    required this.color,
    required this.thickness,
    required this.glowRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: thickness,
      decoration: BoxDecoration(
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: glowRadius,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: glowRadius * 2,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              color.withOpacity(0.8),
              color,
              color.withOpacity(0.8),
              Colors.transparent,
            ],
            stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
          ),
        ),
      ),
    );
  }
}
