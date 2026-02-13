import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/usecases/get_all_fitness_usecase.dart';

// Provider for fitness content state
final fitnessContentProvider = StateNotifierProvider<FitnessContentNotifier, AsyncValue<List<FitnessEntity>>>((ref) {
  final getAllFitnessUsecase = ref.read(getAllFitnessUsecaseProvider);
  return FitnessContentNotifier(getAllFitnessUsecase: getAllFitnessUsecase);
});

class FitnessContentNotifier extends StateNotifier<AsyncValue<List<FitnessEntity>>> {
  final GetAllFitnessUsecase _getAllFitnessUsecase;

  FitnessContentNotifier({required GetAllFitnessUsecase getAllFitnessUsecase})
      : _getAllFitnessUsecase = getAllFitnessUsecase,
        super(const AsyncValue.loading()) {
    loadFitnessContent();
  }

  Future<void> loadFitnessContent() async {
    state = const AsyncValue.loading();
    final result = await _getAllFitnessUsecase(const GetAllFitnessParams());

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (fitnessContent) {
        state = AsyncValue.data(fitnessContent);
      },
    );
  }

  Future<void> refresh() async {
    await loadFitnessContent();
  }
}