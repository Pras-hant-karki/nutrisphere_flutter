import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/api/api_client.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/plan_request_model.dart';
import 'package:nutrisphere_flutter/features/admin/data/services/plan_request_service.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/providers/plan_requests_provider.dart';

class _FakePlanRequestService extends PlanRequestService {
  _FakePlanRequestService() : super(apiClient: ApiClient());

  @override
  Future<List<PlanRequestModel>> getAllRequests({bool pendingOnly = false}) async {
    return [
      PlanRequestModel(
        id: 'r1',
        userId: 'u1',
        requestType: 'diet',
        height: '170',
        weight: '70',
        job: 'dev',
        foodAllergy: 'none',
        dietType: 'veg',
        medicalCondition: 'none',
        trainingType: 'gym',
        goal: 'fit',
        specialRequest: '',
        status: 'pending',
        createdAt: DateTime(2026, 1, 1),
      ),
    ];
  }

  @override
  Future<void> approveWithFile(String requestId, String filePath) async {}

  @override
  Future<void> approveWithLink(String requestId, String link) async {}

  @override
  Future<void> rejectRequest(String requestId, String reason) async {}
}

void main() {
  test('PlanRequestsNotifier removes approved request from state', () async {
    final notifier = PlanRequestsNotifier(_FakePlanRequestService());
    await notifier.loadRequests();

    final ok = await notifier.approveWithLink('r1', 'https://example.com/plan');

    expect(ok, isTrue);
    expect(notifier.state.value, isEmpty);
  });
}