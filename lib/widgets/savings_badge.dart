import 'package:flutter/material.dart';
import '../theme.dart';

class SavingsBadge extends StatelessWidget {
  final double amount;
  final int? percent;
  final bool large;

  const SavingsBadge({
    super.key,
    required this.amount,
    this.percent,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.savingsBadgeBg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: AppColors.success.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_down,
            size: large ? 14 : 12,
            color: AppColors.savingsBadgeText,
          ),
          const SizedBox(width: 4),
          Text(
            percent != null
                ? 'Save $percent% · £${amount.toStringAsFixed(2)}'
                : 'Save £${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: large ? 12 : 10,
              fontWeight: FontWeight.w600,
              color: AppColors.savingsBadgeText,
            ),
          ),
        ],
      ),
    );
  }
}
