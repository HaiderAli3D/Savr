import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/rounded_card.dart';
import '../widgets/segmented_control.dart';
import '../widgets/primary_button.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final prefs = appState.preferences;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'PREFERENCES',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Banner
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Customize your shopping suggestions',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Dietary Preferences Section
                  _buildSectionHeader(
                    context,
                    icon: Icons.eco_outlined,
                    title: 'Dietary Preferences',
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildPreferenceCard(
                    context,
                    children: [
                      _buildSwitch(
                        context,
                        icon: Icons.water_drop_outlined,
                        label: 'Sulfate-Free',
                        subtitle: 'Exclude products with sulfates',
                        value: prefs.sulfateFree,
                        onChanged: (val) => appState.updatePreferences(
                          prefs.copyWith(sulfateFree: val),
                        ),
                      ),
                      _buildDivider(),
                      _buildSwitch(
                        context,
                        icon: Icons.grass_outlined,
                        label: 'Organic Only',
                        subtitle: 'Show only certified organic products',
                        value: prefs.organicOnly,
                        onChanged: (val) => appState.updatePreferences(
                          prefs.copyWith(organicOnly: val),
                        ),
                      ),
                      _buildDivider(),
                      _buildSwitch(
                        context,
                        icon: Icons.restaurant_outlined,
                        label: 'Vegetarian',
                        subtitle: 'Include only vegetarian products',
                        value: prefs.vegetarian,
                        onChanged: (val) => appState.updatePreferences(
                          prefs.copyWith(vegetarian: val),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Shopping Preferences Section
                  _buildSectionHeader(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Shopping Preferences',
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildPreferenceCard(
                    context,
                    children: [
                      _buildSwitch(
                        context,
                        icon: Icons.loyalty_outlined,
                        label: 'No Brand Swaps',
                        subtitle: 'Keep your preferred brands',
                        value: prefs.noBrandSwaps,
                        onChanged: (val) => appState.updatePreferences(
                          prefs.copyWith(noBrandSwaps: val),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Budget Focus Section
                  _buildSectionHeader(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Budget Focus',
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildPreferenceCard(
                    context,
                    children: [
                      SegmentedControl(
                        options: const ['Lowest Price', 'Balanced', 'Best Quality'],
                        selectedOption: prefs.budgetFocus,
                        onChanged: (val) => appState.updatePreferences(
                          prefs.copyWith(budgetFocus: val),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.xxl),
                  
                  // Error Message
                  if (appState.error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              appState.error!,
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Sticky Bottom Button
          Container(
            padding: AppSpacing.page,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: PrimaryButton(
                label: appState.isAnalyzing ? 'Analyzing...' : 'Show Suggestions',
                icon: Icons.auto_awesome,
                isLoading: appState.isAnalyzing,
                fullWidth: true,
                onPressed: appState.isAnalyzing
                    ? null
                    : () async {
                        await appState.analyzeReceipt();
                        if (context.mounted && appState.report != null) {
                          context.push('/summary');
                        }
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _buildPreferenceCard(BuildContext context, {required List<Widget> children}) {
    return RoundedCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitch(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: value
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            size: 20,
            color: value ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.border,
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, String groupValue, Function(String) onSelect) {
    final isSelected = label == groupValue;
    return GestureDetector(
      onTap: () => onSelect(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
