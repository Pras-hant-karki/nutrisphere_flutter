import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/core/services/storage/user_session_service.dart';
import 'package:nutrisphere_flutter/core/utils/snackbar_utils.dart';
import 'package:nutrisphere_flutter/features/appointment/data/models/appointment_model.dart';
import 'package:nutrisphere_flutter/features/appointment/presentation/providers/appointment_provider.dart';

class ViewAppointmentPage extends ConsumerStatefulWidget {
  const ViewAppointmentPage({super.key});

  @override
  ConsumerState<ViewAppointmentPage> createState() =>
      _ViewAppointmentPageState();
}

class _ViewAppointmentPageState extends ConsumerState<ViewAppointmentPage> {
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
  void _showAppointmentDetail(AppointmentModel appointment) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Appointment Detail',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _AppointmentDetailOverlay(
          appointment: appointment,
          onApprove: () async {
            Navigator.pop(context);
            final success = await ref
                .read(appointmentsProvider.notifier)
                .approveAppointment(appointment.id);
            if (mounted) {
              if (success) {
                SnackbarUtils.showSuccess(
                    context, 'Appointment accepted successfully',
                    textColor: Colors.black);
              } else {
                SnackbarUtils.showError(
                    context, 'Failed to approve appointment');
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

  // ─── Reschedule Dialog ───
  void _showRescheduleDialog(AppointmentModel appointment) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Reschedule Appointment',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _RescheduleOverlay(
          appointment: appointment,
          onReschedule: (reason, newDate, newTime) async {
            Navigator.pop(context);
            final success = await ref
                .read(appointmentsProvider.notifier)
                .rescheduleAppointment(
                    appointment.id, reason, newDate, newTime);
            if (mounted) {
              if (success) {
                SnackbarUtils.showSuccess(
                    context, 'Rescheduled appointment successfully',
                    textColor: Colors.black);
              } else {
                SnackbarUtils.showError(
                    context, 'Failed to reschedule appointment');
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

  // ─── Cancel Dialog ───
  void _showCancelDialog(AppointmentModel appointment) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cancel Appointment',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _CancelOverlay(
          appointment: appointment,
          onCancel: (reason) async {
            Navigator.pop(context);
            final success = await ref
                .read(appointmentsProvider.notifier)
                .cancelAppointment(appointment.id, reason);
            if (mounted) {
              if (success) {
                SnackbarUtils.showError(
                    context, 'Appointment Cancelled',
                    textColor: Colors.black);
              } else {
                SnackbarUtils.showError(
                    context, 'Failed to cancel appointment');
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
    final appointmentsState = ref.watch(appointmentsProvider);

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
                      border:
                          Border.all(color: AppColors.gold, width: 1.5),
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

            // ─── "Appointments" Title ───
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
                    'Appointments',
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ─── Appointment List ───
            Expanded(
              child: appointmentsState.when(
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
                      Text('Failed to load appointments',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => ref
                            .read(appointmentsProvider.notifier)
                            .loadAppointments(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (appointments) {
                  if (appointments.isEmpty) {
                    return Center(
                      child: Text('No pending appointments.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textMuted)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 4),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return _buildAppointmentCard(appointment);
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

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAppointmentDetail(appointment),
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
              // Appointment info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.displayName,
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

              // Reschedule (pen) button
              GestureDetector(
                onTap: () => _showRescheduleDialog(appointment),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit,
                      color: AppColors.primary, size: 22),
                ),
              ),
              const SizedBox(width: 8),

              // Cancel (bin) button
              GestureDetector(
                onTap: () => _showCancelDialog(appointment),
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
//  Helper: Format Timestamp
// ─────────────────────────────────────────────────────────────
String _formatTimestamp(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (dateOnly == today) {
    return 'Today on ${DateFormat('h:mm a').format(dateTime)}';
  } else if (dateOnly == yesterday) {
    return 'Yesterday on ${DateFormat('h:mm a').format(dateTime)}';
  } else {
    return DateFormat('M/d/yyyy h:mm a').format(dateTime);
  }
}

// ─────────────────────────────────────────────────────────────
//  Appointment Detail Overlay (popup showing user-filled details)
// ─────────────────────────────────────────────────────────────
class _AppointmentDetailOverlay extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onApprove;

  const _AppointmentDetailOverlay({
    required this.appointment,
    required this.onApprove,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = appointment.displayImage;
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
                        // Profile image + approve arrow
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.secondaryDark,
                              backgroundImage: hasImage
                                  ? NetworkImage(fullImageUrl!)
                                  : null,
                              child: !hasImage
                                  ? Text(
                                      _getInitials(
                                          appointment.displayName),
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            // Green arrow (approve) icon
                            Positioned(
                              right: -40,
                              top: 10,
                              child: GestureDetector(
                                onTap: onApprove,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.send,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Name
                        Text(
                          appointment.displayName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),

                        const SizedBox(height: 8),

                        // Sent timestamp
                        Text(
                          'Sent on: ${_formatTimestamp(appointment.createdAt)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),

                        const SizedBox(height: 20),

                        // Detail fields from user form
                        _detailField(context, 'Height, Weight, Job:',
                            '${appointment.height}, ${appointment.weight}, ${appointment.job}'),
                        const SizedBox(height: 10),
                        _detailField(context, 'Training type:',
                            appointment.trainingType),
                        const SizedBox(height: 10),
                        _detailField(context, 'Your Goal ?',
                            appointment.goal),
                        const SizedBox(height: 10),
                        _detailField(context, 'Preferred date:',
                            appointment.preferredDate),
                        const SizedBox(height: 10),
                        _detailField(context, 'Preferred time:',
                            appointment.preferredTime),
                        const SizedBox(height: 10),
                        _detailField(context, 'Country:',
                            appointment.country.isNotEmpty
                                ? appointment.country
                                : 'Not specified'),
                        if (appointment.specialRequest.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _detailField(
                              context,
                              'Any Special request ?',
                              appointment.specialRequest),
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
//  Reschedule Overlay (admin picks new date/time + reason)
// ─────────────────────────────────────────────────────────────
class _RescheduleOverlay extends StatefulWidget {
  final AppointmentModel appointment;
  final Future<void> Function(
      String reason, String newDate, String newTime) onReschedule;

  const _RescheduleOverlay({
    required this.appointment,
    required this.onReschedule,
  });

  @override
  State<_RescheduleOverlay> createState() => _RescheduleOverlayState();
}

class _RescheduleOverlayState extends State<_RescheduleOverlay> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _reschedule() async {
    if (_isLoading) return;

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      SnackbarUtils.showWarning(
          context, 'Please provide a reason for rescheduling');
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      SnackbarUtils.showWarning(
          context, 'Please select a new date and time');
      return;
    }

    final newDate = DateFormat('M/d/yyyy').format(_selectedDate!);
    final newTime = _selectedTime!.format(context);

    setState(() => _isLoading = true);
    await widget.onReschedule(reason, newDate, newTime);
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title in green
                      const Text(
                        '"Are you sure you want to Reschedule this appointment ?"',
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
                        'Please describe a reason for rescheduling the appointment:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reason text area
                      Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
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
                            hintText:
                                'Write your reason here...',
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

                      // Bottom row: Reschedule button + clock icon + time
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          // Reschedule button
                          GestureDetector(
                            onTap: _isLoading ? null : _reschedule,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: _isLoading
                                    ? AppColors.textMuted
                                    : AppColors.success,
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Reschedule',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),

                          // Date & Time picker row
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _pickDate,
                                child: Container(
                                  padding:
                                      const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius:
                                        BorderRadius.circular(
                                            8),
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_month,
                                        color: AppColors
                                            .textSecondary,
                                        size: 18,
                                      ),
                                      if (_selectedDate !=
                                          null)
                                        Padding(
                                          padding:
                                              const EdgeInsets
                                                  .only(
                                                  left: 4),
                                          child: Text(
                                            DateFormat(
                                                    'M/d/yyyy')
                                                .format(
                                                    _selectedDate!),
                                            style:
                                                const TextStyle(
                                              color: AppColors
                                                  .textSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: _pickTime,
                                child: Container(
                                  padding:
                                      const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius:
                                        BorderRadius.circular(
                                            8),
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: AppColors
                                            .textSecondary,
                                        size: 18,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets
                                                .only(
                                                left: 4),
                                        child: Text(
                                          _selectedTime !=
                                                  null
                                              ? _selectedTime!
                                                  .format(
                                                      context)
                                              : now,
                                          style:
                                              const TextStyle(
                                            color: AppColors
                                                .textMuted,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
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
//  Cancel Overlay (admin enters reason and confirms cancellation)
// ─────────────────────────────────────────────────────────────
class _CancelOverlay extends StatefulWidget {
  final AppointmentModel appointment;
  final Future<void> Function(String reason) onCancel;

  const _CancelOverlay({
    required this.appointment,
    required this.onCancel,
  });

  @override
  State<_CancelOverlay> createState() => _CancelOverlayState();
}

class _CancelOverlayState extends State<_CancelOverlay> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  Future<void> _cancel() async {
    if (_isLoading) return;

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      SnackbarUtils.showWarning(
          context, 'Please provide a reason for cancellation');
      return;
    }

    setState(() => _isLoading = true);
    await widget.onCancel(reason);
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
                      '"Are you sure you want to Cancel this appointment ?"',
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
                      'Please describe a reason for cancelling the appointment:',
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
                          color: AppColors.border,
                          width: 1,
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
                          hintText:
                              'Write your reason here...',
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

                    // Bottom row: Cancel button + time
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        // Cancel button
                        GestureDetector(
                          onTap: _isLoading ? null : _cancel,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: _isLoading
                                  ? AppColors.textMuted
                                  : AppColors.error,
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),

                        // Time
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: AppColors.textMuted,
                                size: 18),
                            const SizedBox(width: 4),
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