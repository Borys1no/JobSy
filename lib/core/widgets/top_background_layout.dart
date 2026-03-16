import 'package:flutter/material.dart';
import 'package:jobsy/core/constants/app_constants.dart';

class TopBackgroundLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final double heightFactor;

  const TopBackgroundLayout({
    super.key,
    required this.child,
    required this.title,
    this.heightFactor = 0.30,
  });
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/worker/top_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.only(top: 100), child: child),
        ],
      ),
    );
  }
}
