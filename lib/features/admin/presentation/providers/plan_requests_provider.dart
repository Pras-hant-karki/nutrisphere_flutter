import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/plan_request_model.dart';
import 'package:nutrisphere_flutter/features/admin/data/services/plan_request_service.dart';

/// Provider that manages plan requests for admin
final planRequestsProvider = StateNotifierProvider<PlanRequestsNotifier,
    AsyncValue<List<PlanRequestModel>>>(
  (ref) {
    final service = ref.read(planRequestServiceProvider);
    return PlanRequestsNotifier(service);
  },
);

class PlanRequestsNotifier
    extends StateNotifier<AsyncValue<List<PlanRequestModel>>> {
  final PlanRequestService _service;

  PlanRequestsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadRequests();
  }

  Future<void> loadRequests({bool pendingOnly = true}) async {
    state = const AsyncValue.loading();
    try {
      final requests = await _service.getAllRequests(pendingOnly: pendingOnly);
      state = AsyncValue.data(requests);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Approve a request with a file
  Future<bool> approveWithFile(String requestId, String filePath) async {
    try {
      await _service.approveWithFile(requestId, filePath);
      _removeFromLocalState(requestId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Approve a request with a link
  Future<bool> approveWithLink(String requestId, String link) async {
    try {
      await _service.approveWithLink(requestId, link);
      _removeFromLocalState(requestId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reject a request with a reason
  Future<bool> rejectRequest(String requestId, String reason) async {
    try {
      await _service.rejectRequest(requestId, reason);
      _removeFromLocalState(requestId);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _removeFromLocalState(String requestId) {
    final current = state.maybeWhen(
      data: (data) => data,
      orElse: () => <PlanRequestModel>[],
    );
    state = AsyncValue.data(
      current.where((r) => r.id != requestId).toList(),
    );
  }
}
