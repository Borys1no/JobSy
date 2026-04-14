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

      // Verificar si hay reseñas, si no hay, insertar de ejemplo
      await _ensureSampleReviews();

      // Obtener todos los workers con sus perfiles
      final workersData = await _supabase
          .from('profiles')
          .select('''
            id,
            first_name,
            last_name,
            avatar_url,
            worker_profiles(
              profession,
              bio
            )
          ''')
          .eq('role', 'worker')
          .not('worker_profiles', 'is', null);

      // Calcular rating dinámicamente desde tabla reviews
      final featuredWorkers = <FeaturedWorker>[];

      for (final w in workersData) {
        final workerId = w['id'] as String;
        final wp = w['worker_profiles'] as Map<String, dynamic>? ?? {};

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
            (sum, r) => sum + (r['rating'] as int),
          );
          rating = totalRating / reviewCount;
        }

        // Solo agregar workers con rating >= 4.5
        if (rating >= 4.5) {
          featuredWorkers.add(
            FeaturedWorker(
              id: workerId,
              name: '${w['first_name'] ?? ''} ${w['last_name'] ?? ''}'.trim(),
              profession: wp['profession'] as String? ?? '',
              avatarUrl: w['avatar_url'] as String?,
              description: wp['bio'] as String? ?? '',
              rating: rating,
              reviewCount: reviewCount,
            ),
          );
        }
      }

      // Si no hay workers en BD con rating >= 4.5, usar datos de ejemplo
      final workers = featuredWorkers.isEmpty
          ? _getSampleWorkers()
          : featuredWorkers;

      // Categorías (de la tabla services)
      final services = await _supabase
          .from('services')
          .select('id, name, description, icon')
          .eq('is_category', true)
          .order('name');

      final categories = services
          .map(
            (s) => Category(
              id: s['id'] as String,
              name: s['name'] as String,
              description: s['description'] as String? ?? '',
              icon: s['icon'] as String? ?? 'build',
              workerCount: 0,
            ),
          )
          .toList();

      final cats = categories.isEmpty ? _getSampleCategories() : categories;

      // Trabajos populares (de tasks con is_popular)
      final tasks = await _supabase
          .from('tasks')
          .select('id, name, icon, request_count')
          .eq('is_popular', true)
          .order('request_count', ascending: false)
          .limit(4);

      final popularJobs = tasks
          .map(
            (t) => PopularJob(
              id: t['id'] as String,
              name: t['name'] as String,
              icon: t['icon'] as String? ?? 'handyman',
              requestCount: (t['request_count'] as int?) ?? 0,
            ),
          )
          .toList();

      final jobs = popularJobs.isEmpty ? _getSamplePopularJobs() : popularJobs;

      state = state.copyWith(
        isLoading: false,
        featuredWorkers: workers,
        categories: cats,
        popularJobs: jobs,
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

  Future<void> _ensureSampleReviews() async {
    // Verificar si ya hay reseñas
    final existingReviews = await _supabase.from('reviews').select();
    if (existingReviews.isNotEmpty) return;

    // Obtener workers existentes
    final workers = await _supabase
        .from('profiles')
        .select('id')
        .eq('role', 'worker')
        .not('worker_profiles', 'is', null);

    // Obtener clients existentes
    final clients = await _supabase
        .from('profiles')
        .select('id')
        .eq('role', 'client')
        .limit(3);

    if (workers.isEmpty || clients.isEmpty) return;

    final workerId = workers.first['id'] as String;
    final clientIds = clients.map((c) => c['id'] as String).toList();

    // Insertar reseñas de ejemplo para el worker
    // 6 reseñas de 5 y 1 de 4 = promedio 4.86 >= 4.5
    final sampleReviews = [
      {
        'worker_id': workerId,
        'client_id': clientIds[0],
        'rating': 5,
        'comment': 'Excelente servicio, muy profesional y puntual.',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      },
      {
        'worker_id': workerId,
        'client_id': clientIds[0],
        'rating': 5,
        'comment': 'Muy buen trabajo, lo recomiendo.',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
      },
      {
        'worker_id': workerId,
        'client_id': clientIds[0],
        'rating': 5,
        'comment': 'Buen servicio, cumple con lo pactado.',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
      },
      {
        'worker_id': workerId,
        'client_id': clientIds[0],
        'rating': 5,
        'comment': 'Excelente, muy satisfecho con el trabajo.',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 7))
            .toIso8601String(),
      },
      {
        'worker_id': workerId,
        'client_id': clientIds[0],
        'rating': 4,
        'comment': 'Regular, podrían mejorar.',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 10))
            .toIso8601String(),
      },
      {
        'worker_id': workerId,
        'client_id': clientIds[0],
        'rating': 5,
        'comment': 'Muy profesional y atendido.',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 14))
            .toIso8601String(),
      },
      {
        'worker_id': workerId,
        'client_id': clientIds[0],
        'rating': 5,
        'comment': 'Perfecto, lo contrataría de nuevo.',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 20))
            .toIso8601String(),
      },
    ];

    for (final review in sampleReviews) {
      try {
        await _supabase.from('reviews').insert(review);
      } catch (e) {
        // Ignorar errores de duplicados
      }
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
      ),
      FeaturedWorker(
        id: '3',
        name: 'Pedro Ruiz',
        profession: 'Plomero',
        avatarUrl: null,
        description: 'Reparaciones de plomería, instalación de heater y más.',
        rating: 4.7,
        reviewCount: 18,
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
