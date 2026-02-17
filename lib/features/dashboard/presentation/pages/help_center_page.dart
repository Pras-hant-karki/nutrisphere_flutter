import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'package:nutrisphere_flutter/core/widgets/custom_app_bar.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = (screenSize.width * 0.05).toDouble();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Help Center',
        subtitle: 'Get Help',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search help...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // FAQ Section
            _buildSectionHeader(context, 'Frequently Asked Questions'),
            const SizedBox(height: AppSpacing.md),

            _buildFAQItem(
              context,
              question: 'How to track my nutrition?',
              answer: 'Use the nutrition tracker to log your meals and monitor your intake.',
            ),
            _buildFAQItem(
              context,
              question: 'How to set fitness goals?',
              answer: 'Go to the profile section to set your fitness and nutrition goals.',
            ),
            _buildFAQItem(
              context,
              question: 'How to view progress?',
              answer: 'Check the dashboard for your progress charts and statistics.',
            ),
            _buildFAQItem(
              context,
              question: 'How to contact support?',
              answer: 'Use the contact options below to reach our support team.',
            ),
            _buildFAQItem(
              context,
              question: 'How to update profile?',
              answer: 'Go to settings and select Edit Profile.',
            ),

            const SizedBox(height: AppSpacing.xl),

            // Contact Support Section
            _buildSectionHeader(context, 'Contact Support'),
            const SizedBox(height: AppSpacing.md),

            _buildContactOption(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Live Chat',
              subtitle: 'Chat with support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Live chat coming soon')),
                );
              },
            ),

            _buildContactOption(
              context,
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'Send email',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Email support coming soon')),
                );
              },
            ),

            _buildContactOption(
              context,
              icon: Icons.phone_outlined,
              title: 'Call Support',
              subtitle: 'Speak with agent',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Call support coming soon')),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.body.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, {required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              answer,
              style: AppTextStyles.caption?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}