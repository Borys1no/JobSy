import 'active_job.dart';
import 'review.dart';

class WorkerHomeState {
  final bool isLoading;
  final String? name;
  final String? profession;
  final String? avatarUrl;
  final String? avatarPath;
  final double rating;
  final int reviewCount;
  final String? description;
  final List<String> skills;
  final List<String> workPhotos;
  final int completedJobs;
  final List<bool> availableDays;
  final List<ActiveJob> activeJobs;
  final List<Review> reviews;

  WorkerHomeState({
    required this.isLoading,
    this.name,
    this.profession,
    this.avatarUrl,
    this.avatarPath,
    required this.rating,
    required this.reviewCount,
    this.description,
    required this.skills,
    required this.workPhotos,
    required this.completedJobs,
    required this.availableDays,
    required this.activeJobs,
    required this.reviews,
  });

  factory WorkerHomeState.initial() => WorkerHomeState(
    isLoading: true,
    name: null,
    profession: null,
    avatarUrl: null,
    avatarPath: null,
    rating: 0,
    reviewCount: 0,
    description: null,
    skills: const [],
    workPhotos: const [],
    completedJobs: 0,
    availableDays: const [false, false, false, false, false, false, false],
    activeJobs: const [],
    reviews: const [],
  );

  WorkerHomeState copyWith({
    bool? isLoading,
    String? name,
    String? profession,
    String? avatarUrl,
    String? avatarPath,
    double? rating,
    int? reviewCount,
    String? description,
    List<String>? skills,
    List<String>? workPhotos,
    int? completedJobs,
    List<bool>? availableDays,
    List<ActiveJob>? activeJobs,
    List<Review>? reviews,
  }) {
    return WorkerHomeState(
      isLoading: isLoading ?? this.isLoading,
      name: name ?? this.name,
      profession: profession ?? this.profession,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarPath: avatarPath ?? this.avatarPath,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      description: description ?? this.description,
      skills: skills ?? this.skills,
      workPhotos: workPhotos ?? this.workPhotos,
      completedJobs: completedJobs ?? this.completedJobs,
      availableDays: availableDays ?? this.availableDays,
      activeJobs: activeJobs ?? this.activeJobs,
      reviews: reviews ?? this.reviews,
    );
  }
}
