class ReviewsState {
  final bool isLoading;
  final List<ReviewItem> reviews;
  final double averageRating;
  final int totalReviews;

  ReviewsState({
    required this.isLoading,
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });

  factory ReviewsState.initial() => ReviewsState(
    isLoading: true,
    reviews: const [],
    averageRating: 0,
    totalReviews: 0,
  );

  ReviewsState copyWith({
    bool? isLoading,
    List<ReviewItem>? reviews,
    double? averageRating,
    int? totalReviews,
  }) {
    return ReviewsState(
      isLoading: isLoading ?? this.isLoading,
      reviews: reviews ?? this.reviews,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }
}

class ReviewItem {
  final String id;
  final String clientName;
  final String? clientAvatar;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewItem({
    required this.id,
    required this.clientName,
    this.clientAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}
