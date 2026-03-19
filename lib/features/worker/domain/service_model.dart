class ServiceModel {
  final int id;
  final String name;

  ServiceModel({required this.id, required this.name});

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
    );
  }
}
