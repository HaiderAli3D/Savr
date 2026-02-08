import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../data/models.dart';
import '../widgets/animated_counter.dart';
import '../widgets/page_shell.dart';
import '../widgets/store_comparison_card.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final report = appState.report;

    if (report == null) {
      return PageShell(
        title: '',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No results yet',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Scan a receipt to find savings',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Go to Scan'),
              ),
            ],
          ),
        ),
      );
    }

    final totalSpent = report.substitutions.fold<double>(
      0,
      (sum, item) => sum + item.original.price,
    );
    final savingsPercent = totalSpent > 0
        ? ((report.totalSavings / totalSpent) * 100).round()
        : 0;

    return PageShell(
      title: '',
      child: Column(
        children: [
          // Hero Savings Card
          _buildHeroCard(context, report.totalSavings, savingsPercent, totalSpent),

          const SizedBox(height: 20),

          // Product Cards
          ...report.substitutions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ExpandableProductCard(
                item: entry.value,
                index: entry.key,
              ),
            );
          }),

          const SizedBox(height: 20),

          // Store Comparison Card
          StoreComparisonCard(
            bestStore: 'Aldi',
            extraSavings: 8.50,
            extraPercent: 25,
            loading: false,
            onCompare: () {
              // Navigate to comparison page when created
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    double totalSavings,
    int savingsPercent,
    double totalSpent,
  ) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: 1.0,
      child: Container(
        padding: const EdgeInsets.all(28),
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
                  Icons.auto_awesome,
                  size: 14,
                  color: AppColors.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  'YOU COULD SAVE',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedCounter(
              value: totalSavings,
              prefix: '£',
              decimals: 2,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: '$savingsPercent%',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' of your £${totalSpent.toStringAsFixed(2)} basket',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableProductCard extends StatefulWidget {
  final ComparisonItem item;
  final int index;

  const _ExpandableProductCard({
    required this.item,
    required this.index,
  });

  @override
  State<_ExpandableProductCard> createState() => _ExpandableProductCardState();
}

class _ExpandableProductCardState extends State<_ExpandableProductCard> {
  bool _isExpanded = false;
  final List<String> _selectedPrefs = [];

  @override
  Widget build(BuildContext context) {
    final bestAlt = widget.item.alternative;
    final savingsPercent = ((bestAlt.price - widget.item.original.price).abs() / 
                            widget.item.original.price * 100).round();

    return AnimatedOpacity(
      duration: Duration(milliseconds: 400 + (widget.index * 40)),
      opacity: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Main row
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.original.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '£${widget.item.original.price.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.savingsBadgeBg,
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Text(
                                  'Save £${(widget.item.original.price - bestAlt.price).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.savingsBadgeText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune, size: 14),
                      onPressed: () {
                        // Show preferences
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.muted,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: _isExpanded ? 0.5 : 0,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expandable alternatives section
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: _isExpanded
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildAlternativeCard(
                              context,
                              bestAlt.name,
                              bestAlt.price,
                              widget.item.original.price - bestAlt.price,
                              true,
                              bestAlt.category,
                            ),
                            // Add more alternatives here if available
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativeCard(
    BuildContext context,
    String name,
    double price,
    double savings,
    bool isCheapest,
    String category,
  ) {
    return Container(
      width: 144,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCheapest ? AppColors.primary.withOpacity(0.1) : AppColors.muted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isCheapest
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedForeground,
              letterSpacing: 1.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '£${price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.savingsBadgeBg,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              'Save £${savings.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.savingsBadgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
