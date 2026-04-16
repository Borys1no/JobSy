class ClientHomeState {
  final bool isLoading;
  final List<FeaturedWorker> featuredWorkers;
  final List<Category> categories;
  final List<PopularJob> popularJobs;

  ClientHomeState({
    required this.isLoading,
    required this.featuredWorkers,
    required this.categories,
    required this.popularJobs,
  });

  factory ClientHomeState.initial() => ClientHomeState(
    isLoading: true,
    featuredWorkers: const [],
    categories: const [],
    popularJobs: const [],
  );

  ClientHomeState copyWith({
    bool? isLoading,
    List<FeaturedWorker>? featuredWorkers,
    List<Category>? categories,
    List<PopularJob>? popularJobs,
  }) {
    return ClientHomeState(
      isLoading: isLoading ?? this.isLoading,
      featuredWorkers: featuredWorkers ?? this.featuredWorkers,
      categories: categories ?? this.categories,
      popularJobs: popularJobs ?? this.popularJobs,
    );
  }
}

class FeaturedWorker {
  final String id;
  final String name;
  final String profession;
  final String? avatarUrl;
  final String description;
  final double rating;
  final int reviewCount;
  final List<String> additionalServices;

  FeaturedWorker({
    required this.id,
    required this.name,
    required this.profession,
    this.avatarUrl,
    required this.description,
    required this.rating,
    required this.reviewCount,
    this.additionalServices = const [],
  });
}

class Category {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int workerCount;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.workerCount,
  });
}

class PopularJob {
  final String id;
  final String name;
  final String icon;
  final int requestCount;

  PopularJob({
    required this.id,
    required this.name,
    required this.icon,
    required this.requestCount,
  });
}
