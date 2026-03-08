import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'package:nutrisphere_flutter/core/widgets/custom_app_bar.dart';


class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = (screenSize.width * 0.05).toDouble();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Terms of Service',
        subtitle: 'Terms and conditions',
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
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Acceptance of Terms
            _buildSection(
              title: 'Acceptance of Terms',
              content: 'By using NutriSphere, you agree to these terms of service.',
            ),

            // Use of Service
            _buildSection(
              title: 'Use of Service',
              content: 'You may use our app for workout tracking and booking appointment with trainer or requesting plans from trainer.',
            ),

            // User Accounts
            _buildSection(
              title: 'User Accounts',
              content: 'You are responsible for maintaining the confidentiality of your account.',
            ),

            // Subscriptions and Payment
            _buildSection(
              title: 'Subscriptions and Payment',
              content: 'Premium features require subscription payment as specified.',
            ),

            // Data Privacy
            _buildSection(
              title: 'Data Privacy',
              content: 'Your workout and request data is stored securely and used only for app functionality.',
            ),

            // Content Ownership
            _buildSection(
              title: 'Content Ownership',
              content: 'All app content is owned by NutriSphere and protected by copyright.',
            ),

            // Intellectual Property
            _buildSection(
              title: 'Intellectual Property',
              content: 'You may not copy or distribute our content without permission.',
            ),

            // Limitation of Liability
            _buildSection(
              title: 'Limitation of Liability',
              content: 'NutriSphere is not liable for any damages from app usage.',
            ),

            // Contact Information
            _buildSection(
              title: 'Contact Information',
              content: 'Contact us at support@nutrisphere.com for any questions.',
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          content,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}