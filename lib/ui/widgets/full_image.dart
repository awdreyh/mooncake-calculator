import 'dart:io';
import 'package:flutter/material.dart';

class FullImageView extends StatelessWidget {
  static const _placeholderImage = 'assets/images/types/placeholder.jpg';

  final String imagePath;
  const FullImageView({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final isAsset = imagePath.startsWith('assets/');
    final image = isAsset
        ? Image.asset(
            imagePath,
            errorBuilder: (_, _, _) =>
                Image.asset(_placeholderImage, fit: BoxFit.contain),
          )
        : Image.file(
            File(imagePath),
            errorBuilder: (_, _, _) =>
                Image.asset(_placeholderImage, fit: BoxFit.contain),
          );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(minScale: 0.5, maxScale: 4.0, child: image),
      ),
    );
  }
}
