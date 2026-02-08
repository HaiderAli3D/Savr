import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/animated_counter.dart';
import '../widgets/page_shell.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for demo
    final receipts = _getMockReceipts();
    final totalSaved = receipts.fold<double>(0, (sum, r) => sum + r.totalSaved);
    final avgSavings = receipts.isEmpty ? 0.0 : totalSaved / receipts.length;
    final totalTrips = receipts.length;

    return PageShell(
      title: 'History',
      child: Column(
        children: [
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  label: 'TOTAL SAVED',
                  value: totalSaved,
                  color: AppColors.primary,
                  isCount: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.shopping_bag,
                  label: 'AVG / TRIP',
                  value: avgSavings,
                  color: AppColors.secondary,
                  isCount: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.bolt,
                  label: 'TRIPS',
                  value: totalTrips.toDouble(),
                  color: AppColors.accent,
                  isCount: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Simple Bar Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Savings Over Time',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedForeground,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 170,
                  child: _SimpleBarChart(data: receipts),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Recent Trips Section Header
          Text(
            'Recent Trips',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedForeground,
                ),
          ),

          const SizedBox(height: 12),

          // Recent Trips List
          ...receipts.asMap().entries.map((entry) {
            final receipt = entry.value;
            final index = entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 400 + (index * 40)),
                opacity: 1.0,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.muted,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Center(
                          child: Text(
                            receipt.date.day.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(receipt.date),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${receipt.itemCount} items · £${receipt.totalSpent.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.savingsBadgeBg,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          'Saved £${receipt.totalSaved.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.savingsBadgeText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  List<_Receipt> _getMockReceipts() {
    return [
      _Receipt(DateTime(2025, 2, 1), 42.30, 8.75, 6),
      _Receipt(DateTime(2025, 1, 25), 35.10, 6.20, 4),
      _Receipt(DateTime(2025, 1, 18), 58.90, 12.40, 8),
      _Receipt(DateTime(2025, 1, 11), 29.50, 5.10, 3),
      _Receipt(DateTime(2025, 1, 4), 47.80, 9.90, 5),
    ];
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;
  final bool isCount;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isCount,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedForeground,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            if (isCount)
              Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              )
            else
              AnimatedCounter(
                value: value,
                prefix: '£',
                decimals: 2,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  final List<_Receipt> data;

  const _SimpleBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final maxValue = data.map((r) => r.totalSaved).reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.reversed.map((receipt) {
        final height = (receipt.totalSaved / maxValue) * 140;
        final hue = 220 + (data.indexOf(receipt) / data.length * 60);
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              height: height,
              width: 32,
              decoration: BoxDecoration(
                color: HSLColor.fromAHSL(1.0, hue, 0.8, 0.62).toColor(),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                  bottom: Radius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${receipt.date.day} ${_getMonthAbbr(receipt.date.month)}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _Receipt {
  final DateTime date;
  final double totalSpent;
  final double totalSaved;
  final int itemCount;

  _Receipt(this.date, this.totalSpent, this.totalSaved, this.itemCount);
}
