import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  const Text('Frequently Asked Questions', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  _buildFaqItem(
                    'How does trip tracking work?',
                    'We use your device\'s GPS to periodically log your location and calculate speed and distance.',
                  ),
                  _buildFaqItem(
                    'Why is GPS inaccurate?',
                    'GPS accuracy can be affected by tall buildings, weather, or being indoors.',
                  ),
                  _buildFaqItem(
                    'Why does tracking stop when the screen is locked?',
                    'Your device may be aggressively killing background apps. Make sure battery optimization is disabled for KSKT Rider.',
                  ),
                  _buildFaqItem(
                    'What happens when I am offline?',
                    'Your trip data is stored locally and will synchronize once you reconnect to the internet.',
                  ),
                  _buildFaqItem(
                    'How do I enable background tracking?',
                    'Go to your device settings, find KSKT Rider, and ensure Location is set to "Allow all the time".',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                text: 'Contact Support',
                onPressed: () {
                  // Placeholder for contact support
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ExpansionTile(
        title: Text(question, style: AppTextStyles.titleMedium),
        childrenPadding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, bottom: AppSpacing.md),
        children: [
          Text(answer, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.greyText)),
        ],
      ),
    );
  }
}
