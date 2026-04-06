class ServiceModel {
  final String id;
  final String name;

  ServiceModel({required this.id, required this.name});

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(id: map['id'].toString(), name: map['name'] as String);
  }
}
