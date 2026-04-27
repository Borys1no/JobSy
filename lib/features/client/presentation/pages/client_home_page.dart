import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/core/theme/app_theme.dart';
import 'package:jobsy/features/client/domain/client_home_state.dart';
import 'package:jobsy/features/client/presentation/client_home/client_home_controller.dart';
import 'package:jobsy/features/client/presentation/pages/all_workers_page.dart';
import 'package:jobsy/features/client/presentation/pages/category_workers_page.dart';
import 'package:jobsy/features/client/presentation/pages/featured_workers_page.dart';
import 'package:jobsy/features/client/presentation/pages/task_workers_page.dart';
import 'package:jobsy/features/notifications/presentation/notifications_page.dart';
import 'package:jobsy/features/notifications/presentation/notifications_controller.dart';
import 'package:jobsy/features/client/presentation/chat/chats_page.dart';
import 'package:jobsy/features/client/presentation/chat/chat_controller.dart';
import 'package:jobsy/features/client/presentation/pages/client_profile_page.dart';

class ClientHomePage extends ConsumerStatefulWidget {
  const ClientHomePage({super.key});

  @override
  ConsumerState<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends ConsumerState<ClientHomePage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientHomeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 60, color: AppTheme.clientPrimary),
              const SizedBox(height: 16),
              Text(
                'JobSy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.clientPrimary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.clientPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFeaturedWorkersSection(
              state,
              cardColor,
              textColor,
              subtitleColor,
            ),
            _buildCategoriesSection(state, cardColor, textColor, subtitleColor),
            _buildPopularJobsSection(
              state,
              cardColor,
              textColor,
              subtitleColor,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      color: AppTheme.clientPrimary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClientProfilePage(),
                ),
              );
            },
            child: Row(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final profileAsync = ref.watch(clientProfileProvider);
                    
                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      backgroundImage: profileAsync.valueOrNull?['avatar_url'] != null
                          ? NetworkImage(profileAsync.valueOrNull!['avatar_url'] as String)
                          : null,
                      child: profileAsync.valueOrNull?['avatar_url'] == null
                          ? const Icon(Icons.person, color: AppTheme.clientPrimary)
                          : null,
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'JobSy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
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
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.clientPrimary,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                'Buscar servicios o trabajadores...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedWorkersSection(
    ClientHomeState state,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trabajadores destacados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FeaturedWorkersPage(),
                    ),
                  );
                },
                child: const Text(
                  'Ver todos',
                  style: TextStyle(color: AppTheme.clientPrimary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 340,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: state.featuredWorkers.length,
            itemBuilder: (context, index) {
              final worker = state.featuredWorkers[index];
              return Container(
                width: 260,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
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
                                  width: 260,
                                  height: 150,
                                  child: worker.avatarUrl != null
                                      ? Image.network(
                                          worker.avatarUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    color: Colors.grey[300],
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 50,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            worker.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            worker.profession,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Color(0xFFFFB800),
                                            size: 14,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            worker.rating.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (worker.additionalServices.isNotEmpty) ...[
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: worker.additionalServices
                                        .take(3)
                                        .map((service) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.clientPrimary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              service,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppTheme.clientPrimary,
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                Text(
                                  worker.description,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subtitleColor,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.clientPrimary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Ver perfil',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(
    ClientHomeState state,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'Categorías',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              final icon = _getCategoryIcon(category.name);
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CategoryWorkersPage(categoryName: category.name),
                    ),
                  );
                },
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.clientPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: AppTheme.clientPrimary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.description,
                        style: TextStyle(fontSize: 12, color: subtitleColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularJobsSection(
    ClientHomeState state,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trabajos populares',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllWorkersPage(),
                    ),
                  );
                },
                child: Text(
                  'Ver todos',
                  style: TextStyle(color: AppTheme.clientPrimary),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: state.popularJobs.length > 4
                ? 4
                : state.popularJobs.length,
            itemBuilder: (context, index) {
              final job = state.popularJobs[index];
              final icon = _getJobIcon(job.name);
              return Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskWorkersPage(taskName: job.name),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.clientPrimary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              icon,
                              color: AppTheme.clientPrimary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            job.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${job.requestCount > 0 ? job.requestCount : 12} solicitudes',
                            style: TextStyle(
                              fontSize: 11,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
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
                AppTheme.clientPrimary,
                subColor,
              ),
              _buildNavItem(
                Icons.search,
                'Buscar',
                false,
                () {},
                AppTheme.clientPrimary,
                subColor,
              ),
              Consumer(
                builder: (context, ref, _) {
                  final hasUnread = ref.watch(chatControllerProvider.select(
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
                              builder: (context) => ChatsPage(),
                            ),
                          );
                        },
                        AppTheme.clientPrimary,
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
                      builder: (context) => const ClientProfilePage(),
                    ),
                  );
                },
                AppTheme.clientPrimary,
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
    Color activeColor,
    Color inactiveColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? activeColor : inactiveColor, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'limpieza':
        return Icons.cleaning_services;
      case 'electricidad':
        return Icons.electrical_services;
      case 'plomería':
        return Icons.plumbing;
      case 'pintura':
        return Icons.format_paint;
      default:
        return Icons.build;
    }
  }

  IconData _getJobIcon(String jobName) {
    final name = jobName.toLowerCase();
    if (name.contains('limpieza') || name.contains('clean')) {
      return Icons.cleaning_services;
    } else if (name.contains('electric') ||
        name.contains('luz') ||
        name.contains('cable')) {
      return Icons.electrical_services;
    } else if (name.contains('plom') ||
        name.contains('agua') ||
        name.contains('dren')) {
      return Icons.plumbing;
    } else if (name.contains('pint') || name.contains('painted')) {
      return Icons.format_paint;
    } else if (name.contains('jardin') ||
        name.contains('grass') ||
        name.contains('plants')) {
      return Icons.yard;
    } else if (name.contains('carpinter') ||
        name.contains('wood') ||
        name.contains('muebl')) {
      return Icons.carpenter;
    } else if (name.contains('tech') || name.contains('techo')) {
      return Icons.roofing;
    } else if (name.contains('mudanza') || name.contains('move')) {
      return Icons.local_shipping;
    }
    return Icons.handyman;
  }
}
