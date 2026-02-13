import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/app/theme/theme_extensions.dart';
import 'package:nutrisphere_flutter/core/utils/snackbar_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/usecases/upload_photo_usecase.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/usecases/upload_video_usecase.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/usecases/create_fitness_usecase.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/usecases/update_fitness_usecase.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/usecases/delete_fitness_usecase.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';
import 'package:nutrisphere_flutter/features/fitness/presentation/providers/fitness_content_provider.dart';

class AdminFitnessGuidePage extends ConsumerStatefulWidget {
  const AdminFitnessGuidePage({super.key});

  @override
  ConsumerState<AdminFitnessGuidePage> createState() => _AdminFitnessGuidePageState();
}

class _AdminFitnessGuidePageState extends ConsumerState<AdminFitnessGuidePage> {

  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers for creating/editing fitness content
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  String _selectedCategory = 'cardio';
  bool _isCreating = false;
  FitnessEntity? _editingFitness; // For edit mode

  final List<String> _categories = [
    'cardio',
    'strength',
    'yoga',
    'flexibility',
    'hiit',
    'pilates',
    'meditation',
    'nutrition',
    'other'
  ];

  Future<bool> _askPermissionWithUser(Permission permission) async {
    final status = await permission.status;
    if(status.isGranted) {
      return true;
    }

    if(status.isDenied) {
      final result = await permission.request(); 
      return result.isGranted;
    }

    if(status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }
    return false;
  }

