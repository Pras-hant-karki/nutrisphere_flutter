import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/core/services/storage/user_session_service.dart';
import 'package:nutrisphere_flutter/core/utils/snackbar_utils.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/plan_request_model.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/providers/plan_requests_provider.dart';

class ViewRequestPage extends ConsumerStatefulWidget {
  const ViewRequestPage({super.key});

  @override
  ConsumerState<ViewRequestPage> createState() => _ViewRequestPageState();
}

class _ViewRequestPageState extends ConsumerState<ViewRequestPage> {
  String _adminName = '';

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

  // ─── Show Detail Popup ───
  void _showRequestDetail(PlanRequestModel request) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Request Detail',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _RequestDetailOverlay(request: request);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  // ─── Upload Plan Dialog ───
  void _showUploadDialog(PlanRequestModel request) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Upload Plan',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _UploadPlanOverlay(
          request: request,
          onFileUpload: (filePath) async {
            Navigator.pop(context);
            final success = await ref
                .read(planRequestsProvider.notifier)
                .approveWithFile(request.id, filePath);
            if (mounted) {
              if (success) {
                SnackbarUtils.showSuccess(
                    context, 'Plan sent to ${request.displayName}');
              } else {
                SnackbarUtils.showError(context, 'Failed to upload plan');
              }
            }
          },
          onLinkSubmit: (link) async {
            Navigator.pop(context);
            final success = await ref
                .read(planRequestsProvider.notifier)
                .approveWithLink(request.id, link);
            if (mounted) {
              if (success) {
                SnackbarUtils.showSuccess(
                    context, 'Plan link sent to ${request.displayName}');
              } else {
                SnackbarUtils.showError(context, 'Failed to send link');
              }
            }
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  // ─── Reject Request Dialog ───
  void _showRejectDialog(PlanRequestModel request) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Reject Request',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _RejectRequestOverlay(
          request: request,
          onReject: (reason) async {
            Navigator.pop(context);
            final success = await ref
                .read(planRequestsProvider.notifier)
                .rejectRequest(request.id, reason);
            if (mounted) {
              if (success) {
                SnackbarUtils.showSuccess(context,
                    'Request from ${request.displayName} rejected');
              } else {
                SnackbarUtils.showError(
                    context, 'Failed to reject request');
              }
            }
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsState = ref.watch(planRequestsProvider);

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

            // ─── "Requests" Title ───
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
                    'Requests',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ─── Request List ───
            Expanded(
              child: requestsState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary),
                ),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 48),
                      const SizedBox(height: 12),
                      Text('Failed to load requests',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => ref
                            .read(planRequestsProvider.notifier)
                            .loadRequests(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (requests) {
                  if (requests.isEmpty) {
                    return Center(
                      child: Text('No pending requests.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textMuted)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 4),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return _buildRequestCard(request);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(PlanRequestModel request) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRequestDetail(request),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              // Request info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.displayName,
                      style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'more details',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                    ),
                  ],
                ),
              ),

              // Upload button
              GestureDetector(
                onTap: () => _showUploadDialog(request),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.upload_rounded,
                      color: AppColors.primary, size: 22),
                ),
              ),
              const SizedBox(width: 8),

