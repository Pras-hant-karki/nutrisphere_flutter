import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/core/services/storage/user_session_service.dart';
import 'package:nutrisphere_flutter/core/utils/snackbar_utils.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/providers/bio_provider.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/bio_entry_model.dart';

class AdminBioPage extends ConsumerStatefulWidget {
  const AdminBioPage({super.key});

  @override
  ConsumerState<AdminBioPage> createState() => _AdminBioPageState();
}

class _AdminBioPageState extends ConsumerState<AdminBioPage> {
  final ImagePicker _imagePicker = ImagePicker();
  String _adminName = '';
  bool _isSaving = false;

  // Controllers for each text entry (managed dynamically)
  final Map<int, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    _loadAdminName();
  }

  Future<void> _loadAdminName() async {
    final session =
        await ref.read(userSessionServiceProvider).getSession();
    if (session != null && mounted) {
      setState(() {
        _adminName = session.fullName;
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(int index, String initialText) {
    if (!_textControllers.containsKey(index)) {
      _textControllers[index] = TextEditingController(text: initialText);
    }
    return _textControllers[index]!;
  }

  void _cleanupControllers(int entryCount) {
    _textControllers.removeWhere((key, controller) {
      if (key >= entryCount) {
        controller.dispose();
        return true;
      }
      return false;
    });
  }

  Future<void> _addPost() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Add to Bio",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 20),
                _buildSheetOption(
                  icon: Icons.edit_note_rounded,
                  label: "Add Text",
                  onTap: () {
                    Navigator.pop(ctx);
                    _addTextEntry();
                  },
                ),
                const SizedBox(height: 12),
                _buildSheetOption(
                  icon: Icons.image_rounded,
                  label: "Add Photo",
                  onTap: () {
                    Navigator.pop(ctx);
                    _addImageEntry();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 24),
            const SizedBox(width: 14),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTextEntry() {
    ref.read(bioEntriesProvider.notifier).addTextEntry('');
  }

  Future<void> _addImageEntry() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null && mounted) {
      setState(() => _isSaving = true);
      final success =
          await ref.read(bioEntriesProvider.notifier).uploadAndAddImage(image.path);
      setState(() => _isSaving = false);

      if (mounted) {
        if (success) {
          SnackbarUtils.showSuccess(context, 'Photo added');
        } else {
          SnackbarUtils.showError(context, 'Failed to upload photo');
        }
      }
    }
  }

  Future<void> _saveBio() async {
    // Sync all text controllers back to state
    final entries = ref.read(bioEntriesProvider).valueOrNull ?? [];
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].type == 'text' && _textControllers.containsKey(i)) {
        ref
            .read(bioEntriesProvider.notifier)
            .updateTextEntry(i, _textControllers[i]!.text);
      }
    }

    setState(() => _isSaving = true);
    final success = await ref.read(bioEntriesProvider.notifier).saveBio();
    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        SnackbarUtils.showSuccess(context, 'Bio saved successfully');
      } else {
        SnackbarUtils.showError(context, 'Failed to save bio');
      }
    }
  }

  void _removeEntry(int index) {
    if (_textControllers.containsKey(index)) {
      _textControllers[index]?.dispose();
      _textControllers.remove(index);
    }
    ref.read(bioEntriesProvider.notifier).removeEntry(index);
    // Rebuild controller map after removal
    final remaining = Map<int, TextEditingController>.from(_textControllers);
    _textControllers.clear();
    remaining.forEach((key, value) {
      final newKey = key > index ? key - 1 : key;
      _textControllers[newKey] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bioState = ref.watch(bioEntriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cardBackground,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Greeting
                  Expanded(
                    child: Text(
                      'Hi $_adminName !',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Profile avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        _adminName.isNotEmpty
                            ? _adminName[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // "My Bio" title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "My Bio",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
              ),
            ),

            // Bio entries list
            Expanded(
              child: bioState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load bio',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            ref.read(bioEntriesProvider.notifier).loadBio(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (entries) {
                  _cleanupControllers(entries.length);

                  if (entries.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.note_add_outlined,
                              size: 64,
                              color: AppColors.textMuted.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No bio entries yet.\nTap the + button to add text or photos.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _buildBioEntryCard(entry, index);
                    },
                  );
                },
              ),
            ),

            // Save Bio button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveBio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Bio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Golden + FAB
      floatingActionButton: FloatingActionButton(
        onPressed: _addPost,
        backgroundColor: AppColors.gold,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildBioEntryCard(BioEntryModel entry, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: entry.type == 'text'
                  ? _buildTextEntry(entry, index)
                  : _buildImageEntry(entry, index),
            ),
            // Delete button
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => _confirmRemove(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextEntry(BioEntryModel entry, int index) {
    final controller = _getController(index, entry.content);
    return TextField(
      controller: controller,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            height: 1.5,
          ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Write something about yourself...',
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.textMuted,
            ),
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildImageEntry(BioEntryModel entry, int index) {
    final imageUrl = entry.content;

    Widget imageWidget;
    if (imageUrl.startsWith('/uploads/') || imageUrl.startsWith('http')) {
      final fullUrl = imageUrl.startsWith('http')
          ? imageUrl
          : '${ApiEndpoints.baseUrl}$imageUrl';
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          fullUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 150,
            color: AppColors.inputFill,
            child: const Center(
              child: Icon(Icons.broken_image,
                  color: AppColors.textMuted, size: 40),
            ),
          ),
        ),
      );
    } else {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(imageUrl),
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 150,
            color: AppColors.inputFill,
            child: const Center(
              child: Icon(Icons.broken_image,
                  color: AppColors.textMuted, size: 40),
            ),
          ),
        ),
      );
    }

    return imageWidget;
  }

  void _confirmRemove(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Remove Entry',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to remove this entry?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeEntry(index);
            },
            child:
                const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}