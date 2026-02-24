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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: getTitleColor(todo),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "${todo.category} • Priority: ${todo.priority}" +
              (todo.dueDate != null
                  ? " • Due: ${todo.dueDate!.toLocal().toString().split(' ')[0]}"
                  : ""),
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}