              // Delete/Reject button
              GestureDetector(
                onTap: () => _showRejectDialog(request),
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
//  Request Detail Overlay (popup card showing user-filled details)
// ─────────────────────────────────────────────────────────────
class _RequestDetailOverlay extends StatelessWidget {
  final PlanRequestModel request;

  const _RequestDetailOverlay({required this.request});

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = request.displayImage;
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
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),

          // Centered scrollable card
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Profile image
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.secondaryDark,
                          backgroundImage: hasImage
                              ? NetworkImage(fullImageUrl!)
                              : null,
                          child: !hasImage
                              ? Text(
                                  _getInitials(request.displayName),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),

                        const SizedBox(height: 16),

                        // Name
                        Text(
                          request.displayName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),

                        const SizedBox(height: 20),

                        // Detail fields
                        _detailField(context, 'Height, Weight, Job:',
                            '${request.height}, ${request.weight}, ${request.job}'),
                        const SizedBox(height: 10),
                        _detailField(context, 'Any Medical Condition:',
                            request.medicalCondition),
                        const SizedBox(height: 10),
                        _detailField(
                            context, 'Diet type:', request.dietType),
                        const SizedBox(height: 10),
                        _detailField(context, 'Training type:',
                            request.trainingType),
                        const SizedBox(height: 10),
                        _detailField(
                            context, 'Your Goal ?', request.goal),
                        const SizedBox(height: 10),
                        _detailField(
                            context,
                            'Any Special request ?',
                            request.specialRequest.isNotEmpty
                                ? request.specialRequest
                                : 'None'),
                        if (request.foodAllergy.isNotEmpty &&
                            request.foodAllergy != 'None') ...[
                          const SizedBox(height: 10),
                          _detailField(context, 'Food Allergy:',
                              request.foodAllergy),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailField(
      BuildContext context, String label, String value) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Text(
        '$label $value',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Upload Plan Overlay (admin uploads file or provides link)
// ─────────────────────────────────────────────────────────────
class _UploadPlanOverlay extends StatefulWidget {
  final PlanRequestModel request;
  final Future<void> Function(String filePath) onFileUpload;
  final Future<void> Function(String link) onLinkSubmit;

  const _UploadPlanOverlay({
    required this.request,
    required this.onFileUpload,
    required this.onLinkSubmit,
  });

  @override
  State<_UploadPlanOverlay> createState() => _UploadPlanOverlayState();
}

class _UploadPlanOverlayState extends State<_UploadPlanOverlay> {
  String? _selectedFileName;
  String? _selectedFilePath;
  final TextEditingController _linkController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'jpg',
        'jpeg',
        'png'
      ],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFilePath = result.files.single.path;
      });
    }
  }

  Future<void> _send() async {
    if (_isLoading) return;

    if (_selectedFilePath != null) {
      setState(() => _isLoading = true);
      await widget.onFileUpload(_selectedFilePath!);
    } else if (_linkController.text.trim().isNotEmpty) {
      setState(() => _isLoading = true);
      await widget.onLinkSubmit(_linkController.text.trim());
    } else {
      SnackbarUtils.showWarning(
          context, 'Please upload a file or enter a link');
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateFormat('h:mm a').format(DateTime.now());

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blurred background
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),

          // Centered card
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.border, width: 1),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      '"Provide the personalized plan to the user according to details"',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    const Text(
                      'Upload files or link of plan for the user to access.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Upload area
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.border, width: 1),
                      ),
                      child: _selectedFileName != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                        Icons.insert_drive_file,
                                        color: AppColors.primary,
                                        size: 40),
                                    const SizedBox(height: 8),
                                    Text(
                                      _selectedFileName!,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Stack(
                              children: [
                                // Link input at bottom
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  right: 12,
                                  child: TextField(
                                    controller: _linkController,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Paste link here...',
                                      hintStyle: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 13,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.background,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),

                                // Upload & Link icons at top-right
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: _pickFile,
                                        child: Container(
                                          padding:
                                              const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                          ),
                                          child: const Icon(
                                            Icons.upload_file,
                                            color:
                                                AppColors.textPrimary,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding:
                                            const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius:
                                              BorderRadius.circular(
                                                  8),
                                        ),
                                        child: const Icon(
                                          Icons.link,
                                          color:
                                              AppColors.textPrimary,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Bottom row: Send button + time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Send button
                        GestureDetector(
                          onTap: _isLoading ? null : _send,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: _isLoading
                                  ? AppColors.textMuted
                                  : AppColors.success,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Send',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),

                        // Time
                        Text(
                          now,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Reject Request Overlay (admin enters reason and confirms)
// ─────────────────────────────────────────────────────────────
class _RejectRequestOverlay extends StatefulWidget {
  final PlanRequestModel request;
  final Future<void> Function(String reason) onReject;

  const _RejectRequestOverlay({
    required this.request,
    required this.onReject,
  });

  @override
  State<_RejectRequestOverlay> createState() =>
      _RejectRequestOverlayState();
}

class _RejectRequestOverlayState extends State<_RejectRequestOverlay> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  Future<void> _reject() async {
    if (_isLoading) return;

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      SnackbarUtils.showWarning(
          context, 'Please provide a reason for rejection');
      return;
    }

    setState(() => _isLoading = true);
    await widget.onReject(reason);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateFormat('h:mm a').format(DateTime.now());

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blurred background
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),

          // Centered card
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.border, width: 1),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title in red
                    const Text(
                      '"Are you sure you want to Reject this request ?"',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    const Text(
                      'Please describe a reason for rejecting the request:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reason text area
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2196F3),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: _reasonController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Write your reason here...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          contentPadding: EdgeInsets.all(14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bottom row: Reject button + time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Reject button
                        GestureDetector(
                          onTap: _isLoading ? null : _reject,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: _isLoading
                                  ? AppColors.textMuted
                                  : AppColors.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Reject',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),

                        // Time
                        Text(
                          now,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}