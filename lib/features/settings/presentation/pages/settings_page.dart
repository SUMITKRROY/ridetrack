import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Text('Tracking', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _buildSettingsTile(
              title: 'Location Permission',
              subtitle: 'Enabled',
              icon: Icons.location_on_outlined,
            ),
            _buildSettingsTile(
              title: 'Background Tracking',
              subtitle: 'Enabled',
              icon: Icons.my_location_outlined,
            ),
            _buildSettingsTile(
              title: 'Battery Optimization',
              subtitle: 'Recommended',
              icon: Icons.battery_charging_full_outlined,
            ),
            
            const SizedBox(height: AppSpacing.xl),
            const Text('Preferences', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _buildSettingsTile(
              title: 'Notifications',
              subtitle: 'On',
              icon: Icons.notifications_outlined,
            ),
            _buildSettingsTile(
              title: 'Units',
              subtitle: 'Metric (km, km/h)',
              icon: Icons.straighten_outlined,
            ),
            
            const SizedBox(height: AppSpacing.xl),
            const Text('About', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _buildSettingsTile(
              title: 'Help & Support',
              icon: Icons.help_outline,
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.help);
              },
            ),
            _buildSettingsTile(
              title: 'Privacy Policy',
              icon: Icons.privacy_tip_outlined,
            ),
            _buildSettingsTile(
              title: 'App Version',
              subtitle: '1.0.0',
              icon: Icons.info_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: subtitle != null ? Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.greyText)) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right, color: AppColors.greyText) : null,
      onTap: onTap,
    );
  }
}
