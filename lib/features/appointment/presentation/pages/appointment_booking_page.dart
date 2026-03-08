import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/core/utils/snackbar_utils.dart';
import 'package:nutrisphere_flutter/features/appointment/data/models/appointment_model.dart';
import 'package:nutrisphere_flutter/features/appointment/data/services/appointment_service.dart';

class AppointmentBookingScreen extends ConsumerStatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  ConsumerState<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState
    extends ConsumerState<AppointmentBookingScreen> {
  int trainingType = 1;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<AppointmentModel> _myAppointments = [];
  bool _isLoading = false;

  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _jobController = TextEditingController();
  final _goalController = TextEditingController();
  final _countryController = TextEditingController();
  final _specialRequestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMyAppointments();
  }

  Future<void> _bookAppointment() async {
    // Validate required fields
    if (_heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _goalController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null) {
      SnackbarUtils.showError(
          context, 'Please fill in all required fields');
      return;
    }

    try {
      final service = ref.read(appointmentServiceProvider);
      await service.submitAppointment({
        'height': _heightController.text,
        'weight': _weightController.text,
        'job': _jobController.text,
        'trainingType': trainingType == 1 ? 'Online' : 'In-Person',
        'goal': _goalController.text,
        'preferredDate': DateFormat('M/d/yyyy').format(selectedDate!),
        'preferredTime': selectedTime!.format(context),
        'country': _countryController.text,
        'specialRequest': _specialRequestController.text,
      });

      // Clear form
      _heightController.clear();
      _weightController.clear();
      _jobController.clear();
      _goalController.clear();
      _countryController.clear();
      _specialRequestController.clear();
      setState(() {
        selectedDate = null;
        selectedTime = null;
        trainingType = 1;
      });

      if (mounted) {
        SnackbarUtils.showSuccess(
            context, 'Appointment requested successfully',
            textColor: Colors.black);
      }

      // Reload appointments
      _loadMyAppointments();
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to book appointment');
      }
    }
  }

  Future<void> _loadMyAppointments() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(appointmentServiceProvider);
      final appointments = await service.getMyAppointments();
      if (mounted) {
        setState(() => _myAppointments = appointments);
      }
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      return 'Today on ${DateFormat('h:mm a').format(dateTime)}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday on ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('M/d/yyyy h:mm a').format(dateTime);
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
              _header(context, "PT Appointment"),
              const SizedBox(height: 20),

              _textField("Height", controller: _heightController),
              _rowFields("Weight", "Job"),

              const Text("Training Type"),
              Row(
                children: [
                  Radio(
                    value: 1,
                    groupValue: trainingType,
                    onChanged: (v) =>
                        setState(() => trainingType = v!),
                  ),
                  const Text("Online"),
                  Radio(
                    value: 2,
                    groupValue: trainingType,
                    onChanged: (v) =>
                        setState(() => trainingType = v!),
                  ),
                  const Text("In-Person"),
                ],
              ),

              _textField("Your Goal", controller: _goalController),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  selectedDate == null
                      ? "Preferred date"
                      : DateFormat('M/d/yyyy')
                          .format(selectedDate!),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: _pickDate,
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  selectedTime == null
                      ? "Preferred time"
                      : selectedTime!.format(context),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),

              _textField("Country",
                  controller: _countryController),

              _textField(
                  "Any special request or suggestions ?",
                  controller: _specialRequestController),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _bookAppointment,
                  child: const Text("Book"),
                ),
              ),

              const SizedBox(height: 40),

              // ─── My Appointments Section ───
              Text(
                "My Appointments",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),

              if (_isLoading)
                const Center(
                    child: CircularProgressIndicator())
              else if (_myAppointments.isEmpty)
                Center(
                  child: Text(
                    "No appointments booked yet",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                )
              else
                ..._myAppointments.map(
                    (appt) => _appointmentCard(context, appt)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Widget _header(BuildContext context, String title) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        Text(title,
            style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _textField(String hint,
      {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.textMuted),
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
        Expanded(
            child: _textField(h1,
                controller: h1 == "Weight"
                    ? _weightController
                    : _jobController)),
        const SizedBox(width: 12),
        Expanded(
            child: _textField(h2,
                controller: h2 == "Job"
                    ? _jobController
                    : _weightController)),
      ],
    );
  }

  Widget _appointmentCard(
      BuildContext context, AppointmentModel appointment) {
    String statusText;
    Color statusColor;
    String timestampText;
    String? actionPrefix;

    switch (appointment.status) {
      case 'pending':
        statusText = 'Pending';
        statusColor = Colors.orange;
        timestampText =
            'Sent on: ${_formatTimestamp(appointment.createdAt)}';
        break;
      case 'approved':
        statusText = 'Approved';
        statusColor = Colors.green;
        actionPrefix = 'Approved on: ';
        timestampText =
            appointment.adminResponse?.respondedAt != null
                ? '$actionPrefix${_formatTimestamp(appointment.adminResponse!.respondedAt!)}'
                : 'Approved';
        break;
      case 'rescheduled':
        statusText = 'Rescheduled';
        statusColor = Colors.blue;
        actionPrefix = 'Rescheduled on: ';
        timestampText =
            appointment.adminResponse?.respondedAt != null
                ? '$actionPrefix${_formatTimestamp(appointment.adminResponse!.respondedAt!)}'
                : 'Rescheduled';
        break;
      case 'cancelled':
        statusText = 'Cancelled';
        statusColor = Colors.red;
        actionPrefix = 'Cancelled on: ';
        timestampText =
            appointment.adminResponse?.respondedAt != null
                ? '$actionPrefix${_formatTimestamp(appointment.adminResponse!.respondedAt!)}'
                : 'Cancelled';
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
        border:
            Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PT Appointment',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      statusColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(12),
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
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          // Show preferred date & time
          const SizedBox(height: 4),
          Text(
            'Date: ${appointment.preferredDate}  |  Time: ${appointment.preferredTime}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          // Show admin response message if any
          if (appointment.adminResponse != null &&
              appointment.adminResponse!.message.isNotEmpty &&
              appointment.status != 'approved') ...[
            const SizedBox(height: 8),
            Text(
              'Reason: ${appointment.adminResponse!.message}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: appointment.status ==
                            'cancelled'
                        ? Colors.red
                        : Colors.blue,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _jobController.dispose();
    _goalController.dispose();
    _countryController.dispose();
    _specialRequestController.dispose();
    super.dispose();
  }
}
