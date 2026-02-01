import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/core/services/storage/user_session_service.dart';
import 'package:nutrisphere_flutter/core/services/storage/token_service.dart';
import 'package:nutrisphere_flutter/core/utils/snackbar_utils.dart';
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
  
  
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _profileImage;
  String? _profileImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userSession = ref.read(userSessionServiceProvider);
    final session = await userSession.getSession();
    
    if (session != null) {
      setState(() {
        _nameCtrl.text = session.fullName;
        _emailCtrl.text = session.email;
        _usernameCtrl.text = _getRoleFromEmail(session.email);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getRoleFromEmail(String email) {
    // Extract username from email or return "User"
    if (email.contains('@')) {
      return email.split('@')[0];
    }
    return "User";
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

  Future<void> _saveProfile() async {
    // Upload profile picture if selected
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
            // Prepend base URL if the path is relative
            _profileImageUrl = imageUrl.startsWith('http') 
                ? imageUrl 
                : '${ApiEndpoints.baseUrl}$imageUrl';
            _profileImage = null; // Clear the local image after upload
          });
          if (mounted) {
            SnackbarUtils.showSuccess(context, 'Profile picture uploaded successfully');
          }
        },
      );
    }

    // TODO: Save other profile data (name, email, phone) to backend
    if (mounted) {
      SnackbarUtils.showSuccess(context, 'Profile updated successfully');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Material(
        color: Color(0xFFF5F5F5),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Material(
      color: const Color(0xFFF5F5F5),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Profile",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // PROFILE PICTURE
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF001F3F), // Navy blue
                      backgroundImage: _profileImage != null
                          ? FileImage(File(_profileImage!.path))
                          : _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : null,
                      child: (_profileImage == null && _profileImageUrl == null)
                          ? Text(
                              _getInitials(_nameCtrl.text.isEmpty ? "User" : _nameCtrl.text),
                              style: const TextStyle(
                                color: Colors.white,
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
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _editableField("Full name", _nameCtrl),
              _editableField("Username", _usernameCtrl),
              _editableField("Email address", _emailCtrl),
              _editableField("Phone number", _phoneCtrl),

              const SizedBox(height: 10),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text("Save Changes"),
                ),
              ),

              const Spacer(),

              // LOGOUT BUTTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Logout and clear session + token
                    final userSession = ref.read(userSessionServiceProvider);
                    final tokenService = ref.read(tokenServiceProvider);
                    
                    await userSession.logout();
                    await tokenService.removeToken();
                    
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "/login",
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Log Out"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}




