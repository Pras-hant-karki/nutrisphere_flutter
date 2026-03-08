import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'package:nutrisphere_flutter/core/widgets/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = (screenSize.width * 0.05).toDouble();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Privacy Policy',
        subtitle: 'Learn about our privacy practices',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last Updated
            Text(
              'Last Updated: February 6, 2026',
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Introduction
            _buildSection(
              context,
              title: 'Introduction',
              content: 'This privacy policy explains how NutriSphere collects, uses, and protects your personal information.',
            ),

            // Information We Collect
            _buildSection(
              context,
              title: 'Information We Collect',
              content: 'We collect information you provide directly, such as your name, email, and nutrition data.',
            ),

            // How We Use Information
            _buildSection(
              context,
              title: 'How We Use Information',
              content: 'We use your information to provide personalized nutrition recommendations and improve our services.',
            ),

            // Information Sharing
            _buildSection(
              context,
              title: 'Information Sharing',
              content: 'We do not sell or share your personal information with third parties without your consent.',
            ),

            // Data Security
            _buildSection(
              context,
              title: 'Data Security',
              content: 'We implement appropriate security measures to protect your personal information.',
            ),

            // Your Rights
            _buildSection(
              context,
              title: 'Your Rights',
              content: 'You have the right to access, update, or delete your personal information.',
            ),

            // Contact Us
            _buildSection(
              context,
              title: 'Contact Us',
              content: 'If you have questions about this privacy policy, please contact us at support@nutrisphere.com.',
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          content,
          style: AppTextStyles.body.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}