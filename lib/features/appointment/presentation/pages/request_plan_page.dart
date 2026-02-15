import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/plan_request_model.dart';
import 'package:nutrisphere_flutter/features/admin/data/services/plan_request_service.dart';
import 'package:nutrisphere_flutter/core/utils/snackbar_utils.dart';

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
        'specialRequest': _specialRequestController.text,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
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
          if (request.rejectionReason != null && request.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Reason: ${request.rejectionReason}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
            ),
          ],
          if (request.adminResponse != null) ...[
            const SizedBox(height: 8),
            Text(
              request.adminResponse!.type == 'file' ? 'Plan File' : 'Plan Link',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
