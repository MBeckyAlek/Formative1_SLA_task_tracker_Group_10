import 'enums.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String assigneeId;
  final Priority priority;
  final DateTime deadline;
  final TaskStatus status;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assigneeId,
    required this.priority,
    required this.deadline,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'assigneeId': assigneeId,
    'priority': priority.name,
    'deadline': deadline.toIso8601String(),
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    assigneeId: json['assigneeId'] as String,
    priority: Priority.values.byName(json['priority'] as String),
    deadline: DateTime.parse(json['deadline'] as String),
    status: TaskStatus.values.byName(json['status'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Task copyWith({
    String? title,
    String? description,
    String? assigneeId,
    Priority? priority,
    DateTime? deadline,
    TaskStatus? status,
  }) =>
      Task(
        id: id,
        title: title?? this.title,
        description: description?? this.description,
        assigneeId: assigneeId?? this.assigneeId,
        priority: priority?? this.priority,
        deadline: deadline?? this.deadline,
        status: status?? this.status,
        createdAt: createdAt,
      );
}