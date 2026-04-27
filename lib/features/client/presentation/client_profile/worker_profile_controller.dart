import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jobsy/core/config/supabase_client.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import 'package:jobsy/features/client/domain/worker_profile_state.dart';
import 'package:jobsy/features/worker/domain/review.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'worker_profile_controller.g.dart';

@riverpod
class WorkerProfileController extends _$WorkerProfileController {
  SupabaseClient get _supabase => ref.read(supabaseProvider);

  @override
  WorkerProfileState build(String workerId) {
    Future.microtask(() => loadWorkerProfile(workerId));
    return WorkerProfileState.initial(workerId);
  }

  Future<void> loadWorkerProfile(String workerId) async {
    try {
      state = state.copyWith(isLoading: true, hasError: false);

      final profileData = await _supabase
          .from('profiles')
          .select('first_name, last_name, avatar_url')
          .eq('id', workerId)
          .maybeSingle();

      if (profileData == null) {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: 'Trabajador no encontrado',
        );
        return;
      }

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

      final workerProfileData = await _supabase
          .from('worker_profiles')
          .select('bio, zone, work_photos')
          .eq('user_id', workerId)
          .maybeSingle();

      final bio = workerProfileData?['bio'] as String?;
      final zone = workerProfileData?['zone'] as String?;

      final skillsData = await _supabase
          .from('worker_services')
          .select('services(name)')
          .eq('worker_id', workerId);

      final skills = skillsData
          .map((s) => s['services']?['name'] as String?)
          .where((s) => s != null)
          .cast<String>()
          .toList();

      final additionalServicesData = await _supabase
          .from('worker_tasks')
          .select('tasks(name)')
          .eq('worker_id', workerId);

      final precargados = additionalServicesData
          .map((s) => s['tasks']?['name'] as String?)
          .where((s) => s != null)
          .cast<String>()
          .toList();

      final customServicesData = await _supabase
          .from('custom_services')
          .select('name')
          .eq('worker_id', workerId);

      final personalizados = customServicesData
          .map((s) => s['name'] as String?)
          .where((s) => s != null)
          .cast<String>()
          .toList();

      final additionalServices = [...precargados, ...personalizados];

      final photosRaw = workerProfileData?['work_photos'] as List? ?? [];
      final workPhotos = photosRaw
          .map((url) => WorkPhoto(url: url as String))
          .toList();

final reviewsData = await _supabase
          .from('reviews')
          .select('id, rating, comment, created_at, client_id')
          .eq('worker_id', workerId)
          .order('created_at', ascending: false);

      final List<Review> reviews = [];
      for (final r in reviewsData) {
        final clientData = await _supabase
            .from('profiles')
            .select('first_name, last_name, avatar_url')
            .eq('id', r['client_id'])
            .maybeSingle();

        reviews.add(Review(
          id: r['id'] as String,
          clientName:
              '${clientData?['first_name'] ?? ''} ${clientData?['last_name'] ?? ''}'
                  .trim(),
          clientAvatar: clientData?['avatar_url'] as String?,
          rating: (r['rating'] as num?)?.toDouble() ?? 0,
          comment: r['comment'] as String? ?? '',
          date: DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
          service: 'Servicio',
        ));
      }

      final reviewCount = reviews.length;
      double rating = 0;
      if (reviewCount > 0) {
        final totalRating = reviews.fold<double>(
          0,
          (sum, r) => sum + r.rating,
        );
        rating = totalRating / reviewCount;
      }

      const completedJobs = 0;

      state = state.copyWith(
        isLoading: false,
        name:
            '${profileData['first_name'] ?? ''} ${profileData['last_name'] ?? ''}'
                .trim(),
        profession: profession,
        avatarUrl: profileData['avatar_url'] as String?,
        bio: bio,
        skills: skills,
        additionalServices: additionalServices,
        workPhotos: workPhotos,
        rating: rating,
        reviewCount: reviewCount,
        reviews: reviews,
        completedJobs: completedJobs,
        zone: zone,
      );
    } catch (e) {
      print('Error cargando perfil del trabajador: $e');
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error al cargar el perfil',
      );
    }
  }
}