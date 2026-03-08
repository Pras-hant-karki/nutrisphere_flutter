import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/api/api_client.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/bio_entry_model.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/trainer_info_model.dart';
import 'package:nutrisphere_flutter/features/admin/data/services/bio_service.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/providers/bio_provider.dart';

class _FakeBioService extends BioService {
  _FakeBioService() : super(apiClient: ApiClient());

  @override
  Future<List<BioEntryModel>> getBio() async => [];

  @override
  Future<TrainerInfoModel> getTrainerInfo() async => throw UnimplementedError();

  @override
  Future<void> saveBio(List<BioEntryModel> entries) async {}

  @override
  Future<String> uploadBioImage(String filePath) async => 'img';
}

void main() {
  group('BioEntriesNotifier', () {
    test('addTextEntry appends a text entry', () {
      final notifier = BioEntriesNotifier(_FakeBioService());

      notifier.addTextEntry('hello');

      expect(notifier.state.value?.last.content, 'hello');
    });

    test('removeEntry removes by index', () {
      final notifier = BioEntriesNotifier(_FakeBioService());
      notifier.addTextEntry('first');
      notifier.addTextEntry('second');

      notifier.removeEntry(0);

      expect(notifier.state.value?.length, 1);
      expect(notifier.state.value?.first.content, 'second');
    });
  });
}