import 'package:flutter/material.dart';

class BlobImage extends StatelessWidget {
  final String imagePath;
  final double height;
  final int variant;

  const BlobImage({
    super.key,
    required this.imagePath,
    this.height = 320,
    this.variant = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipPath(
        clipper: SoftBlobClipper(variant),
        child: Container(
          height: height,
          width: height, // 👈 cuadrado controlado
          padding: const EdgeInsets.all(20), // 👈 espacio interno
          color: Colors.grey.shade100, // fondo suave
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain, // 👈 NO cover
          ),
        ),
      ),
    );
  }
}

class SoftBlobClipper extends CustomClipper<Path> {
  final int variant;

  SoftBlobClipper(this.variant);

  @override
  Path getClip(Size size) {
    final path = Path();

    switch (variant % 3) {
      case 0:
        path.moveTo(size.width * 0.2, 0);
        path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.4);
        path.quadraticBezierTo(
          size.width,
          size.height,
          size.width * 0.4,
          size.height,
        );
        path.quadraticBezierTo(0, size.height, 0, size.height * 0.3);
        path.quadraticBezierTo(0, 0, size.width * 0.2, 0);
        break;

      case 1:
        path.moveTo(size.width * 0.3, 0);
        path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.5);
        path.quadraticBezierTo(
          size.width,
          size.height,
          size.width * 0.5,
          size.height,
        );
        path.quadraticBezierTo(0, size.height, 0, size.height * 0.5);
        path.quadraticBezierTo(0, 0, size.width * 0.3, 0);
        break;

      default:
        path.moveTo(size.width * 0.25, 0);
        path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.6);
        path.quadraticBezierTo(
          size.width * 0.8,
          size.height,
          size.width * 0.3,
          size.height,
        );
        path.quadraticBezierTo(0, size.height * 0.8, 0, size.height * 0.4);
        path.quadraticBezierTo(0, 0, size.width * 0.25, 0);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
