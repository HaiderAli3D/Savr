import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../data/models.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final report = appState.report;

    if (report == null) {
      // Should not happen if correctly navigated
      return const Scaffold(body: Center(child: Text("No report data")));
    }

    final currency = NumberFormat.simpleCurrency(name: 'GBP'); // Using GBP as per screenshot

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Savings Summary'),
         leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // Hero Savings Card
                   Container(
                     width: double.infinity,
                     padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(AppRadius.lg),
                     ),
                     child: Column(
                       children: [
                         const Text(
                           'You could have saved:',
                           style: TextStyle(
                             color: AppColors.textSecondary,
                             fontSize: 16,
                             fontWeight: FontWeight.w500,
                           ),
                         ),
                         const SizedBox(height: AppSpacing.sm),
                         Text(
                           currency.format(report.totalSavings),
                           style: const TextStyle(
                             color: AppColors.primary,
                             fontSize: 48,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                         const SizedBox(height: AppSpacing.sm),
                         Text(
                           'That\'s ${report.percentageSaved.toStringAsFixed(0)}% off your total shop!',
                           style: const TextStyle(
                             color: AppColors.textSecondary,
                             fontSize: 14,
                             fontWeight: FontWeight.w500,
                           ),
                         ),
                       ],
                     ),
                   ),
                   
                   const SizedBox(height: AppSpacing.xl),
                   
                   const Text(
                     'Breakdown',
                     style: TextStyle(
                       color: Colors.white,
                       fontSize: 18,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   
                   const SizedBox(height: AppSpacing.md),
                   
                   // List Items
                   ListView.separated(
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     itemCount: report.substitutions.length,
                     separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                     itemBuilder: (context, index) {
                       final item = report.substitutions[index];
                       return _buildComparisonCard(context, item, currency);
                     },
                   ),
                   
                   // Padding for button
                   const SizedBox(height: 100),
                 ],
              ),
            ),
          ),
          
          // Sticky Bottom Button
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // In a real app, this might show more details
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Full Detailed Report Downloaded!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF0F52BA), // Sapphire
                ),
                child: const Text('See Full Report >'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(BuildContext context, ComparisonItem item, NumberFormat currency) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.original.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        currency.format(item.original.price),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.textTertiary),
                      const SizedBox(width: 8),
                      Text(
                        currency.format(item.alternative.price),
                        style: const TextStyle(
                          color: AppColors.textPrimary, // Or green?
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Tags
          Wrap(
            spacing: 8,
            children: item.tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF334155), // Dark Slate
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10, 
                  fontWeight: FontWeight.w600
                ),
              ),
            )).toList(),
          ),
          
          if (item.reason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                item.reason,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
