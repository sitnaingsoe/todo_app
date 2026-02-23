import 'package:uuid/uuid.dart';

class Todo {
  final String id;
  String title;
  String category;
  int priority; // 1 = High, 2 = Medium, 3 = Low
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

  bool get isOverdue {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return !isDone && dueDate!.isBefore(now);
  }

  bool get isToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return !isDone &&
        dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }
}