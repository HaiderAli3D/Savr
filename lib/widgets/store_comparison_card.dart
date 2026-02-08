import 'package:flutter/material.dart';
import '../theme.dart';

class StoreComparisonCard extends StatelessWidget {
  final String bestStore;
  final double extraSavings;
  final int extraPercent;
  final bool loading;
  final VoidCallback onCompare;

  const StoreComparisonCard({
    super.key,
    required this.bestStore,
    required this.extraSavings,
    required this.extraPercent,
    required this.loading,
    required this.onCompare,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              height: 20,
              width: 192,
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 32,
              width: 128,
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 160,
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: 1.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        offset: Offset.zero,
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store,
                    size: 14,
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'OTHER STORES',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                  children: [
                    const TextSpan(text: 'You could save '),
                    TextSpan(
                      text: '$extraPercent% more',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: ' if you shopped at '),
                    TextSpan(
                      text: bestStore,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onCompare,
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('Compare stores'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
