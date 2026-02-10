import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/core/providers/session_provider.dart';

class SessionManagePage extends ConsumerWidget {
  const SessionManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        'No sessions yet. Tap + to add.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        for (final day in daysOfWeek)
                          if (groupedSessions.containsKey(day)) ...[
                            // Day header
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 12, bottom: 8),
                              child: Text(
                                day,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
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
                                isAdmin: true,
                              );
                            }),
                          ],
                      ],
                    ),
            ),
          ],
        ),
      ),

      // FAB to add session
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddEditDialog(context, ref),
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    WidgetRef ref,
    Session session,
    int index, {
    required bool isAdmin,
  }) {
    return GestureDetector(
      onTap: () => _showSessionDetailPopup(context, session),
      child: Container(
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
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "(${session.timeRange})",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isAdmin) ...[
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: () =>
                    _showAddEditDialog(context, ref, session: session, index: index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: () => _confirmDelete(context, ref, index),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Popup with blur background showing full session details
  void _showSessionDetailPopup(BuildContext context, Session session) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location: ${session.location}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${session.workoutTitle}  (${session.timeRange})',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ...session.exercises.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      e,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Add or Edit session dialog
  void _showAddEditDialog(
    BuildContext context,
    WidgetRef ref, {
    Session? session,
    int? index,
  }) {
    final isEditing = session != null;
    String selectedDay = session?.day ?? daysOfWeek.first;
    final nameCtrl =
        TextEditingController(text: session?.sessionName ?? 'Group Workout');
    final timeCtrl =
        TextEditingController(text: session?.timeRange ?? '8:00 AM - 10:00 AM');
    final locationCtrl =
        TextEditingController(text: session?.location ?? '');
    final workoutCtrl =
        TextEditingController(text: session?.workoutTitle ?? '');
    final exercisesCtrl =
        TextEditingController(text: session?.exercises.join('\n') ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                isEditing ? 'Edit Session' : 'Add Session',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Day dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedDay,
                      dropdownColor: AppColors.cardBackground,
                      decoration: _inputDecoration('Day'),
                      style: const TextStyle(color: AppColors.textPrimary),
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
                    const SizedBox(height: 10),
                    _buildTextField(nameCtrl, 'Session Name'),
                    const SizedBox(height: 10),
                    _buildTextField(timeCtrl, 'Time Range (e.g. 8:00 AM - 10:00 AM)'),
                    const SizedBox(height: 10),
                    _buildTextField(locationCtrl, 'Location'),
                    const SizedBox(height: 10),
                    _buildTextField(workoutCtrl, 'Workout Title'),
                    const SizedBox(height: 10),
                    _buildTextField(exercisesCtrl, 'Exercises (one per line)',
                        maxLines: 5),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () {
                    final newSession = Session(
                      day: selectedDay,
                      sessionName: nameCtrl.text,
                      timeRange: timeCtrl.text,
                      location: locationCtrl.text,
                      workoutTitle: workoutCtrl.text,
                      exercises: exercisesCtrl.text
                          .split('\n')
                          .where((e) => e.trim().isNotEmpty)
                          .toList(),
                    );
                    if (isEditing && index != null) {
                      ref
                          .read(sessionProvider.notifier)
                          .updateSession(index, newSession);
                    } else {
                      ref.read(sessionProvider.notifier).addSession(newSession);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    isEditing ? 'Update' : 'Add',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Confirm delete dialog
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
            onPressed: () {
              ref.read(sessionProvider.notifier).deleteSession(index);
              Navigator.pop(ctx);
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
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

  Widget _buildTextField(TextEditingController ctrl, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: _inputDecoration(label),
      style: const TextStyle(color: AppColors.textPrimary),
    );
  }
}