import 'package:jobsy/features/worker/domain/review.dart';

class WorkerProfileState {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final String workerId;
  final String? name;
  final String? profession;
  final String? avatarUrl;
  final double rating;
  final int reviewCount;
  final String? bio;
  final List<String> skills;
  final List<String> additionalServices;
  final List<WorkPhoto> workPhotos;
  final int completedJobs;
  final String? address;
  final String? zone;
  final List<Review> reviews;

  WorkerProfileState({
    required this.isLoading,
    this.hasError = false,
    this.errorMessage,
    required this.workerId,
    this.name,
    this.profession,
    this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    this.bio,
    required this.skills,
    required this.additionalServices,
    required this.workPhotos,
    required this.completedJobs,
    this.address,
    this.zone,
    required this.reviews,
  });

  factory WorkerProfileState.initial(String workerId) => WorkerProfileState(
        isLoading: true,
        workerId: workerId,
        rating: 0,
        reviewCount: 0,
        skills: const [],
        additionalServices: const [],
        workPhotos: const [],
        completedJobs: 0,
        reviews: const [],
      );

  WorkerProfileState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    String? name,
    String? profession,
    String? avatarUrl,
    double? rating,
    int? reviewCount,
    String? bio,
    List<String>? skills,
    List<String>? additionalServices,
    List<WorkPhoto>? workPhotos,
    int? completedJobs,
    String? address,
    String? zone,
    List<Review>? reviews,
  }) {
    return WorkerProfileState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      workerId: workerId,
      name: name ?? this.name,
      profession: profession ?? this.profession,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      additionalServices: additionalServices ?? this.additionalServices,
      workPhotos: workPhotos ?? this.workPhotos,
      completedJobs: completedJobs ?? this.completedJobs,
      address: address ?? this.address,
      zone: zone ?? this.zone,
      reviews: reviews ?? this.reviews,
    );
  }
}

class WorkPhoto {
  final String url;
  final String? id;

  WorkPhoto({required this.url, this.id});
}