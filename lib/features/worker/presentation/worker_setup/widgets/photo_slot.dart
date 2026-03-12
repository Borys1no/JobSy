import 'package:flutter/material.dart';
import 'dart:io';

class PhotoSlot extends StatelessWidget {
  final int index;
  final String? imagePath;
  final VoidCallback onTap;

  const PhotoSlot({
    super.key,
    required this.index,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(imagePath!), fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 30,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Foto ${index + 1}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    'Agregar',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
