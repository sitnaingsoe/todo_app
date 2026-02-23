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

  // 🎯 Due date color logic
  Color _dueDateColor(BuildContext context) {
    if (todo.dueDate == null) {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }

    final today = DateTime.now();
    final due = todo.dueDate!.toLocal();

    if (!todo.isDone && due.isBefore(today)) {
      return Colors.red;
    }

    if (!todo.isDone &&
        due.year == today.year &&
        due.month == today.month &&
        due.day == today.day) {
      return Colors.orange;
    }

    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  // 🎯 Priority chip UI
  Widget _priorityChip(BuildContext context) {
    late Color color;
    late String label;

    switch (todo.priority) {
      case 1:
        color = Colors.red;
        label = "High";
        break;
      case 2:
        color = Colors.orange;
        label = "Medium";
        break;
      default:
        color = Colors.green;
        label = "Low";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  // 🎯 Category chip
  Widget _categoryChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        todo.category,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ✅ Checkbox
              Checkbox(
                value: todo.isDone,
                onChanged: (_) => onTap(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              const SizedBox(width: 12),

              // ✅ Main Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: todo.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: todo.isDone
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        _categoryChip(context),
                        const SizedBox(width: 8),
                        _priorityChip(context),

                        if (todo.dueDate != null) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.schedule,
                              size: 16, color: _dueDateColor(context)),
                          const SizedBox(width: 4),
                          Text(
                            "${todo.dueDate!.toLocal().toString().split(' ')[0]}",
                            style: TextStyle(
                              color: _dueDateColor(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),

              // ✅ Menu (cleaner than many icons)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == "edit") onEdit?.call();
                  if (value == "delete") onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: "edit", child: Text("Edit")),
                  PopupMenuItem(value: "delete", child: Text("Delete")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}