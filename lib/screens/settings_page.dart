import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/page_shell.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      title: 'Profile',
      child: Column(
        children: [
          // Hero profile card
          AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: 1.0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 24,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Savr User',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Premium Member',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Demo toggle card
          AnimatedOpacity(
            duration: const Duration(milliseconds: 450),
            opacity: 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Mode',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Try with sample data',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: false,
                    onChanged: (value) {
                      // Handle demo mode toggle
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Menu items
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.person,
                  label: 'Account',
                  description: 'Manage your profile',
                  delay: 500,
                  isFirst: true,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.notifications,
                  label: 'Notifications',
                  description: 'Alerts & reminders',
                  delay: 550,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.shield,
                  label: 'Privacy',
                  description: 'Data & permissions',
                  delay: 600,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  description: 'FAQs & contact',
                  delay: 650,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required int delay,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: delay),
      opacity: 1.0,
      child: InkWell(
        onTap: () {
          // Handle menu item tap
        },
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(AppRadius.lg) : Radius.zero,
          bottom: isLast ? const Radius.circular(AppRadius.lg) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: isLast
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.mutedForeground.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
