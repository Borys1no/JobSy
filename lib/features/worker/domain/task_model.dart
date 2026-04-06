class TaskModel {
  final String id;
  final String name;

  TaskModel({required this.id, required this.name});

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(id: map['id'].toString(), name: map['name'] ?? '');
  }
}
