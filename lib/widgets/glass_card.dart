import 'package:flutter/material.dart';
import '../theme.dart';

enum GlowType { none, primary, secondary, accent }

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final GlowType glow;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.glow = GlowType.none,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    BoxShadow? glowShadow;
    
    switch (glow) {
      case GlowType.primary:
        glowShadow = BoxShadow(
          color: AppColors.primary.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, 8),
        );
        break;
      case GlowType.secondary:
        glowShadow = BoxShadow(
          color: AppColors.accent.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, 8),
        );
        break;
      case GlowType.accent:
        glowShadow = BoxShadow(
          color: AppColors.success.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, 8),
        );
        break;
      case GlowType.none:
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: glowShadow != null ? [glowShadow] : null,
      ),
      child: child,
    );
  }
}
