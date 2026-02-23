import 'package:flutter/material.dart';
import '../models/to_do.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    String dueDateText = "";
    if (todo.dueDate != null) {
      dueDateText =
          " | Due: ${todo.dueDate!.toLocal().toString().split(' ')[0]}";
    }

    return ListTile(
      leading: Checkbox(
        value: todo.isDone,
        onChanged: (_) => onTap(),
      ),
      title: GestureDetector(
        onTap: onEdit,
        child: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
      subtitle: Text(
        "Category: ${todo.category} | Priority: ${["High", "Medium", "Low"][todo.priority - 1]}$dueDateText",
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: onDelete,
      ),
    );
  }
}