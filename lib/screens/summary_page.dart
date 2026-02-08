import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../data/models.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/animated_counter.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  String? _expandedItemId;
  final Map<String, List<String>> _itemFilters = {};

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final report = appState.report;

    if (report == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppColors.mutedForeground,
              ),
              const SizedBox(height: 16),
              Text(
                'No report data',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar(),
      );
    }

    final currency = NumberFormat.simpleCurrency(name: 'GBP');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Savings Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Savings Card
            _buildHeroCard(report, currency),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Breakdown header
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: AppColors.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'YOU COULD SAVE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // List Items
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: report.substitutions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = report.substitutions[index];
                return _buildComparisonCard(context, item, currency);
              },
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildHeroCard(SavingsReport report, NumberFormat currency) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 28,
          horizontal: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: AppColors.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'YOU COULD SAVE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedCounter(
              value: report.totalSavings,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 40,
                  ),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '${report.percentageSaved.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' of your basket'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(BuildContext context, ComparisonItem item, NumberFormat currency) {
    final isExpanded = _expandedItemId == item.original.name;
    final activeFilters = _itemFilters[item.original.name] ?? [];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: () {
                setState(() {
                  _expandedItemId = isExpanded ? null : item.original.name;
                });
              },
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    // Item info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.original.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 14,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                currency.format(item.original.price),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                              ),
                              if (activeFilters.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${activeFilters.length} pref${activeFilters.length > 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Savings badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Save ${currency.format((item.original.price - item.alternative.price))}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Expand icon
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.mutedForeground,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Expanded content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedContent(item, currency, activeFilters),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(
    ComparisonItem item,
    NumberFormat currency,
    List<String> activeFilters,
  ) {
    return Column(
      children: [
        const Divider(height: 1, color: AppColors.border),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alternative product
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BEST ALTERNATIVE',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textTertiary,
                                  fontSize: 9,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.alternative.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 13,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currency.format(item.alternative.price),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 16,
                                  color: AppColors.accent,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tags
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: item.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )).toList(),
                ),
              ],
              
              // Reason
              if (item.reason.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  item.reason,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
