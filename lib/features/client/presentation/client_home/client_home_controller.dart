import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import 'package:jobsy/features/client/domain/client_home_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'client_home_controller.g.dart';

@riverpod
class ClientHomeController extends _$ClientHomeController {
  SupabaseClient get _supabase => ref.read(supabaseProvider);

  @override
  ClientHomeState build() {
    Future.microtask(() => loadClientData());
    return ClientHomeState.initial();
  }

  Future<void> loadClientData() async {
    try {
      state = state.copyWith(isLoading: true);

      // Obtener todos los workers con su perfil
      final workersData = await _supabase
          .from('profiles')
          .select('''
            id,
            first_name,
            last_name,
            avatar_url
          ''')
          .eq('role', 'worker');

      List<FeaturedWorker> workers = [];
      if (workersData.isNotEmpty) {
        // Calcular rating dinámicamente desde tabla reviews
        final featuredWorkers = <FeaturedWorker>[];

        for (final w in workersData) {
          final workerId = w['id'] as String;

          // Obtener bio del worker_profiles
          final workerProfileData = await _supabase
              .from('worker_profiles')
              .select('bio, user_id')
              .eq('user_id', workerId)
              .maybeSingle();

          if (workerProfileData == null) {
            print('Worker $workerId sin worker_profiles');
            continue;
          }

          // Obtener la profesión desde worker_services -> services
          String profession = 'Trabajador';

          final services = await _supabase
              .from('worker_services')
              .select('services(name)')
              .eq('worker_id', workerId)
              .eq('service_type', 'primary');

          if (services.isNotEmpty) {
            profession =
                services.first['services']?['name'] as String? ?? 'Trabajador';
          }

          //Servicios adicionales - servicios precargados
          final additionalServicesData = await _supabase
              .from('worker_tasks')
              .select('tasks(name)')
              .eq('worker_id', workerId);

          final precargados = additionalServicesData
              .map((s) => s['tasks']?['name'] as String?)
              .where((s) => s != null)
              .cast<String>()
              .toList();

          //Servicios adicionales - servicios personalizados
          final customServicesData = await _supabase
              .from('custom_services')
              .select('name')
              .eq('worker_id', workerId);

          final personalizados = customServicesData
              .map((s) => s['name'] as String?)
              .where((s) => s != null)
              .cast<String>()
              .toList();

          final servicesList = [...precargados, ...personalizados];

          // Buscar reseñas del worker y calcular rating promedio
          final reviews = await _supabase
              .from('reviews')
              .select('rating')
              .eq('worker_id', workerId);

          final reviewCount = reviews.length;
          double rating = 0;
          if (reviewCount > 0) {
            final totalRating = reviews.fold<int>(
              0,
              (sum, r) => sum + ((r['rating'] as num?)?.toInt() ?? 0),
            );
            rating = totalRating / reviewCount;
          }

          print(
            'Worker: ${w['first_name']}, rating: $rating, reviews: $reviewCount',
          );
          print('  precargados: $precargados, personalizados: $personalizados');

          // Agregar workers con rating >= 4.5
          if (rating >= 4.5) {
            featuredWorkers.add(
              FeaturedWorker(
                id: workerId,
                name: '${w['first_name'] ?? ''} ${w['last_name'] ?? ''}'.trim(),
                profession: profession,
                avatarUrl: w['avatar_url'] as String?,
                description: workerProfileData['bio'] as String? ?? '',
                rating: rating,
                reviewCount: reviewCount,
                additionalServices: servicesList,
              ),
            );
          }
        }

        workers = featuredWorkers.isEmpty
            ? _getSampleWorkers()
            : featuredWorkers;
      } else {
        workers = _getSampleWorkers();
      }

      // Cargar categorías desde BD (si existe la tabla)
      List<Map<String, dynamic>> categoriesData;
      try {
        categoriesData = await _supabase
            .from('categories')
            .select('id, name, description, icon')
            .order('name');
        print('Categories data: $categoriesData');
      } catch (e) {
        print('Error fetching categories: $e');
        categoriesData = [];
      }

      final cats = categoriesData.isEmpty
          ? _getSampleCategories()
          : categoriesData
                .map(
                  (c) => Category(
                    id: c['id'].toString(),
                    name: c['name'] as String? ?? 'Categoría',
                    description: c['description'] as String? ?? '',
                    icon: c['icon'] as String? ?? 'build',
                    workerCount: 0,
                  ),
                )
                .toList();

      // Cargar trabajos populares desde tabla tasks
      List<Map<String, dynamic>> tasksData;
      try {
        tasksData = await _supabase
            .from('tasks')
            .select('id, name')
            .eq('is_popular', true)
            .order('name');
        print('Tasks data: $tasksData');
      } catch (e) {
        print('Error fetching tasks: $e');
        tasksData = [];
      }

      final popularJobs = tasksData.isEmpty
          ? _getSamplePopularJobs()
          : tasksData.map((t) {
              return PopularJob(
                id: t['id'].toString(),
                name: t['name'] as String? ?? 'Servicio',
                icon: 'handyman',
                requestCount: 0,
              );
            }).toList();

      state = state.copyWith(
        isLoading: false,
        featuredWorkers: workers,
        categories: cats,
        popularJobs: popularJobs.isEmpty
            ? _getSamplePopularJobs()
            : popularJobs,
      );
    } catch (e) {
      print('Error cargando datos client: $e');
      state = state.copyWith(
        isLoading: false,
        featuredWorkers: _getSampleWorkers(),
        categories: _getSampleCategories(),
        popularJobs: _getSamplePopularJobs(),
      );
    }
  }

