import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/member_model.dart';
import 'package:nutrisphere_flutter/features/admin/data/services/user_management_service.dart';

/// Provider that manages the list of members for admin
final membersProvider =
    StateNotifierProvider<MembersNotifier, AsyncValue<List<MemberModel>>>(
  (ref) {
    final service = ref.read(userManagementServiceProvider);
    return MembersNotifier(service);
  },
);

class MembersNotifier extends StateNotifier<AsyncValue<List<MemberModel>>> {
  final UserManagementService _service;

  MembersNotifier(this._service) : super(const AsyncValue.loading()) {
    loadMembers();
  }

  Future<void> loadMembers() async {
    state = const AsyncValue.loading();
    try {
      final users = await _service.getAllUsers();
      // Filter to show only non-admin users
      final members = users.where((u) => u.role != 'admin').toList();
      state = AsyncValue.data(members);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> deleteMember(String userId) async {
    try {
      await _service.deleteUser(userId);
      // Remove from local state
      final current = state.maybeWhen(
        data: (data) => data,
        orElse: () => <MemberModel>[],
      );
      state = AsyncValue.data(
        current.where((m) => m.id != userId).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
