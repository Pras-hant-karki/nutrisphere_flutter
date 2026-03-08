import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/api/api_client.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/member_model.dart';
import 'package:nutrisphere_flutter/features/admin/data/services/user_management_service.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/providers/members_provider.dart';

class _FakeUserManagementService extends UserManagementService {
  _FakeUserManagementService() : super(apiClient: ApiClient());

  @override
  Future<List<MemberModel>> getAllUsers() async {
    return [
      MemberModel(id: '1', fullName: 'Admin', email: 'a@mail.com', role: 'admin'),
      MemberModel(id: '2', fullName: 'User', email: 'u@mail.com', role: 'user'),
    ];
  }

  @override
  Future<void> deleteUser(String userId) async {}
}

void main() {
  test('MembersNotifier filters out admins', () async {
    final notifier = MembersNotifier(_FakeUserManagementService());

    await notifier.loadMembers();

    expect(notifier.state.value?.length, 1);
    expect(notifier.state.value?.first.role, 'user');
  });
}