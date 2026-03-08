import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/trainer_info_model.dart';
import 'package:nutrisphere_flutter/features/admin/data/services/bio_service.dart';

final trainerInfoProvider =
    FutureProvider<TrainerInfoModel>((ref) async {
  final bioService = ref.read(bioServiceProvider);
  return bioService.getTrainerInfo();
});
