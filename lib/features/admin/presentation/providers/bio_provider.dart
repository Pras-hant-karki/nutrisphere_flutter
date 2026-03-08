import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/bio_entry_model.dart';
import 'package:nutrisphere_flutter/features/admin/data/services/bio_service.dart';

/// Notifier that manages the list of bio entries
final bioEntriesProvider =
    StateNotifierProvider<BioEntriesNotifier, AsyncValue<List<BioEntryModel>>>(
  (ref) {
    final bioService = ref.read(bioServiceProvider);
    return BioEntriesNotifier(bioService);
  },
);

class BioEntriesNotifier extends StateNotifier<AsyncValue<List<BioEntryModel>>> {
  final BioService _bioService;

  BioEntriesNotifier(this._bioService) : super(const AsyncValue.loading()) {
    loadBio();
  }

  Future<void> loadBio() async {
    state = const AsyncValue.loading();
    try {
      final entries = await _bioService.getBio();
      state = AsyncValue.data(entries);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add a text entry locally
  void addTextEntry(String text) {
    final current = state.maybeWhen(
      data: (data) => data,
      orElse: () => <BioEntryModel>[],
    );
    state = AsyncValue.data([
      ...current,
      BioEntryModel(type: 'text', content: text),
    ]);
  }

  /// Add an image entry locally (with uploaded URL)
  void addImageEntry(String imageUrl) {
    final current = state.maybeWhen(
      data: (data) => data,
      orElse: () => <BioEntryModel>[],
    );
    state = AsyncValue.data([
      ...current,
      BioEntryModel(type: 'image', content: imageUrl),
    ]);
  }

  /// Update a text entry at index
  void updateTextEntry(int index, String text) {
    final current = state.maybeWhen(
      data: (data) => data,
      orElse: () => <BioEntryModel>[],
    );
    if (index >= 0 && index < current.length) {
      final updated = List<BioEntryModel>.from(current);
      updated[index] = updated[index].copyWith(content: text);
      state = AsyncValue.data(updated);
    }
  }

  /// Remove entry at index
  void removeEntry(int index) {
    final current = state.maybeWhen(
      data: (data) => data,
      orElse: () => <BioEntryModel>[],
    );
    if (index >= 0 && index < current.length) {
      final updated = List<BioEntryModel>.from(current);
      updated.removeAt(index);
      state = AsyncValue.data(updated);
    }
  }

  /// Save all entries to backend
  Future<bool> saveBio() async {
    final entries = state.maybeWhen(
      data: (data) => data,
      orElse: () => <BioEntryModel>[],
    );
    try {
      await _bioService.saveBio(entries);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Upload image and add entry
  Future<bool> uploadAndAddImage(String filePath) async {
    try {
      final imageUrl = await _bioService.uploadBioImage(filePath);
      addImageEntry(imageUrl);
      return true;
    } catch (e) {
      return false;
    }
  }
}
