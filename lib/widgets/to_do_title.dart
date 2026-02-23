import 'package:flutter/material.dart';
import '../models/to_do.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onDelete,
    this.onEdit,
  });

  Color getTitleColor(Todo todo) {
    if (todo.dueDate == null) return Colors.black;
    final today = DateTime.now();
    final due = todo.dueDate!.toLocal();
    if (!todo.isDone && due.isBefore(today)) return Colors.red;
    if (!todo.isDone &&
        due.year == today.year &&
        due.month == today.month &&
        due.day == today.day) return Colors.orange;
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.isDone ? TextDecoration.lineThrough : null,
          color: getTitleColor(todo),
        ),
      ),
      subtitle: Text("${todo.category} • Priority: ${todo.priority}"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}