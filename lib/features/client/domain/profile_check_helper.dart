import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/features/auth/data/profile_repository.dart';
import 'package:jobsy/features/client/presentation/pages/complete_client_profile_page.dart';

Future<bool> checkAndShowProfileCompletion({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final isComplete = await ref.read(isProfileCompleteProvider.future);

  if (!isComplete) {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Completa tu perfil'),
        content: const Text(
          'Para poder ver el perfil de los trabajadores, primero necesitas completar tu información personal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Completar perfil'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const CompleteClientProfilePage(),
        ),
      );
      return completed ?? false;
    }

    return false;
  }

  return true;
}