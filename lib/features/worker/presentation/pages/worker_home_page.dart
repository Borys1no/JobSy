import 'package:flutter/material.dart';

class WorkerHomePage extends StatelessWidget {
  const WorkerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Worker Home")),
      body: const Center(
        child: Text("Bienvenido Worker 🚀", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
