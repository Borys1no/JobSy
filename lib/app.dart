import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JobSyApp extends StatelessWidget {
  const JobSyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JobSy',
        home: Scaffold(
          body: Center(
            child: Text('JobSy MVP', style: TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }
}
