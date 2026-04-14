import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/core/theme/app_theme.dart';
import 'package:jobsy/features/worker/domain/reviews_state.dart';
import 'package:jobsy/features/worker/presentation/worker_reviews/worker_reviews_controller.dart';

class WorkerReviewsPage extends ConsumerWidget {
  const WorkerReviewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workerReviewsControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final borderColor = isDark ? const Color(0xFF3C3C3C) : Colors.grey[200]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reseñas',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: state.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    size: 48,
                    color: AppTheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'JobSy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
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
            )
          : Column(
              children: [
                _buildRatingSummary(
                  state,
                  cardColor,
                  textColor,
                  subColor,
                  borderColor,
                  isDark,
                ),
                Expanded(
                  child: state.reviews.isEmpty
                      ? _buildEmptyState(subColor)
                      : _buildReviewsList(
                          state.reviews,
                          cardColor,
                          textColor,
                          subColor,
                          borderColor,
                          isDark,
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildRatingSummary(
    ReviewsState state,
    Color cardColor,
    Color textColor,
    Color subColor,
    Color borderColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  state.averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < state.averageRating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.totalReviews} reseñas',
                  style: TextStyle(
                    color: subColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color subColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 80,
            color: subColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aún no hay reseñas',
            style: TextStyle(fontSize: 18, color: subColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Las reseñas de tus clientes aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: subColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(
    List<ReviewItem> reviews,
    Color cardColor,
    Color textColor,
    Color subColor,
    Color borderColor,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) => _buildReviewCard(
        reviews[index],
        cardColor,
        textColor,
        subColor,
        borderColor,
        isDark,
      ),
    );
  }

  Widget _buildReviewCard(
    ReviewItem review,
    Color cardColor,
    Color textColor,
    Color subColor,
    Color borderColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isDark
                    ? const Color(0xFF3C3C3C)
                    : Colors.grey[200],
                backgroundImage: review.clientAvatar != null
                    ? NetworkImage(review.clientAvatar!) as ImageProvider
                    : null,
                child: review.clientAvatar == null
                    ? Text(
                        review.clientName.isNotEmpty
                            ? review.clientName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.primary,
                        ),
                      )
                    : null,
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
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(color: subColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment, style: TextStyle(color: subColor, height: 1.5)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }
}
