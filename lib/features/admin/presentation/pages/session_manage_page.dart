import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/core/providers/session_provider.dart';

class SessionManagePage extends ConsumerStatefulWidget {
  const SessionManagePage({super.key});

  @override
  ConsumerState<SessionManagePage> createState() => _SessionManagePageState();
}

class _SessionManagePageState extends ConsumerState<SessionManagePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sessionProvider.notifier).refreshAdminSessions());
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);
    final groupedSessions = notifier.sessionsByDay;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Manage Sessions",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),

            if (kDebugMode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'API: ${ApiEndpoints.baseUrl}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                  ),
                ),
              ),

            if (kDebugMode) const SizedBox(height: 8),

            // "Sessions" banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "Sessions",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Session list grouped by day
            Expanded(
              child: sessions.isEmpty
                  ? const Center(
                      child: Text(
                        'No sessions yet. Tap the gold button to add.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        for (final day in daysOfWeek)
                          if (groupedSessions.containsKey(day)) ...[
                            // Day header with golden add button on first day
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 12, bottom: 8),
                              child: Row(
                                children: [
                                  Text(
                                    day,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  // Golden add button on the first day header
                                  if (day ==
                                      daysOfWeek.firstWhere(
                                          (d) =>
                                              groupedSessions
                                                  .containsKey(d),
                                          orElse: () => ''))
                                    GestureDetector(
                                      onTap: () => _showSessionPopup(
                                          context, ref),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          color: AppColors.gold,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Session cards for this day
                            ...groupedSessions[day]!.map((session) {
                              final globalIndex =
                                  sessions.indexOf(session);
                              return _buildSessionCard(
                                context,
                                ref,
                                session,
                                globalIndex,
                              );
                            }),
                          ],
                        // If there are sessions but we want the add button always visible
                        // even when the first day header is scrolled away
                      ],
                    ),
            ),
          ],
        ),
      ),

      // Golden FAB as a fallback when no sessions exist
      floatingActionButton: sessions.isEmpty
          ? FloatingActionButton(
              backgroundColor: AppColors.gold,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _showSessionPopup(context, ref),
            )
          : null,
    );
  }

  // ─────────────────────────────────────────────────────
  // Session card with edit (green pencil) & delete (red bin)
  // ─────────────────────────────────────────────────────
  Widget _buildSessionCard(
    BuildContext context,
    WidgetRef ref,
    Session session,
    int index,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.sessionName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: session.isActive
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  "(${session.timeRange})",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: session.isActive
                            ? AppColors.textSecondary
                            : AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
          // Edit button — opens popup card
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () =>
                _showSessionPopup(context, ref, session: session, index: index),
          ),
          // Delete button — deletes session
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref, index),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Popup card (Add / Edit) — matches the design image
  // Location field, Time field with clock icon (from–to picker),
  // Session Details large text area, Save button, On/Off toggle
  // ─────────────────────────────────────────────────────
  void _showSessionPopup(
    BuildContext context,
    WidgetRef ref, {
    Session? session,
    int? index,
  }) {
    final isEditing = session != null;

    String selectedDay = session?.day ?? daysOfWeek.first;
    final locationCtrl =
        TextEditingController(text: session?.location ?? '');
    final timeCtrl =
        TextEditingController(text: session?.timeRange ?? '');
    final detailsCtrl = TextEditingController(
      text: session != null
          ? '${session.sessionName}\n${session.workoutTitle}\n${session.exercises.join('\n')}'
          : '',
    );
    bool isActive = session?.isActive ?? true;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Dialog(
                backgroundColor: AppColors.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Day dropdown ──
                      DropdownButtonFormField<String>(
                        initialValue: selectedDay,
                        dropdownColor: AppColors.cardBackground,
                        decoration: _popupInputDecoration('Day'),
                        style:
                            const TextStyle(color: AppColors.textPrimary),
                        items: daysOfWeek
                            .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setDialogState(() => selectedDay = val!);
                        },
                      ),
                      const SizedBox(height: 14),

                      // ── Location field ──
                      TextField(
                        controller: locationCtrl,
                        decoration: _popupInputDecoration('Location:'),
                        style:
                            const TextStyle(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 14),

                      // ── Time field with clock icon ──
                      TextField(
                        controller: timeCtrl,
                        readOnly: true,
                        decoration: _popupInputDecoration('Time:').copyWith(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time,
                                color: AppColors.textPrimary),
                            onPressed: () async {
                              // Pick FROM time
                              final fromTime = await showTimePicker(
                                context: ctx,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) =>
                                    _timePickerTheme(context, child),
                              );
                              if (fromTime == null) return;

                              // Pick TO time
                              if (!ctx.mounted) return;
                              final toTime = await showTimePicker(
                                context: ctx,
                                initialTime: fromTime.replacing(
                                    hour: (fromTime.hour + 2) % 24),
                                builder: (context, child) =>
                                    _timePickerTheme(context, child),
                              );
                              if (toTime == null) return;

                              setDialogState(() {
                                timeCtrl.text =
                                    '${_formatTime(fromTime)} - ${_formatTime(toTime)}';
                              });
                            },
                          ),
                        ),
                        style:
                            const TextStyle(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 14),

                      // ── Session Details ──
                      TextField(
                        controller: detailsCtrl,
                        maxLines: 7,
                        decoration:
                            _popupInputDecoration('Session Details'),
                        style:
                            const TextStyle(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 20),

                      // ── Bottom row: Save Session + Toggle ──
                      Row(
                        children: [
                          // Save button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            onPressed: () {
                              _saveSession(
                                ref,
                                ctx,
                                isEditing: isEditing,
                                index: index,
                                day: selectedDay,
                                locationCtrl: locationCtrl,
                                timeCtrl: timeCtrl,
                                detailsCtrl: detailsCtrl,
                                isActive: isActive,
                              );
                            },
                            child: const Text('Save Session'),
                          ),
                          const Spacer(),
                          // On/Off toggle
                          Switch(
                            value: isActive,
                            activeThumbColor: AppColors.textPrimary,
                            activeTrackColor: AppColors.secondaryDark,
                            inactiveThumbColor: AppColors.textMuted,
                            inactiveTrackColor: AppColors.border,
                            onChanged: (val) {
                              setDialogState(() => isActive = val);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────
  // Save logic — parses the details text area
  // ─────────────────────────────────────────────────────
  void _saveSession(
    WidgetRef ref,
    BuildContext ctx, {
    required bool isEditing,
    int? index,
    required String day,
    required TextEditingController locationCtrl,
    required TextEditingController timeCtrl,
    required TextEditingController detailsCtrl,
    required bool isActive,
  }) async {
    final lines = detailsCtrl.text
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    // First line = session name, second line = workout title, rest = exercises
    final sessionName =
        lines.isNotEmpty ? lines[0] : 'Group Workout';
    final workoutTitle =
        lines.length > 1 ? lines[1] : '';
    final exercises =
        lines.length > 2 ? lines.sublist(2) : <String>[];

    final newSession = Session(
      day: day,
      sessionName: sessionName,
      timeRange: timeCtrl.text,
      location: locationCtrl.text,
      workoutTitle: workoutTitle,
      exercises: exercises,
      isActive: isActive,
    );

    try {
      if (isEditing && index != null) {
        await ref.read(sessionProvider.notifier).updateSession(index, newSession);
      } else {
        await ref.read(sessionProvider.notifier).addSession(newSession);
      }

      if (ctx.mounted) {
        Navigator.pop(ctx);
      }
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Session updated successfully' : 'Session added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('Failed to save session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────
  // Confirm delete dialog
  // ─────────────────────────────────────────────────────
  void _confirmDelete(BuildContext context, WidgetRef ref, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Session',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to delete this session?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(sessionProvider.notifier).deleteSession(index);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Session deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete session: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────
  InputDecoration _popupInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: AppColors.inputFill,
    );
  }

  Widget _timePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          surface: AppColors.cardBackground,
          onSurface: AppColors.textPrimary,
        ),
      ),
      child: child!,
    );
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}