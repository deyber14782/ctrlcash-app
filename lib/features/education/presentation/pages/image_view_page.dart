import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ImageViewPage extends StatelessWidget {
  final String imageUrl;
  const ImageViewPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined, color: AppColors.textSecondary, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}