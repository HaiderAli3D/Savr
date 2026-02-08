import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/bottom_nav_bar.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  // We'll manage local state for the form, then commit to AppState on "Next"
  // Actually, binding directly to AppState is fine since we are in a flow.
  
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final prefs = appState.preferences;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Filter Your Preferences'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Preferences Card
            _buildSection(
              context,
              title: 'Your Preferences',
              children: [
                _buildSwitch(
                  'Sulfate-Free',
                  prefs.sulfateFree,
                  (val) => appState.updatePreferences(prefs.copyWith(sulfateFree: val)),
                ),
                _buildDivider(),
                _buildSwitch(
                  'Organic Only',
                  prefs.organicOnly,
                  (val) => appState.updatePreferences(prefs.copyWith(organicOnly: val)),
                ),
                _buildDivider(),
                _buildSwitch(
                  'No Brand Swaps',
                  prefs.noBrandSwaps,
                  (val) => appState.updatePreferences(prefs.copyWith(noBrandSwaps: val)),
                ),
                 _buildDivider(),
                _buildSwitch(
                  'Vegetarian Products',
                  prefs.vegetarian,
                  (val) => appState.updatePreferences(prefs.copyWith(vegetarian: val)),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Budget Focus Card
            _buildSection(
              context,
              title: 'Budget Focus',
              children: [
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _buildChip(context, 'Lowest Price', prefs.budgetFocus, (val) => appState.updatePreferences(prefs.copyWith(budgetFocus: val))),
                    const SizedBox(width: 8),
                    _buildChip(context, 'Balanced', prefs.budgetFocus, (val) => appState.updatePreferences(prefs.copyWith(budgetFocus: val))),
                    const SizedBox(width: 8),
                    _buildChip(context, 'Best Quality', prefs.budgetFocus, (val) => appState.updatePreferences(prefs.copyWith(budgetFocus: val))),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: appState.isAnalyzing 
                  ? null 
                  : () async {
                      // Trigger analysis
                      await appState.analyzeReceipt();
                      if (context.mounted && appState.report != null) {
                         context.push('/summary');
                      }
                    },
                style: ElevatedButton.styleFrom(
                  // The background is dark. Let's make the button distinct. 
                  // The design shows a dark blue button on a dark background? No, actually usually light button on dark, or dark button on light. 
                  // Let's use the secondary color (Teal) or a dedicated "action" color?
                  // Design Reference: Button is "See Full Report" (Blue) on White.
                  // Here on dark bg, let's use White/Light Blue.
                  backgroundColor: const Color(0xFF334155),
                  foregroundColor: Colors.white,
                ),
                child: appState.isAnalyzing
                  ? const SizedBox(
                      height: 20, width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text('Show Suggestions >'),
              ),
            ),
             if (appState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Error: ${appState.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.secondary,
        ),
      ],
    );
  }
  
  Widget _buildDivider() {
    return Divider(height: 24, thickness: 1, color: Colors.grey.withValues(alpha: 0.1));
  }

  Widget _buildChip(BuildContext context, String label, String groupValue, Function(String) onSelect) {
    final isSelected = label == groupValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F52BA) : const Color(0xFFF1F5F9), // Sapphire Blue for active
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
