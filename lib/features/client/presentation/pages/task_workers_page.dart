import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/core/theme/app_theme.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final taskWorkersProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      taskName,
    ) async {
      final supabase = ref.read(supabaseProvider);

      print('Buscando trabajadores para: $taskName');

      // Obtener todos los worker_tasks y filtrar manualmente
      final allWorkerTasks = await supabase
          .from('worker_tasks')
          .select('tasks(name), worker_id');

      print('All worker tasks: $allWorkerTasks');

      // Filtrar manualmente por nombre del task
      final workersWithTask = allWorkerTasks
          .where((w) => w['tasks'] != null && w['tasks']['name'] == taskName)
          .toList();

      print('Workers with task (filtered): $workersWithTask');

      if (workersWithTask.isEmpty) {
        return [];
      }

      final List<Map<String, dynamic>> workersWithDetails = [];

      for (final w in workersWithTask) {
        final workerId = w['worker_id'] as String;

        final profiles = await supabase
            .from('profiles')
            .select('id, first_name, last_name, avatar_url')
            .eq('id', workerId)
            .limit(1);

        if (profiles.isEmpty) continue;
        final worker = profiles.first;

        final workerProfile = await supabase
            .from('worker_profiles')
            .select('bio')
            .eq('user_id', workerId)
            .maybeSingle();

        final services = await supabase
            .from('worker_services')
            .select('services(name)')
            .eq('worker_id', workerId)
            .eq('service_type', 'primary');

        String profession = 'Trabajador';
        if (services.isNotEmpty) {
          final serviceName = services.first['services']?['name'];
          if (serviceName != null) {
            profession = serviceName as String;
          }
        }

        final reviews = await supabase
            .from('reviews')
            .select('rating')
            .eq('worker_id', workerId);

        double rating = 0;
        if (reviews.isNotEmpty) {
          final total = reviews.fold<int>(
            0,
            (sum, r) => sum + ((r['rating'] as num?)?.toInt() ?? 0),
          );
          rating = total / reviews.length;
        }

        workersWithDetails.add({
          'id': workerId,
          'name': '${worker['first_name'] ?? ''} ${worker['last_name'] ?? ''}'
              .trim(),
          'avatarUrl': worker['avatar_url'],
          'bio': workerProfile?['bio'] ?? '',
          'profession': profession,
          'rating': rating,
          'reviewCount': reviews.length,
        });
      }

      return workersWithDetails;
    });

class TaskWorkersPage extends ConsumerWidget {
  final String taskName;

  const TaskWorkersPage({super.key, required this.taskName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workersAsync = ref.watch(taskWorkersProvider(taskName));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.clientPrimary,
        foregroundColor: Colors.white,
        title: Text(
          taskName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: workersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: subtitleColor),
              const SizedBox(height: 16),
              Text('Error: $error', style: TextStyle(color: subtitleColor)),
            ],
          ),
        ),
        data: (workers) {
          if (workers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: subtitleColor),
                  const SizedBox(height: 16),
                  Text(
                    'No hay trabajadores para este servicio',
                    style: TextStyle(
                      fontSize: 18,
                      color: subtitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 180,
                            child: worker['avatarUrl'] != null
                                ? Image.network(
                                    worker['avatarUrl'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        Container(
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFB800),
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  (worker['rating'] as double).toStringAsFixed(
                                    1,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
                            child: Text(
                              worker['name'] as String,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: const Color(0xFFFFB800),
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${(worker['rating'] as double).toStringAsFixed(1)} (${worker['reviewCount']} reseñas)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.clientPrimary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              worker['profession'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            (worker['bio'] as String).isNotEmpty
                                ? worker['bio'] as String
                                : 'Sin descripción disponible.',
                            style: TextStyle(
                              fontSize: 14,
                              color: subtitleColor,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.clientPrimary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Ver perfil',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
