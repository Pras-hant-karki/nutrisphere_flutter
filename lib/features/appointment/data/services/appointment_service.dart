import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/api/api_client.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/features/appointment/data/models/appointment_model.dart';

final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AppointmentService(apiClient: apiClient);
});

class AppointmentService {
  final ApiClient apiClient;

  AppointmentService({required this.apiClient});

  /// User books a new appointment
  Future<void> submitAppointment(Map<String, dynamic> data) async {
    try {
      await apiClient.post(
        ApiEndpoints.appointments,
        data: data,
      );
    } catch (e) {
      debugPrint('Error submitting appointment: $e');
      rethrow;
    }
  }

  /// User gets their own appointments
  Future<List<AppointmentModel>> getMyAppointments() async {
    try {
      final response = await apiClient.get(ApiEndpoints.myAppointments);
      final data = response.data['data'] as List;
      return data
          .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching my appointments: $e');
      rethrow;
    }
  }

  /// Admin gets all appointments
  Future<List<AppointmentModel>> getAllAppointments(
      {bool pendingOnly = false}) async {
    try {
      final queryParams = pendingOnly ? {'pending': 'true'} : null;
      final response = await apiClient.get(
        ApiEndpoints.adminAppointments,
        queryParameters: queryParams,
      );
      final data = response.data['data'] as List;
      return data
          .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all appointments: $e');
      rethrow;
    }
  }

  /// Admin approves an appointment
  Future<void> approveAppointment(String appointmentId) async {
    try {
      await apiClient.put(
        ApiEndpoints.approveAppointment(appointmentId),
      );
    } catch (e) {
      debugPrint('Error approving appointment: $e');
      rethrow;
    }
  }

  /// Admin reschedules an appointment
  Future<void> rescheduleAppointment(
    String appointmentId,
    String message,
    String newDate,
    String newTime,
  ) async {
    try {
      await apiClient.put(
        ApiEndpoints.rescheduleAppointment(appointmentId),
        data: {
          'message': message,
          'newDate': newDate,
          'newTime': newTime,
        },
      );
    } catch (e) {
      debugPrint('Error rescheduling appointment: $e');
      rethrow;
    }
  }

  /// Admin cancels an appointment
  Future<void> cancelAppointment(
      String appointmentId, String reason) async {
    try {
      await apiClient.put(
        ApiEndpoints.cancelAppointment(appointmentId),
        data: {'reason': reason},
      );
    } catch (e) {
      debugPrint('Error cancelling appointment: $e');
      rethrow;
    }
  }
}
