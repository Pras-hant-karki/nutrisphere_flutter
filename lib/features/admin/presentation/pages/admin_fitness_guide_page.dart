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

class AdminFitnessGuidePage extends ConsumerStatefulWidget {
  const AdminFitnessGuidePage({super.key});

  @override
  ConsumerState<AdminFitnessGuidePage> createState() => _AdminFitnessGuidePageState();
}

class _AdminFitnessGuidePageState extends ConsumerState<AdminFitnessGuidePage> {

  XFile? _pendingMedia; // Media being previewed before confirmation
  final List<XFile> _confirmedMedia = []; // List of confirmed photos to display
  final ImagePicker _imagePicker = ImagePicker();

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

  // Media selection
  final List<XFile> _selectedMedia = []; // images or video
  // final ImagePicker _imagePicker = ImagePicker();
  String? _selectedMediaType; // 'image' or 'video'

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

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Photo"),
        content: Text("Are you sure you want to delete this photo?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _confirmedMedia.removeAt(index);
              });
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // camera code
  Future<void> _clickFromCamera() async{
    final hasPermission = await _askPermissionWithUser(Permission.camera);
    if(!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(photo);
        _selectedMediaType = 'photo';
        _pendingMedia = photo;
      });
      // Upload photo to server using fitness upload usecase
      final uploadResult = await ref.read(uploadPhotoUsecaseProvider)(File(photo.path));
      uploadResult.fold(
        (failure) {
          if (mounted) SnackbarUtils.showError(context, failure.message);
        },
        (url) {
          if (mounted) SnackbarUtils.showSuccess(context, 'Photo uploaded');
        },
      );
    }
  }

  // gallery code
  Future<void> _pickFromGallery({bool allowMultiple = false}) async {
    try {
      if (allowMultiple) {
        final List<XFile> images = await _imagePicker.pickMultiImage(
          imageQuality: 80,
        );

        if (images.isNotEmpty) {
          setState(() {
            _selectedMedia.clear();
            _selectedMedia.addAll(images);
            _selectedMediaType = 'photo';
            _pendingMedia = images.first;
          });
          // Upload first photo to server using fitness upload usecase
          final uploadResult = await ref.read(uploadPhotoUsecaseProvider)(File(images.first.path));
          uploadResult.fold(
            (failure) {
              if (mounted) SnackbarUtils.showError(context, failure.message);
            },
            (url) {
              if (mounted) SnackbarUtils.showSuccess(context, 'Photo uploaded');
            },
          );
        }
      } else {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() {
            _selectedMedia.clear();
            _selectedMedia.add(image);
            _selectedMediaType = 'photo';
          });
          // Upload photo to server using fitness upload usecase
          final uploadResult = await ref.read(uploadPhotoUsecaseProvider)(File(image.path));
          uploadResult.fold(
            (failure) {
              if (mounted) SnackbarUtils.showError(context, failure.message);
            },
            (url) {
              if (mounted) SnackbarUtils.showSuccess(context, 'Photo uploaded');
            },
          );
        }
      }
    } catch (e) {
      debugPrint('Gallery Error $e');

      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Unable to access gallery. Please try using the camera instead.',
        );
      }
    }
  }

  // video code
  Future<void> _pickFromVideo() async {
    try{
      final hasPermission = await _askPermissionWithUser(
        Permission.camera,
      );
      if (!hasPermission) return;

      final hasMicPermission = await _askPermissionWithUser(
        Permission.microphone,
      );
      if (!hasMicPermission) return;

      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 1),
      );

      if (video != null) {
        setState(() {
          _selectedMedia.clear();
          _selectedMedia.add(video);
          _selectedMediaType = 'video';
        });
        // Upload video to server using fitness upload video usecase
        final uploadResult = await ref.read(uploadVideoUsecaseProvider)(File(video.path));
        uploadResult.fold(
          (failure) {
            if (mounted) SnackbarUtils.showError(context, failure.message);
          },
          (url) {
            if (mounted) SnackbarUtils.showSuccess(context, 'Video uploaded');
          },
        );
      }
    } catch (e) {
      _showPermissionDeniedDialog();
    }
  }

  // code for dialogBox : showDialog for menu
  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context, 
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)
      ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding:EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera), 
                title: Text('Open Camera') , 
                onTap: () {
                  Navigator.pop(context);
                  _clickFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.browse_gallery), 
                title: Text('Open Gallery') ,
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.video_camera_back), 
                title: Text('Record Video') , 
                onTap: () {
                  Navigator.pop(context);
                  _pickFromVideo();
                },
              ),
            ],
          ),
        ),
      ),
    );
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

                if (_pendingMedia != null) ...[
                  Column(
                    children: [
                      // Preview for pending media
                      Stack(
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: FileImage(File(_pendingMedia!.path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _pendingMedia = null;
                                });
                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Confirm / Cancel buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _pendingMedia = null;
                              });
                            },
                            child: const Text("Cancel"),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _confirmedMedia.add(_pendingMedia!);
                                _pendingMedia = null;
                              });
                            },
                            child: const Text("Confirm"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],


                // scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Show all confirmed media
                        ..._confirmedMedia.asMap().entries.map((entry) {
                          int index = entry.key;
                          XFile media = entry.value;
                          return Column(
                            children: [
                              _imagePreviewCardWithDelete(File(media.path), index),
                              const SizedBox(height: 20),
                            ],
                          );
                        }).toList(),

                        const SizedBox(height: 120), // space for floating +
                      ],
                    ),
                  ),
                ),
              ],
            ),

            /// FLOATING + BUTTON (ADMIN POST)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _pickMedia();
                  },
                  child: Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: Colors.green,
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

  // image card
  Widget _imageCard({required String imagePath}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }

Widget _imagePreviewCardWithDelete(File file, int index) {
  return Stack(
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.file(
          file,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        top: 16,
        right: 16,
        child: GestureDetector(
          onTap: () {
            _showDeleteConfirmationDialog(index);
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    ],
  );
}
}