  List<FeaturedWorker> _getSampleWorkers() {
    return [
      FeaturedWorker(
        id: '1',
        name: 'Carlos Gómez',
        profession: 'Electricista',
        avatarUrl: null,
        description:
            'Técnico electricista con 10 años de experiencia en instalaciones residenciales y comerciales.',
        rating: 4.8,
        reviewCount: 24,
        additionalServices: [
          'Instalación de ventiladores',
          'Reparación de cortocircuitos',
          'Cambio de breakers',
        ],
      ),
      FeaturedWorker(
        id: '2',
        name: 'María López',
        profession: 'Limpiadora',
        avatarUrl: null,
        description:
            'Limpieza profunda y mantenimiento para hogares y oficinas.',
        rating: 4.9,
        reviewCount: 38,
        additionalServices: ['Limpieza de ventanas', 'Lavandería', 'Planchado'],
      ),
      FeaturedWorker(
        id: '3',
        name: 'Pedro Ruiz',
        profession: 'Plomero',
        avatarUrl: null,
        description: 'Reparaciones de plomería, instalación de heater y más.',
        rating: 4.7,
        reviewCount: 18,
        additionalServices: [
          'Destape de drenajes',
          'Instalación de regaderas',
          'Reparación de fugas',
        ],
      ),
    ];
  }

  List<Category> _getSampleCategories() {
    return [
      Category(
        id: '1',
        name: 'Limpieza',
        description: 'Servicios de limpieza para tu hogar',
        icon: 'cleaning_services',
        workerCount: 12,
      ),
      Category(
        id: '2',
        name: 'Electricidad',
        description: 'Reparaciones e instalaciones eléctricas',
        icon: 'electrical_services',
        workerCount: 8,
      ),
      Category(
        id: '3',
        name: 'Plomería',
        description: 'Reparación de tuberías y más',
        icon: 'plumbing',
        workerCount: 6,
      ),
      Category(
        id: '4',
        name: 'Pintura',
        description: 'Pintura residential y comercial',
        icon: 'format_paint',
        workerCount: 5,
      ),
    ];
  }

  List<PopularJob> _getSamplePopularJobs() {
    return [
      PopularJob(
        id: '1',
        name: 'Limpieza general',
        icon: 'cleaning_services',
        requestCount: 45,
      ),
      PopularJob(
        id: '2',
        name: 'Instalación eléctrica',
        icon: 'electrical_services',
        requestCount: 32,
      ),
      PopularJob(
        id: '3',
        name: 'Reparación de tuberías',
        icon: 'plumbing',
        requestCount: 28,
      ),
      PopularJob(
        id: '4',
        name: 'Pintura de paredes',
        icon: 'format_paint',
        requestCount: 20,
      ),
    ];
  }
}
