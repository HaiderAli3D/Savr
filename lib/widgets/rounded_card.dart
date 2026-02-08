import 'package:flutter/material.dart';
import '../theme.dart';

class RoundedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool withGlow;
  final Color? glowColor;

  const RoundedCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.withGlow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: (glowColor ?? AppColors.primary).withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: card,
      );
    }

    return card;
  }
}
