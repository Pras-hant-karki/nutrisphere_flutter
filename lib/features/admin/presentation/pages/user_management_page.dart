import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/core/services/storage/user_session_service.dart';
import 'package:nutrisphere_flutter/core/utils/snackbar_utils.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/member_model.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/providers/members_provider.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() =>
      _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  String _adminName = '';
  bool _deleteMode = false;

  @override
  void initState() {
    super.initState();
    _loadAdminName();
  }

  Future<void> _loadAdminName() async {
    final session =
        await ref.read(userSessionServiceProvider).getSession();
    if (session != null && mounted) {
      setState(() => _adminName = session.fullName);
    }
  }

  void _toggleDeleteMode() {
    setState(() => _deleteMode = !_deleteMode);
  }

  void _showMemberDetail(MemberModel member) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Member Detail',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _MemberDetailOverlay(member: member);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  void _confirmDelete(MemberModel member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 26),
            SizedBox(width: 10),
            Text('Delete Member',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${member.fullName}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No',
                style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(membersProvider.notifier)
                  .deleteMember(member.id);
              if (mounted) {
                if (success) {
                  SnackbarUtils.showSuccess(
                      context, '${member.fullName} has been removed');
                } else {
                  SnackbarUtils.showError(
                      context, 'Failed to delete member');
                }
              }
            },
            child: const Text('Yes',
                style: TextStyle(color: AppColors.error, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final membersState = ref.watch(membersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cardBackground,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.textPrimary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Admin avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryDark,
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        _adminName.isNotEmpty
                            ? _adminName[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Greeting
                  Expanded(
                    child: Text(
                      'Hi $_adminName !',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Notification bell
                  Stack(
                    children: [
                      const Icon(Icons.notifications_none,
                          color: AppColors.textPrimary, size: 26),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── "Members" Title ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Members',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ─── Member List ───
            Expanded(
              child: membersState.when(
                loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 48),
                      const SizedBox(height: 12),
                      Text('Failed to load members',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            ref.read(membersProvider.notifier).loadMembers(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (members) {
                  if (members.isEmpty) {
                    return Center(
                      child: Text('No members found.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textMuted)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 4),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return _buildMemberCard(member);
                    },
                  );
                },
              ),
            ),

            // ─── Delete Member Button ───
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: GestureDetector(
                onTap: _toggleDeleteMode,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _deleteMode ? AppColors.gold : AppColors.error,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _deleteMode ? 'Cancel' : 'Delete Member',
                    style: TextStyle(
                      color: _deleteMode ? AppColors.gold : AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(MemberModel member) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _deleteMode ? null : () => _showMemberDetail(member),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Member info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'more details',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),

              // Delete bin icon (visible only in delete mode)
              if (_deleteMode)
                GestureDetector(
                  onTap: () => _confirmDelete(member),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: AppColors.error, size: 22),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Blurred overlay popup showing member details
// ─────────────────────────────────────────────────────────────
class _MemberDetailOverlay extends StatelessWidget {
  final MemberModel member;

  const _MemberDetailOverlay({required this.member});

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = member.displayImage;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final fullImageUrl = hasImage
        ? (imageUrl.startsWith('http')
            ? imageUrl
            : '${ApiEndpoints.baseUrl}$imageUrl')
        : null;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blurred background – dismiss on tap
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),

          // Centered card
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row: name + subtitle
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.fullName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'more details',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Profile image
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.secondaryDark,
                      backgroundImage: hasImage
                          ? NetworkImage(fullImageUrl!)
                          : null,
                      child: !hasImage
                          ? Text(
                              _getInitials(member.fullName),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(height: 24),

                    // Detail fields
                    _detailField(context, 'Name:', member.fullName),
                    const SizedBox(height: 10),
                    _detailField(context, 'Email:', member.email),
                    const SizedBox(height: 10),
                    _detailField(
                        context, 'Ph no:', member.phone ?? 'Not provided'),
                    const SizedBox(height: 10),
                    _detailField(context, 'Role:', member.role),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailField(BuildContext context, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: RichText(
        text: TextSpan(
          text: '$label  ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
          children: [
            TextSpan(
              text: value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}