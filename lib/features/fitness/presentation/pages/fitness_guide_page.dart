import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrisphere_flutter/app/theme/theme_extentions.dart';
import 'package:nutrisphere_flutter/core/utils/snackbar_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class FitnessGuideScreen extends StatefulWidget {
  const FitnessGuideScreen({super.key});

  @override
  State<FitnessGuideScreen> createState() => _FitnessGuideScreenState();
}

class _FitnessGuideScreenState extends State<FitnessGuideScreen> {

  final List<XFile> _selectedMedia = [];
  final ImagePicker _imagePicker = ImagePicker();

  Future<bool> _userSangaPermissionMagu(Permission permission) async {
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

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text("Please provide Permission"),
        content: Text(
          "Please go to permission settings to use this features"
        ),
        actions: [
          TextButton(onPressed: (){}, child: Text('Cancel')),
          TextButton(onPressed: (){}, child: Text('Open Settings')),
        ],
      ),
    );
  }

  // camera code
  Future<void> _clickFromCamera() async{
    final hasPermission = await _userSangaPermissionMagu(Permission.camera);
    if(!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if(photo!=null){
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(photo);
      });
    }
  }

  // gallery code
Future<void> _pickFromGallery() async {
  try {
    final hasPermission =
        await _userSangaPermissionMagu(Permission.photos);

    if (!hasPermission) return;

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(image);
        _isMediaConfirmed = false; // reset confirmation
      });
    }
  } catch (e) {
    debugPrint('Gallery Error $e');

    if (mounted) {
      SnackbarUtils.showError(
        context,
        'Gallery could not be accessed. Please try again.',
      );
    }
  }
}


  // video code
  Future<void> _pickFromVideo() async {
    return Future.value(true);
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
                  onTap: _pickFromVideo,
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
      backgroundColor: const Color(0xFFF5F5F5),
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
                        "High quality fitness\n guidance below !",
                        style: textTheme.titleMedium,
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
                ),

                if (_selectedMedia.isNotEmpty) ...[
                  Column(
                    children: [
                      // Preview
                      Stack(
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: FileImage(File(_selectedMedia[0].path)),
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
                                  _selectedMedia.clear();
                                  _isMediaConfirmed = false;
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
                      if (!_isMediaConfirmed)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedMedia.clear();
                                });
                              },
                              child: const Text("Cancel"),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isMediaConfirmed = true;
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

                        // 👉 If admin has confirmed media, show it in feed
                        if (_isMediaConfirmed && _selectedMedia.isNotEmpty)
                          _imagePreviewCard(File(_selectedMedia[0].path))
                        else ...[
                          _imageCard(imagePath: 'assets/images/test.png'),
                          const SizedBox(height: 20),

                          _imageCard(imagePath: 'assets/images/dose.png'),
                          const SizedBox(height: 30),

                          _imageCard(imagePath: 'assets/images/plan.png'),
                          const SizedBox(height: 30),

                          _imageCard(imagePath: 'assets/images/pt.png'),
                          const SizedBox(height: 30),

                          _imageCard(imagePath: 'assets/images/dose.png'),
                        ],

                        const SizedBox(height: 120), // space for floating +
                      ],
                    ),
                  ),
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
}

Widget _imagePreviewCard(File file) {
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
    child: Image.file(
      file,
      fit: BoxFit.contain,
    ),
  );
}

