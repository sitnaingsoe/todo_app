import 'package:uuid/uuid.dart';

class Todo {
  final String id;
  String title;
  String category;
  int priority;
  DateTime? dueDate;
  bool isDone;

  Todo({
    String? id,
    required this.title,
    this.category = "General",
    this.priority = 2,
    this.dueDate,
    this.isDone = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'isDone': isDone,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      priority: map['priority'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      isDone: map['isDone'] ?? false,
    );
  }
}