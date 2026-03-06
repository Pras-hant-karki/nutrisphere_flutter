import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrisphere_flutter/features/dashboard/presentation/pages/help_center_page.dart';
import 'package:nutrisphere_flutter/features/dashboard/presentation/pages/privacy_policy_page.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'package:nutrisphere_flutter/core/widgets/custom_app_bar.dart';
import 'package:nutrisphere_flutter/core/widgets/logout_dialog.dart';
import 'package:nutrisphere_flutter/app/theme/theme_provider.dart';
import '../../../../core/services/notification_service.dart'; 
import 'package:nutrisphere_flutter/features/dashboard/presentation/pages/terms_of_service_page.dart';
import 'package:nutrisphere_flutter/features/auth/domain/usecases/logout_usecase.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  bool _notificationsEnabled = true;
  bool _emailUpdates = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _emailUpdates = prefs.getBool('emailUpdates') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = (screenSize.width * 0.05).toDouble(); // 5% of width
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        subtitle: "Manage Preferences",
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Account'),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Update personal info',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Edit Profile coming soon'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              subtitle: 'Manage privacy',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Privacy coming soon'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update password',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Change Password coming soon'),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            const SizedBox(height: AppSpacing.sm),
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive notifications',
              value: _notificationsEnabled,
              onChanged: (value) async {
                setState(() {
                  _notificationsEnabled = value;
                });
                await ref.read(notificationServiceProvider).setNotificationsEnabled(value);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                          ? 'Notifications enabled'
                          : 'Notifications disabled'
                      ),
                      backgroundColor: value ? Colors.green : Colors.orange,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSwitchTile(
              icon: Icons.email_outlined,
              title: 'Email Updates',
              subtitle: 'Receive email updates',
              value: _emailUpdates,
              onChanged: (value) async {
                setState(() {
                  _emailUpdates = value;
                });
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('emailUpdates', value);
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.notifications_active_outlined,
              title: 'Test Notification',
              subtitle: 'Test notification subtitle',
              onTap: () {
                ref.read(notificationServiceProvider).showTestNotification(context);
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Support Section
            _buildSectionHeader('Support'),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'Get help',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpCenterScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version',
              onTap: () {
                _showAboutDialog();
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.rate_review_outlined,
              title: 'Rate App',
              subtitle: 'Share your feeling',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Thank you!'),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Legal Section
            _buildSectionHeader('Legal'),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'View privacy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildSettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'View terms',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsOfServiceScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  'Logout',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.body.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        secondary: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'NutriSphere',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.restaurant_menu,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text('Your personal nutrition and fitness companion.'),
      ],
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LogoutDialog(
        onConfirm: () async {
          await ref.read(logoutUseCaseProvider).call();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (_) => false,
            );
          }
        },
      ),
    );
  }
}