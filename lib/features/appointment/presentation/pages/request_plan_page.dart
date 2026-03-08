import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/plan_request_model.dart';
import 'package:nutrisphere_flutter/features/admin/data/services/plan_request_service.dart';
import 'package:nutrisphere_flutter/core/utils/snackbar_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestPlanScreen extends ConsumerStatefulWidget {
  const RequestPlanScreen({super.key});

  @override
  ConsumerState<RequestPlanScreen> createState() => _RequestPlanScreenState();
}

class _RequestPlanScreenState extends ConsumerState<RequestPlanScreen> {
  int dietType = 2; 
  int medical = 1;
  List<PlanRequestModel> _myRequests = [];
  bool _isLoading = false;

  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _jobController = TextEditingController();
  final _allergyController = TextEditingController();
  final _goalController = TextEditingController();
  final _specialRequestController = TextEditingController();
  final _medicalConditionController = TextEditingController();
  final _trainingTypeController = TextEditingController();
  final _dietDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMyRequests();
  }

  Future<void> _sendRequest() async {
    // Validate required fields
    if (_heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _goalController.text.isEmpty) {
      SnackbarUtils.showError(context, 'Please fill in all required fields');
      return;
    }

    try {
      final service = ref.read(planRequestServiceProvider);
      String specialRequest = _specialRequestController.text;
      if (_dietDescriptionController.text.isNotEmpty) {
        specialRequest += (specialRequest.isNotEmpty ? '\n' : '') + 'Diet preferences: ${_dietDescriptionController.text}';
      }
      await service.submitRequest({
        'requestType': 'diet',
        'height': _heightController.text,
        'weight': _weightController.text,
        'job': _jobController.text,
        'foodAllergy': _allergyController.text.isEmpty ? 'None' : _allergyController.text,
        'dietType': dietType == 1 ? 'veg' : 'non-veg',
        'medicalCondition': medical == 1 ? 'No' : _medicalConditionController.text,
        'trainingType': _trainingTypeController.text,
        'goal': _goalController.text,
        'specialRequest': specialRequest,
      });

      // Clear form
      _heightController.clear();
      _weightController.clear();
      _jobController.clear();
      _allergyController.clear();
      _goalController.clear();
      _specialRequestController.clear();
      _medicalConditionController.clear();
      _trainingTypeController.clear();
      _dietDescriptionController.clear();

      SnackbarUtils.showSuccess(context, 'Request sent to Trainer');

      // Reload requests
      _loadMyRequests();
    } catch (e) {
      SnackbarUtils.showError(context, 'Failed to send request');
    }
  }

  Future<void> _loadMyRequests() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(planRequestServiceProvider);
      final requests = await service.getMyRequests();
      if (mounted) {
        setState(() => _myRequests = requests);
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context, "Request Plan"),
              const SizedBox(height: 20),

              _textField("Height", controller: _heightController),
              _rowFields("Weight", "Job"),
              _textField("Any food allergy", controller: _allergyController),

              const SizedBox(height: 10),
              const Text("Diet Type"),
              Row(
                children: [
                  Radio(
                    value: 1,
                    groupValue: dietType,
                    onChanged: (v) => setState(() => dietType = v!),
                  ),
                  const Text("Veg"),
                  Radio(
                    value: 2,
                    groupValue: dietType,
                    onChanged: (v) => setState(() => dietType = v!),
                  ),
                  const Text("Non-Veg"),
                ],
              ),
              _textField("Describe your diet preferences (e.g., I am veg but eat egg and fish, no chicken etc.)", controller: _dietDescriptionController),

              const Text("Any Medical Condition"),
              Row(
                children: [
                  Radio(
                    value: 1,
                    groupValue: medical,
                    onChanged: (v) => setState(() => medical = v!),
                  ),
                  const Text("No"),
                  Radio(
                    value: 2,
                    groupValue: medical,
                    onChanged: (v) => setState(() => medical = v!),
                  ),
                  const Text("Yes"),
                ],
              ),
              if (medical == 2)
                _textField("Describe your medical condition", controller: _medicalConditionController),

              _textField("Your Goal", controller: _goalController),
              _textField("Any special request or suggestions ?", controller: _specialRequestController),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sendRequest,
                  child: const Text("Request"),
                ),
              ),

              const SizedBox(height: 40),

              // My Plans Section
              Text(
                "My Plans",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_myRequests.isEmpty)
                Center(
                  child: Text(
                    "No plans requested yet",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                )
              else
                ..._myRequests.map((request) => _planCard(context, request)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String title) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _textField(String hint, {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _rowFields(String h1, String h2) {
    return Row(
      children: [
        Expanded(child: _textField(h1, controller: h1 == "Weight" ? _weightController : _jobController)),
        const SizedBox(width: 12),
        Expanded(child: _textField(h2, controller: h2 == "Job" ? _jobController : _weightController)),
      ],
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final requestDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (requestDate == today) {
      return 'Today on ${DateFormat('h:mm a').format(dateTime)}';
    } else if (requestDate == yesterday) {
      return 'Yesterday on ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('M/d/yyyy h:mm a').format(dateTime);
    }
  }

  // ─── Show Plan Detail Overlay ───
  void _showPlanDetail(PlanRequestModel request) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Plan Detail',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _PlanDetailOverlay(request: request);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  Widget _planCard(BuildContext context, PlanRequestModel request) {
    String statusText;
    Color statusColor;
    String timestampText;

    switch (request.status) {
      case 'pending':
        statusText = 'Pending';
        statusColor = Colors.orange;
        timestampText = 'Requested on: ${_formatTimestamp(request.createdAt)}';
        break;
      case 'approved':
        statusText = 'Approved';
        statusColor = Colors.green;
        timestampText = request.adminResponse?.respondedAt != null
            ? 'Sent on: ${_formatTimestamp(request.adminResponse!.respondedAt!)}'
            : 'Approved';
        break;
      case 'rejected':
        statusText = 'Rejected';
        statusColor = Colors.red;
        timestampText = request.adminResponse?.respondedAt != null
            ? 'Rejected on: ${_formatTimestamp(request.adminResponse!.respondedAt!)}'
            : 'Rejected';
        break;
      default:
        statusText = 'Unknown';
        statusColor = Colors.grey;
        timestampText = '';
    }

    return InkWell(
      onTap: () => _showPlanDetail(request),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${request.requestType.toUpperCase()} Plan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              timestampText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            // Hint to tap
            const SizedBox(height: 6),
            Text(
              'Tap to view details',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Plan Detail Overlay (user views their request & admin response)
// ─────────────────────────────────────────────────────────────
class _PlanDetailOverlay extends StatelessWidget {
  final PlanRequestModel request;

  const _PlanDetailOverlay({required this.request});

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final requestDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (requestDate == today) {
      return 'Today at ${DateFormat('h:mm a').format(dateTime)}';
    } else if (requestDate == yesterday) {
      return 'Yesterday at ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('M/d/yyyy h:mm a').format(dateTime);
    }
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    // Normalize input so both file paths and raw links can be opened.
    String fullUrl = url.trim();

    // If admin pastes `www.example.com`, assume https.
    if (fullUrl.startsWith('www.')) {
      fullUrl = 'https://$fullUrl';
    }

    // Prepend base URL for relative paths returned by backend uploads.
    if (!fullUrl.startsWith('http://') && !fullUrl.startsWith('https://')) {
      final normalizedPath = fullUrl.startsWith('/') ? fullUrl : '/$fullUrl';
      fullUrl = '${ApiEndpoints.baseUrl}$normalizedPath';
    }

    final uri = Uri.tryParse(fullUrl);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid link: $fullUrl')),
        );
      }
      return;
    }

    try {
      // Try browser/app first, then fallback to platform default launch mode.
      final launchedExternal =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launchedExternal) {
        final launchedDefault = await launchUrl(uri);
        if (!launchedDefault && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open: $fullUrl')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = request.status == 'approved';
    final isRejected = request.status == 'rejected';
    final isPending = request.status == 'pending';

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isApproved) {
      statusColor = Colors.green;
      statusText = 'Approved';
      statusIcon = Icons.check_circle;
    } else if (isRejected) {
      statusColor = Colors.red;
      statusText = 'Rejected';
      statusIcon = Icons.cancel;
    } else {
      statusColor = Colors.orange;
      statusText = 'Pending';
      statusIcon = Icons.hourglass_top;
    }

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

          // Centered scrollable card
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
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
                    border: Border.all(color: AppColors.border, width: 1),
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
                        // Status icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 40),
                        ),

                        const SizedBox(height: 16),

                        // Plan title
                        Text(
                          '${request.requestType.toUpperCase()} Plan',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Requested timestamp
                        Text(
                          'Requested on: ${_formatTimestamp(request.createdAt)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ─── Your Request Details ───
                        _sectionTitle(context, 'Your Request Details'),
                        const SizedBox(height: 10),
                        _detailField(context, 'Height, Weight, Job:',
                            '${request.height}, ${request.weight}, ${request.job}'),
                        const SizedBox(height: 8),
                        _detailField(context, 'Diet type:', request.dietType),
                        const SizedBox(height: 8),
                        _detailField(context, 'Medical Condition:', request.medicalCondition),
                        if (request.trainingType.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _detailField(context, 'Training type:', request.trainingType),
                        ],
                        const SizedBox(height: 8),
                        _detailField(context, 'Goal:', request.goal),
                        if (request.specialRequest.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _detailField(context, 'Special request:', request.specialRequest),
                        ],
                        if (request.foodAllergy.isNotEmpty && request.foodAllergy != 'None') ...[
                          const SizedBox(height: 8),
                          _detailField(context, 'Food Allergy:', request.foodAllergy),
                        ],

                        const SizedBox(height: 24),

                        // ─── Admin Response Section ───
                        if (isPending) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.hourglass_top, color: Colors.orange, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Waiting for Trainer/Admin to review your request...',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (isRejected) ...[
                          _sectionTitle(context, 'Admin Response'),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.cancel, color: Colors.red, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Request Rejected',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (request.rejectionReason != null &&
                                    request.rejectionReason!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    'Reason:',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    request.rejectionReason!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                                if (request.adminResponse?.respondedAt != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    'Rejected on: ${_formatTimestamp(request.adminResponse!.respondedAt!)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],

                        if (isApproved && request.adminResponse != null) ...[
                          _sectionTitle(context, 'Admin Response'),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Plan Provided',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (request.adminResponse!.respondedAt != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sent on: ${_formatTimestamp(request.adminResponse!.respondedAt!)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),

                                // File/Link button
                                GestureDetector(
                                  onTap: () => _openUrl(context, request.adminResponse!.url),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.primary.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          request.adminResponse!.type == 'file'
                                              ? Icons.file_download
                                              : Icons.open_in_new,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          request.adminResponse!.type == 'file'
                                              ? 'Download Plan File'
                                              : 'Open Plan Link',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _sectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
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
      child: Text(
        '$label $value',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
