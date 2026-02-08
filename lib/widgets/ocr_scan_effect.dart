import 'package:flutter/material.dart';
import '../theme.dart';

class OcrScanEffect extends StatefulWidget {
  const OcrScanEffect({super.key});

  @override
  State<OcrScanEffect> createState() => _OcrScanEffectState();
}

class _OcrScanEffectState extends State<OcrScanEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanLineAnimation;

  final List<_ScanRegion> regions = [
    _ScanRegion(0.12, 0.18, 0.65, 0.035, 0.3),
    _ScanRegion(0.12, 0.24, 0.50, 0.035, 0.55),
    _ScanRegion(0.12, 0.30, 0.72, 0.035, 0.8),
    _ScanRegion(0.12, 0.36, 0.40, 0.035, 1.05),
    _ScanRegion(0.12, 0.42, 0.60, 0.035, 1.3),
    _ScanRegion(0.12, 0.48, 0.55, 0.035, 1.55),
    _ScanRegion(0.12, 0.54, 0.68, 0.035, 1.8),
    _ScanRegion(0.12, 0.60, 0.45, 0.035, 2.05),
    _ScanRegion(0.12, 0.66, 0.58, 0.035, 2.3),
    _ScanRegion(0.12, 0.72, 0.35, 0.035, 2.55),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );

    _scanLineAnimation = Tween<double>(begin: 0.15, end: 0.78).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scan regions
        ...regions.map((region) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final progress = _controller.value;
                final delay = region.delay / 2.8;
                final regionProgress = ((progress - delay) / 0.6).clamp(0.0, 1.0);

                if (regionProgress == 0) return const SizedBox.shrink();

                double opacity;
                double scaleX;
                Color bgColor;
                Color borderColor;

                if (regionProgress < 0.3) {
                  // Fade in
                  opacity = regionProgress / 0.3 * 0.9;
                  scaleX = 0.3 + (regionProgress / 0.3 * 0.7);
                  bgColor = AppColors.success.withOpacity(0.12);
                  borderColor = AppColors.success.withOpacity(0.3);
                } else if (regionProgress < 0.6) {
                  // Peak
                  opacity = 0.9;
                  scaleX = 1.0;
                  bgColor = AppColors.success.withOpacity(0.18);
                  borderColor = AppColors.success.withOpacity(0.5);
                } else {
                  // Fade out
                  final fadeOut = (regionProgress - 0.6) / 0.4;
                  opacity = 0.6 * (1 - fadeOut);
                  scaleX = 1.0;
                  bgColor = AppColors.success.withOpacity(0.08);
                  borderColor = AppColors.success.withOpacity(0.2);
                }

                return Positioned(
                  left: region.x * MediaQuery.of(context).size.width,
                  top: region.y * MediaQuery.of(context).size.height,
                  child: Transform.scale(
                    scaleX: scaleX,
                    alignment: Alignment.centerLeft,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: region.width * MediaQuery.of(context).size.width,
                        height: region.height * MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )),

        // Scanning cursor line
        AnimatedBuilder(
          animation: _scanLineAnimation,
          builder: (context, child) {
            return Positioned(
              top: _scanLineAnimation.value * MediaQuery.of(context).size.height,
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.success,
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ScanRegion {
  final double x;
  final double y;
  final double width;
  final double height;
  final double delay;

  _ScanRegion(this.x, this.y, this.width, this.height, this.delay);
}
