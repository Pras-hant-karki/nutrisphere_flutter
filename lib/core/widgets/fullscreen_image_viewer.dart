import 'package:flutter/material.dart';

class FullScreenImageViewer {
  const FullScreenImageViewer._();

  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    String? title,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _FullScreenImagePage(
          imageUrl: imageUrl,
          title: title,
        ),
      ),
    );
  }
}

class _FullScreenImagePage extends StatelessWidget {
  const _FullScreenImagePage({
    required this.imageUrl,
    this.title,
  });

  final String imageUrl;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title ?? 'Image'),
      ),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: Center(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.white70,
                size: 56,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
