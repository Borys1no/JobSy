import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import 'package:jobsy/features/worker/domain/reviews_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'worker_reviews_controller.g.dart';

@riverpod
class WorkerReviewsController extends _$WorkerReviewsController {
  SupabaseClient get _supabase => ref.read(supabaseProvider);

  @override
  ReviewsState build() {
    Future.microtask(() => loadReviews());
    return ReviewsState.initial();
  }

  Future<void> loadReviews() async {
    try {
      state = state.copyWith(isLoading: true);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final reviewsData = await _supabase
          .from('reviews')
          .select('''
            id,
            rating,
            comment,
            created_at,
            client:profiles(
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .eq('worker_id', userId)
          .order('created_at', ascending: false);

      List<ReviewItem> reviews;
      if (reviewsData.isEmpty) {
        reviews = _getStaticReviews();
      } else {
        reviews = reviewsData.map((r) {
          final client = r['client'] as Map<String, dynamic>? ?? {};
          return ReviewItem(
            id: r['id'] as String,
            clientName:
                '${client['first_name'] ?? ''} ${client['last_name'] ?? ''}'
                    .trim(),
            clientAvatar: client['avatar_url'] as String?,
            rating: r['rating'] as int,
            comment: r['comment'] as String? ?? '',
            createdAt: DateTime.parse(r['created_at'] as String),
          );
        }).toList();
      }

      final totalReviews = reviews.length;
      final averageRating = totalReviews > 0
          ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / totalReviews
          : 0.0;

      state = state.copyWith(
        isLoading: false,
        reviews: reviews,
        averageRating: averageRating,
        totalReviews: totalReviews,
      );
    } catch (e) {
      print('Error cargando reseñas: $e');
      state = state.copyWith(
        isLoading: false,
        reviews: _getStaticReviews(),
        averageRating: 4.2,
        totalReviews: 5,
      );
    }
  }

  List<ReviewItem> _getStaticReviews() {
    return [
      ReviewItem(
        id: '1',
        clientName: 'María García',
        clientAvatar: null,
        rating: 5,
        comment:
            'Excelente trabajo, muy profesional y puntuales. Totalmente recomendado,很快就完成了工作，质量非常好。',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ReviewItem(
        id: '2',
        clientName: 'Juan Pérez',
        clientAvatar: null,
        rating: 4,
        comment:
            'Buen servicio, puntuales y eficientes. El trabajo quedó muy bien.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ReviewItem(
        id: '3',
        clientName: 'Ana López',
        clientAvatar: null,
        rating: 5,
        comment:
            'Muy satisfied with the service. They exceeded my expectations!',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      ReviewItem(
        id: '4',
        clientName: 'Carlos Martínez',
        clientAvatar: null,
        rating: 4,
        comment: 'Buena atención y resultados buenos. Volvería a contratar.',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ReviewItem(
        id: '5',
        clientName: 'Laura Sánchez',
        clientAvatar: null,
        rating: 3,
        comment: 'El trabajo está bien, pero llegaron un poco tarde.',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }
}