  Future<bool> _requestGalleryPermission() async {
    try {
      // Try requesting photos permission first (Android 13+)
      PermissionStatus status = await Permission.photos.request();
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        // Show error message for denied permission
        if (mounted) {
          SnackbarUtils.showError(context, 'Please enable gallery permission');
        }
        return false;
      }
      
      if (status.isPermanentlyDenied) {
        // Show dialog to open settings
        _showPermissionDeniedDialog();
        return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('Permission Error: $e');
      return false;
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text("Permission Required"),
        content: Text(
          "Gallery access is permanently denied. Please enable it in app settings to use this feature."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Cancel')
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            }, 
            child: Text('Open Settings')
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _durationController.clear();
    _selectedCategory = 'cardio';
    _editingFitness = null;
  }

  void _populateFormForEdit(FitnessEntity fitness) {
    _editingFitness = fitness;
    _titleController.text = fitness.title ?? '';
    _descriptionController.text = fitness.description ?? '';
    _selectedCategory = fitness.category ?? 'cardio';
    _durationController.text = fitness.duration?.toString() ?? '';
  }

  // Show form dialog for creating/editing fitness content
  void _showFitnessContentForm({FitnessEntity? fitness}) {
    if (fitness != null) {
      _populateFormForEdit(fitness);
    } else {
      _resetForm();
    }

    XFile? selectedMedia; // Local variable for media selection in form

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        fitness != null ? 'Edit Fitness Content' : 'Create Fitness Content',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Title field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title *',
                      hintText: 'Enter fitness content title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: context.surfaceColor,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      if (value.length < 5) {
                        return 'Title must be at least 5 characters';
                      }
                      if (value.length > 100) {
                        return 'Title must not exceed 100 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description *',
                      hintText: 'Enter detailed description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: context.surfaceColor,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      if (value.length < 10) {
                        return 'Description must be at least 10 characters';
                      }
                      if (value.length > 500) {
                        return 'Description must not exceed 500 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Category dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: context.surfaceColor,
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  // Duration field
                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Duration (minutes)',
                      hintText: 'Optional duration in minutes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: context.surfaceColor,
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final duration = int.tryParse(value);
                        if (duration == null || duration <= 0) {
                          return 'Duration must be a positive number';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Media selection (if not editing or if editing without media)
                  if (selectedMedia == null && (fitness == null || fitness.media == null))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Media (Optional)',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final image = await _imagePicker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 80,
                                  );
                                  if (image != null) {
                                    setState(() {
                                      selectedMedia = image;
                                    });
                                  }
                                },
                                icon: Icon(Icons.image),
                                label: Text('Pick Image'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final hasPermission = await _askPermissionWithUser(Permission.camera);
                                  if (!hasPermission) return;

                                  final video = await _imagePicker.pickVideo(
                                    source: ImageSource.camera,
                                    maxDuration: Duration(minutes: 1),
                                  );
                                  if (video != null) {
                                    setState(() {
                                      selectedMedia = video;
                                    });
                                  }
                                },
                                icon: Icon(Icons.videocam),
                                label: Text('Record Video'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  // Media preview
                  if (selectedMedia != null)
                    Column(
                      children: [
                        SizedBox(height: 16),
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(selectedMedia!.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedMedia = null;
                                });
                              },
                              child: Text('Remove Media'),
                            ),
                          ],
                        ),
                      ],
                    ),

                  SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isCreating ? null : () => _saveFitnessContent(context, selectedMedia),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isCreating
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(fitness != null ? 'Update' : 'Create'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Save fitness content (create or update)
  Future<void> _saveFitnessContent(BuildContext context, XFile? selectedMedia) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      String? mediaUrl;
      String? mediaType;

      // Upload media if selected
      if (selectedMedia != null) {
        final file = File(selectedMedia.path);
        if (selectedMedia.path.toLowerCase().endsWith('.mp4') ||
            selectedMedia.path.toLowerCase().endsWith('.mov') ||
            selectedMedia.path.toLowerCase().endsWith('.avi')) {
          // Upload video
          final result = await ref.read(uploadVideoUsecaseProvider)(file);
          result.fold(
            (failure) => throw Exception('Video upload failed: ${failure.message}'),
            (url) {
              mediaUrl = url;
              mediaType = 'video';
            },
          );
        } else {
          // Upload image
          final result = await ref.read(uploadPhotoUsecaseProvider)(file);
          result.fold(
            (failure) => throw Exception('Image upload failed: ${failure.message}'),
            (url) {
              mediaUrl = url;
              mediaType = 'image';
            },
          );
        }
      }

      final params = CreateFitnessParams(
        fitnessId: _editingFitness?.fitnessId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        media: mediaUrl ?? _editingFitness?.media,
        mediaType: mediaType ?? _editingFitness?.mediaType,
        duration: _durationController.text.isNotEmpty
            ? int.tryParse(_durationController.text)
            : null,
      );

      if (_editingFitness != null) {
        // Update existing content
        final updateParams = UpdateFitnessParams(
          fitnessId: _editingFitness!.fitnessId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          location: '', 
          media: mediaUrl ?? _editingFitness?.media,
          mediaType: mediaType ?? _editingFitness?.mediaType,
        );
        final result = await ref.read(updateFitnessUsecaseProvider)(updateParams);
        result.fold(
          (failure) => throw Exception('Update failed: ${failure.message}'),
          (_) {
            if (mounted) {
              SnackbarUtils.showSuccess(context, 'Fitness content updated successfully');
              Navigator.pop(context);
              // Refresh the content list
              ref.invalidate(fitnessContentProvider);
            }
          },
        );
      } else {
        // Create new content
        final result = await ref.read(createFitnessUsecaseProvider)(params);
        result.fold(
          (failure) => throw Exception('Creation failed: ${failure.message}'),
          (success) {
            if (mounted) {
              SnackbarUtils.showSuccess(context, 'Fitness content created successfully');
              Navigator.pop(context);
              // Refresh the content list
              ref.invalidate(fitnessContentProvider);
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // top bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "High quality fitness guidance below !",
                        style: textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),

                // scrollable content
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final fitnessState = ref.watch(fitnessContentProvider);

                      return fitnessState.when(
                        loading: () => Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                        error: (error, stack) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, color: AppColors.error, size: 48),
                              SizedBox(height: 12),
                              Text(
                                'Failed to load fitness content',
                                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                              ),
                              SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => ref.invalidate(fitnessContentProvider),
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                        data: (fitnessList) {
                          if (fitnessList.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.fitness_center,
                                    size: 64,
                                    color: AppColors.textMuted.withOpacity(0.5),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No fitness content yet.\nTap the + button to create your first content.',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            itemCount: fitnessList.length,
                            itemBuilder: (context, index) {
                              final fitness = fitnessList[index];
                              return _buildFitnessContentCard(fitness);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            /// FLOATING + BUTTON (ADMIN CREATE FITNESS CONTENT)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _showFitnessContentForm();
                  },
                  child: Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build fitness content card with edit/delete options
  Widget _buildFitnessContentCard(FitnessEntity fitness) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media (if available)
          if (fitness.media != null && fitness.media!.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                image: DecorationImage(
                  image: NetworkImage(fitness.media!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and category
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        fitness.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // Category badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (fitness.category ?? 'other').toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Description
                if (fitness.description != null && fitness.description!.isNotEmpty)
                  Text(
                    fitness.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                SizedBox(height: 12),

                // Duration (if available)
                if (fitness.duration != null && fitness.duration! > 0)
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: AppColors.textMuted),
                      SizedBox(width: 4),
                      Text(
                        '${fitness.duration} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showFitnessContentForm(fitness: fitness),
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteConfirmation(fitness),
                      icon: Icon(Icons.delete, size: 18),
                      label: Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Show delete confirmation for fitness content
  void _showDeleteConfirmation(FitnessEntity fitness) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Fitness Content'),
        content: Text('Are you sure you want to delete "${fitness.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteFitnessContent(fitness),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Delete fitness content
  Future<void> _deleteFitnessContent(FitnessEntity fitness) async {
    Navigator.pop(context); // Close confirmation dialog

    try {
      final result = await ref.read(deleteFitnessUsecaseProvider)(
        DeleteFitnessParams(fitnessId: fitness.fitnessId!)
      );
      result.fold(
        (failure) {
          if (mounted) SnackbarUtils.showError(context, 'Delete failed: ${failure.message}');
        },
        (_) {
          if (mounted) {
            SnackbarUtils.showSuccess(context, 'Fitness content deleted successfully');
            ref.invalidate(fitnessContentProvider);
          }
        },
      );
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, 'Delete failed: $e');
    }
  }
}
