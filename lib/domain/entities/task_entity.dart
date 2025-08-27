import 'package:loop_task/domain/enums/task_status.dart';

class Task {
  final String id;
  String title;
  TaskStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final String? parentId;
  int order;

  Task({
    required this.id,
    required this.title,
    required this.status,
    DateTime? createdAt,
    this.updatedAt,
    this.completedAt,
    this.parentId,
    this.order = 0,
  }) : createdAt = createdAt ?? DateTime.now();
}
