import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';
import 'package:nutrisphere_flutter/core/providers/sensor_provider.dart';
import 'package:nutrisphere_flutter/core/services/storage/user_session_service.dart';
import 'package:nutrisphere_flutter/core/utils/snackbar_utils.dart';
import 'package:nutrisphere_flutter/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:nutrisphere_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:nutrisphere_flutter/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:nutrisphere_flutter/features/profile/domain/usecases/upload_profile_picture_usecase.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _profileImage;
  String? _profileImageUrl;
  bool _isLoading = true;
  StreamSubscription<bool>? _shakeSub;
  DateTime _lastShakeSaveAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _isSavingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _attachShakeAutosave();
  }

  void _attachShakeAutosave() {
    _shakeSub = ref.read(sensorServiceProvider).shakeStream.listen((detected) async {
      if (!detected || !mounted) return;
      if (!TickerMode.of(context)) return;
      if (_isSavingProfile) return;

      final now = DateTime.now();
      if (now.difference(_lastShakeSaveAt) < const Duration(seconds: 4)) {
        return;
      }
      _lastShakeSaveAt = now;

      await _saveProfile(triggeredByShake: true);
    });
  }

  Future<void> _loadUserData() async {
    final userSession = ref.read(userSessionServiceProvider);
    final session = await userSession.getSession();
    
    if (session != null) {
      setState(() {
        _nameCtrl.text = session.fullName;
        _emailCtrl.text = session.email;
        _usernameCtrl.text = _getUsernameFromEmail(session.email);
        _roleCtrl.text = _capitalize(session.role ?? 'User');
        _phoneCtrl.text = session.phone ?? '';
        if (session.profilePicture != null && session.profilePicture!.isNotEmpty) {
          _profileImageUrl = session.profilePicture!.startsWith('http')
              ? session.profilePicture!
              : '${ApiEndpoints.baseUrl}${session.profilePicture!}';
        }
        _isLoading = false;
      });

      await _syncUserFromServer();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _syncUserFromServer() async {
    try {
      final remoteUser = await ref.read(authRemoteDatasourceProvider).getCurrentUser();
      if (remoteUser == null) {
        return;
      }

      final normalizedPicture =
          (remoteUser.profilePicture != null && remoteUser.profilePicture!.isNotEmpty)
              ? (remoteUser.profilePicture!.startsWith('http')
                  ? remoteUser.profilePicture!
                  : '${ApiEndpoints.baseUrl}${remoteUser.profilePicture!}')
              : null;

      if (mounted) {
        setState(() {
          _nameCtrl.text = remoteUser.fullName;
          _emailCtrl.text = remoteUser.email;
          _usernameCtrl.text = _getUsernameFromEmail(remoteUser.email);
          _roleCtrl.text = _capitalize(remoteUser.role ?? _roleCtrl.text);
          _phoneCtrl.text = remoteUser.phone ?? '';
          _profileImageUrl = normalizedPicture;
        });
      }

      final userSession = ref.read(userSessionServiceProvider);
      final oldSession = await userSession.getSession();
      await userSession.saveSession(
        userId: remoteUser.authId ?? oldSession?.userId ?? '',
        email: remoteUser.email,
        fullName: remoteUser.fullName,
        role: remoteUser.role ?? oldSession?.role,
        phone: remoteUser.phone,
        profilePicture: remoteUser.profilePicture,
      );
    } catch (_) {
      // keep cached data when server sync fails
    }
  }

  String _getUsernameFromEmail(String email) {
    // Extract username from email or return "User"
    if (email.contains('@')) {
      return email.split('@')[0];
    }
    return "User";
  }

  // String _getRoleLabelFromEmail(String email) {
  //   return email.toLowerCase().contains('admin') ? 'Admin' : 'User';
  // }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _getInitials(String fullName) {
    final names = fullName.trim().split(' ');
    if (names.isEmpty) return 'U';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  Future<bool> _requestGalleryPermission() async {
    try {
      PermissionStatus status = await Permission.photos.request();
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        if (mounted) {
          SnackbarUtils.showError(context, 'Please enable gallery permission');
        }
        return false;
      }
      
      if (status.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
        return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('Permission Error: $e');
      return false;
    }
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Please enable camera permission');
      }
      return false;
    }
    
    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }
    
    return false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "Permission is permanently denied. Please enable it in app settings to use this feature."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final hasPermission = await _requestGalleryPermission();
    if (!hasPermission) return;

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _profileImage = photo;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose Image Source"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile({bool triggeredByShake = false}) async {
    if (_isSavingProfile) return;
    _isSavingProfile = true;

    final userSession = ref.read(userSessionServiceProvider);
    final session = await userSession.getSession();
    if (session == null) {
      if (mounted) {
        SnackbarUtils.showError(context, 'User session not found');
      }
      _isSavingProfile = false;
      return;
    }

    // Upload profile picture first if selected
    if (_profileImage != null) {
      final uploadResult = await ref.read(uploadProfilePictureUsecaseProvider)(File(_profileImage!.path));
      uploadResult.fold(
        (failure) {
          if (mounted) {
            SnackbarUtils.showError(context, 'Failed to upload profile picture: ${failure.message}');
          }
        },
        (imageUrl) {
          setState(() {
            _profileImageUrl = imageUrl.startsWith('http')
                ? imageUrl
                : '${ApiEndpoints.baseUrl}$imageUrl';
            _profileImage = null;
          });
        },
      );
    }

    // Update profile data
    final authEntity = AuthEntity(
      authId: session.userId,
      fullName: _nameCtrl.text,
      email: session.email, 
      phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      profilePicture: _profileImageUrl,
    );

    final updateResult = await ref.read(updateUserUseCaseProvider)(
      UpdateUserUsecaseParams(user: authEntity),
    );

    if (mounted) {
      updateResult.fold(
        (failure) {
          SnackbarUtils.showError(context, 'Failed to update profile: ${failure.message}');
        },
        (updatedUser) async {
          // Update session with new data
          await userSession.saveSession(
            userId: updatedUser.authId ?? session.userId,
            email: updatedUser.email,
            fullName: updatedUser.fullName,
            role: session.role,
            phone: updatedUser.phone,
            profilePicture: updatedUser.profilePicture ?? _profileImageUrl,
          );
          SnackbarUtils.showSuccess(
            context,
            triggeredByShake
                ? 'Shake detected: profile saved'
                : 'Profile updated successfully',
          );
        },
      );
    }

    await _syncUserFromServer();
    _isSavingProfile = false;
  }

  @override
  void dispose() {
    _shakeSub?.cancel();
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Material(
        color: AppColors.background,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP BAR
                    Text(
                      "Edit Profile",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),

                    const SizedBox(height: 20),

                    // PROFILE PICTURE
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.secondaryDark,
                            backgroundImage: _profileImage != null
                                ? FileImage(File(_profileImage!.path))
                                : _profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : null,
                            child: (_profileImage == null && _profileImageUrl == null)
                                ? Text(
                                    _getInitials(_nameCtrl.text.isEmpty ? "User" : _nameCtrl.text),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.textPrimary,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _profileField("Full name", _nameCtrl),
                    _profileField("Username", _usernameCtrl, readOnly: true),
                    _profileField("Email address", _emailCtrl, readOnly: true),
                    _profileField("Role", _roleCtrl, readOnly: true),
                    _profileField("Phone number", _phoneCtrl),

                    const SizedBox(height: 10),

                    // SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text("Save Changes"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _profileField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: AppColors.cardBackground,
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        shadowColor: Colors.black54,
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.gold, width: 1.8),
            ),
            filled: true,
            fillColor: AppColors.inputFill,
          ),
        ),
      ),
    );
  }
}

