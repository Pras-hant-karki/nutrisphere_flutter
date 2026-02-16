import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nutrisphere_flutter/features/appointment/data/models/appointment_model.dart';
import 'package:nutrisphere_flutter/features/appointment/data/services/appointment_service.dart';

final appointmentsProvider = StateNotifierProvider<AppointmentsNotifier,
    AsyncValue<List<AppointmentModel>>>(
  (ref) {
    final service = ref.read(appointmentServiceProvider);
    return AppointmentsNotifier(service);
  },
);

class AppointmentsNotifier
    extends StateNotifier<AsyncValue<List<AppointmentModel>>> {
  final AppointmentService _service;

  AppointmentsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadAppointments();
  }

  Future<void> loadAppointments({bool pendingOnly = true}) async {
    state = const AsyncValue.loading();
    try {
      final appointments =
          await _service.getAllAppointments(pendingOnly: pendingOnly);
      state = AsyncValue.data(appointments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> approveAppointment(String appointmentId) async {
    try {
      await _service.approveAppointment(appointmentId);
      _removeFromLocalState(appointmentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rescheduleAppointment(
    String appointmentId,
    String message,
    String newDate,
    String newTime,
  ) async {
    try {
      await _service.rescheduleAppointment(
          appointmentId, message, newDate, newTime);
      _removeFromLocalState(appointmentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelAppointment(
      String appointmentId, String reason) async {
    try {
      await _service.cancelAppointment(appointmentId, reason);
      _removeFromLocalState(appointmentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _removeFromLocalState(String appointmentId) {
    final current = state.maybeWhen(
      data: (data) => data,
      orElse: () => <AppointmentModel>[],
    );
    state = AsyncValue.data(
      current.where((a) => a.id != appointmentId).toList(),
    );
  }
}
