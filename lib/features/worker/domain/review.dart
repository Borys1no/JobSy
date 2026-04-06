class Review {
  final String id;
  final String clientName;
  final String? clientAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final String service;

  Review({
    required this.id,
    required this.clientName,
    this.clientAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    required this.service,
  });
}
