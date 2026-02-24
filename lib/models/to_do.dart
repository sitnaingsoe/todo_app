class Todo {
  final String id;
  final String title;    // required
  final String category; // required
  final int priority;    // required
  bool isDone;
  DateTime? dueDate;

  Todo({
    this.id = '',
    required this.title,
    required this.category,
    required this.priority,
    this.isDone = false,
    this.dueDate,
  });

  // ================= FROM JSON (API → APP)

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      category: json['category'] ?? 'General',
      priority: json['priority'] ?? 2,
      isDone: json['isDone'] ?? false,
      dueDate:
          json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }

  // ================= TO JSON (APP → API)

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'priority': priority,
      'isDone': isDone,
      'dueDate': dueDate?.toIso8601String(),
    };
  }
}