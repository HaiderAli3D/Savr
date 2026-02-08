import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../data/models.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile & Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              
              // Profile section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guest User',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap to sign in',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Shopping Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              // Preferences section
              const _PreferencesSection(),
              
              const SizedBox(height: 24),
              
              const Text(
                'App Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              // App settings
              _buildSettingItem(context, Icons.notifications, 'Notifications', 'Manage your notifications'),
              _buildSettingItem(context, Icons.dark_mode, 'Dark Mode', 'Toggle app appearance'),
              _buildSettingItem(context, Icons.info, 'About', 'App version and info'),
              _buildSettingItem(context, Icons.help, 'Help & Support', 'Get help and send feedback'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Handle tap
        },
      ),
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final preferences = appState.preferences;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildPreferenceToggle(context, 'Vegetarian', preferences.vegetarian, (value) {
            appState.updatePreferences(preferences.copyWith(vegetarian: value));
          }),
          _buildDivider(context),
          _buildPreferenceToggle(context, 'Vegan', preferences.vegan, (value) {
            appState.updatePreferences(preferences.copyWith(vegan: value));
          }),
          _buildDivider(context),
          _buildPreferenceToggle(context, 'Gluten Free', preferences.glutenFree, (value) {
            appState.updatePreferences(preferences.copyWith(glutenFree: value));
          }),
          _buildDivider(context),
          _buildPreferenceToggle(context, 'Organic Only', preferences.organicOnly, (value) {
            appState.updatePreferences(preferences.copyWith(organicOnly: value));
          }),
          _buildDivider(context),
          _buildPreferenceToggle(context, 'Sulfate Free', preferences.sulfateFree, (value) {
            appState.updatePreferences(preferences.copyWith(sulfateFree: value));
          }),
          _buildDivider(context),
          _buildPreferenceToggle(context, 'No Brand Swaps', preferences.noBrandSwaps, (value) {
            appState.updatePreferences(preferences.copyWith(noBrandSwaps: value));
          }),
        ],
      ),
    );
  }

  Widget _buildPreferenceToggle(BuildContext context, String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.5),
      indent: 16,
      endIndent: 16,
    );
  }
}