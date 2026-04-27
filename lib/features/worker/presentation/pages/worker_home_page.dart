import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/core/theme/app_theme.dart';
import 'package:jobsy/features/worker/domain/worker_home_state.dart';
import 'package:jobsy/features/worker/presentation/worker_home/worker_home_controller.dart';
import 'package:jobsy/features/worker/presentation/pages/worker_reviews_page.dart';
import 'package:jobsy/features/notifications/presentation/notifications_page.dart';
import 'package:jobsy/features/notifications/presentation/notifications_controller.dart';
import 'package:jobsy/features/worker/presentation/pages/worker_profile_page.dart';
import 'package:jobsy/features/worker/presentation/chat/worker_chats_page.dart';
import 'package:jobsy/features/worker/presentation/chat/worker_chat_controller.dart';

class WorkerHomePage extends ConsumerStatefulWidget {
  const WorkerHomePage({super.key});

  @override
  ConsumerState<WorkerHomePage> createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends ConsumerState<WorkerHomePage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workerHomeControllerProvider);
    final controller = ref.read(workerHomeControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDark ? const Color(0xFF3C3C3C) : Colors.grey[200]!;

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 60, color: AppTheme.primary),
              const SizedBox(height: 16),
              Text(
                'JobSy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text(
          'Hola, ${state.name ?? 'Trabajador'}',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final notifications = ref.watch(notificationsControllerProvider).notifications;
              final unreadCount = notifications.where((n) => !n.isRead).length;
              
              return Badge(
                label: Text('$unreadCount'),
                isLabelVisible: unreadCount > 0,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.notifications_outlined, color: textColor),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(context, state, controller),
            _buildSectionTitle('Descripción'),
            _buildDescriptionSection(state),
            _buildSectionTitle('Habilidades'),
            _buildSkillsSection(state, controller),
            _buildSectionTitle('Trabajos en marcha'),
            _buildActiveJobsSection(state),
            _buildSectionTitle('Mis trabajos'),
            _buildWorkPhotosSection(context, state, controller),
            _buildStatsSection(state),
            _buildSectionTitle('Disponibilidad'),
            _buildAvailabilitySection(context, state, controller),
            _buildSectionTitle('Reseñas'),
            _buildReviewsSection(context, state),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  static const List<String> _dayNames = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

  Widget _buildProfileSection(
    BuildContext context,
    WorkerHomeState state,
    WorkerHomeController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      padding: const EdgeInsets.all(16),
      color: cardColor,
      child: Row(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: state.avatarUrl != null
                    ? () => _showFullscreenImage(context, state.avatarUrl!)
                    : null,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: isDark
                      ? const Color(0xFF3C3C3C)
                      : Colors.grey[200],
                  backgroundImage: state.avatarPath != null
                      ? FileImage(File(state.avatarPath!)) as ImageProvider
                      : state.avatarUrl != null
                      ? NetworkImage(state.avatarUrl!) as ImageProvider
                      : null,
                  child: state.avatarPath == null && state.avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 45,
                          color: isDark ? Colors.grey[600] : Colors.grey,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: controller.pickAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.name ?? '',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.profession ?? '',
                  style: TextStyle(fontSize: 14, color: subtitleColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      state.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${state.reviewCount} reseñas)',
                      style: TextStyle(color: subtitleColor, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(WorkerHomeState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDark ? const Color(0xFF3C3C3C) : Colors.grey[200]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        state.description ?? '',
        style: TextStyle(fontSize: 14, color: subtitleColor, height: 1.5),
      ),
    );
  }

  Widget _buildSkillsSection(
    WorkerHomeState state,
    WorkerHomeController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final borderColor = isDark ? const Color(0xFF3C3C3C) : Colors.grey[200]!;
    final chipBgColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[50]!;
    final chipBlueBgColor = isDark ? const Color(0xFF1A3A5C) : Colors.blue[50]!;
    final chipBorderColor = isDark
        ? const Color(0xFF3C3C3C)
        : Colors.grey[200]!;
    final addChipBgColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!;
    final addChipBorderColor = isDark
        ? const Color(0xFF3C3C3C)
        : Colors.grey[300]!;

    final allJobNames = [
      ...state.additionalJobs.map((j) => j.name),
      ...state.customServices.map((j) => j.name),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.additionalJobs.isNotEmpty ||
              state.customServices.isNotEmpty) ...[
            const Text(
              'Tus trabajos adicionales:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            ...state.additionalJobs.asMap().entries.map((entry) {
              final index = entry.key;
              final job = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: chipBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: chipBorderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (job.basePrice != null)
                            Text(
                              'Desde \$${job.basePrice!.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => controller.removeTask(index, job.name),
                    ),
                  ],
                ),
              );
            }),
            ...state.customServices.asMap().entries.map((entry) {
              final index = entry.key;
              final job = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: chipBlueBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (job.basePrice != null)
                            Text(
                              'Desde \$${job.basePrice!.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () =>
                          controller.removeCustomService(index, job.name),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
          if (state.availableTasks.isNotEmpty) ...[
            Text(
              'Agregar trabajo adicional',
              style: TextStyle(
                fontSize: 12,
                color: subtitleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.availableTasks
                  .where((t) => !allJobNames.contains(t.name))
                  .map((task) {
                    return GestureDetector(
                      onTap: () => _showAddPriceDialog(
                        context,
                        controller,
                        task.id,
                        task.name,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: addChipBgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: addChipBorderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 16, color: subtitleColor),
                            const SizedBox(width: 4),
                            Text(
                              task.name,
                              style: TextStyle(color: subtitleColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showCustomServiceDialog(context, controller),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: chipBlueBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Agregar otro servicio personalizado',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddPriceDialog(
    BuildContext context,
    WorkerHomeController controller,
    String taskId,
    String taskName,
  ) {
    final priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar $taskName'),
        content: TextField(
          controller: priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Precio base (\$)',
            hintText: 'Ej: 25',
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text);
              controller.addTask(taskId, taskName, price);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$taskName agregado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showCustomServiceDialog(
    BuildContext context,
    WorkerHomeController controller,
  ) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo servicio personalizado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del servicio',
                hintText: 'Ej: Cerrajería',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Precio base (\$)',
                hintText: 'Ej: 30',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text);
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa el nombre del servicio'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              await controller.addCustomService(name, price);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name agregado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showFullscreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveJobsSection(WorkerHomeState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final chipBgColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!;
    final borderColor = isDark ? const Color(0xFF3C3C3C) : Colors.grey[200]!;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    if (state.activeJobs.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: chipBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No tienes trabajos en marcha',
            style: TextStyle(color: subtitleColor),
          ),
        ),
      );
    }

    return Column(
      children: state.activeJobs.map((job) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.work_outline, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.service,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.clientName,
                      style: TextStyle(color: subtitleColor, fontSize: 13),
                    ),
                    Text(
                      job.address,
                      style: TextStyle(color: subtitleColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF3C2A10)
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDate(job.date),
                      style: TextStyle(
                        color: isDark
                            ? Colors.orange[300]!
                            : Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Mañana';
    return '${date.day}/${date.month}';
  }

  Widget _buildWorkPhotosSection(
    BuildContext context,
    WorkerHomeState state,
    WorkerHomeController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBgColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]!;
    final chipBorderColor = isDark
        ? const Color(0xFF3C3C3C)
        : Colors.grey[300]!;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    if (state.workPhotos.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 150,
        decoration: BoxDecoration(
          color: chipBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: GestureDetector(
            onTap: controller.addWorkPhoto,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, size: 40, color: subtitleColor),
                const SizedBox(height: 8),
                Text(
                  'Agrega fotos de tus trabajos',
                  style: TextStyle(color: subtitleColor),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: state.workPhotos.length,
            controller: PageController(viewportFraction: 0.85),
            itemBuilder: (context, index) {
              final photo = state.workPhotos[index];
              return GestureDetector(
                onTap: () => _showFullscreenImage(context, photo.url),
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(photo.url),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPhotoButton(
                              Icons.edit,
                              () =>
                                  _showPhotoOptions(context, index, controller),
                            ),
                            const SizedBox(width: 4),
                            _buildPhotoButton(
                              Icons.delete,
                              () => _confirmDeletePhoto(
                                context,
                                index,
                                controller,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(state.workPhotos.length, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: chipBorderColor,
              ),
            );
          }),
        ),
        if (state.workPhotos.length < 3) ...[
          const SizedBox(height: 12),
          IconButton(
            onPressed: controller.addWorkPhoto,
            icon: const Icon(Icons.add_a_photo),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  void _showPhotoOptions(
    BuildContext context,
    int index,
    WorkerHomeController controller,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Editar foto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Cambiar foto'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.deletePhoto(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePhoto(
    BuildContext context,
    int index,
    WorkerHomeController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text('¿Estás seguro de eliminar esta foto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deletePhoto(index);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(WorkerHomeState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Text(
            '${state.completedJobs} trabajos realizados',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(
    BuildContext context,
    WorkerHomeState state,
    WorkerHomeController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3C3C3C) : Colors.grey[200]!;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final chipBgColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[200]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Días disponibles',
            style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isAvailable = state.availableDays[index];
              return GestureDetector(
                onTap: () => controller.toggleDay(index),
                child: Column(
                  children: [
                    Text(
                      _dayNames[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: isAvailable ? AppTheme.primary : subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isAvailable ? AppTheme.primary : chipBgColor,
                      ),
                      child: Icon(
                        isAvailable ? Icons.check : Icons.close,
                        color: isAvailable ? Colors.white : subtitleColor,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Guardar cambios'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, WorkerHomeState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3C3C3C) : Colors.grey[200]!;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final chipBgColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[200]!;
    final displayCount = state.reviews.length > 3 ? 3 : state.reviews.length;

    if (displayCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: displayCount,
            controller: PageController(viewportFraction: 0.9),
            itemBuilder: (context, index) {
              final review = state.reviews[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: chipBgColor,
                          child: Text(
                            review.clientName.isNotEmpty
                                ? review.clientName[0]
                                : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.clientName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < review.rating.floor()
                                        ? Icons.star
                                        : (i < review.rating
                                              ? Icons.star_half
                                              : Icons.star_border),
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        review.comment,
                        style: TextStyle(color: subtitleColor, height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.service,
                      style: TextStyle(color: subtitleColor, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (state.reviews.length > 3) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkerReviewsPage(),
                ),
              );
            },
            child: const Text('Ver todas las reseñas'),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                Icons.home,
                'Inicio',
                true,
                () {},
                textColor,
                subColor,
              ),
              _buildNavItem(
                Icons.search,
                'Buscar',
                false,
                () {},
                textColor,
                subColor,
              ),
              Consumer(
                builder: (context, ref, _) {
                  final hasUnread = ref.watch(workerChatControllerProvider.select(
                    (s) => s.conversations.any((c) => c.hasUnreadMessages),
                  ));

                  return Stack(
                    children: [
                      _buildNavItem(
                        Icons.chat_bubble_outline,
                        'Chat',
                        false,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkerChatsPage(),
                            ),
                          );
                        },
                        textColor,
                        subColor,
                      ),
                      if (hasUnread)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              _buildNavItem(
                Icons.person_outline,
                'Perfil',
                false,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkerProfilePage(),
                    ),
                  );
                },
                textColor,
                subColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
    Color textColor,
    Color subColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.primary : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.primary : Colors.grey,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
