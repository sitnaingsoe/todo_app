import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/to_do.dart';
import '../widgets/to_do_title.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> todos = [];
  String selectedFilter = "All";
  String searchQuery = "";
  bool sortHighToLow = true;

  final List<String> categories = ["All", "General", "Work", "Personal", "Shopping"];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // ================= TODO OPERATIONS =================

  void addOrEditTodo({
    Todo? todo,
    int? index,
    required String title,
    required String category,
    required int priority,
    DateTime? dueDate,
  }) {
    setState(() {
      if (todo == null) {
        todos.add(Todo(
          title: title,
          category: category,
          priority: priority,
          dueDate: dueDate,
        ));
      } else {
        todos[index!] = Todo(
          id: todo.id,
          title: title,
          category: category,
          priority: priority,
          dueDate: dueDate,
          isDone: todo.isDone,
        );
      }
      _sortTodos();
    });
    _saveTodos();
  }

  void toggleTodo(int index) {
    setState(() {
      todos[index].isDone = !todos[index].isDone;
      _sortTodos();
    });
    _saveTodos();
  }

  void deleteTodoAt(int index) {
    final removed = todos[index];
    setState(() => todos.removeAt(index));
    _saveTodos();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Task deleted"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            setState(() {
              todos.insert(index, removed);
              _sortTodos();
            });
            _saveTodos();
          },
        ),
      ),
    );
  }

  void _sortTodos() {
    todos.sort((a, b) {
      if (a.isDone && !b.isDone) return 1;
      if (!a.isDone && b.isDone) return -1;
      return sortHighToLow ? a.priority - b.priority : b.priority - a.priority;
    });
  }

  // ================= STORAGE =================

  void _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosString = prefs.getString('todos');

    if (todosString != null) {
      final decoded = jsonDecode(todosString);
      setState(() {
        todos = decoded.map<Todo>((t) => Todo.fromMap(t)).toList();
        _sortTodos();
      });
    }
  }

  void _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = todos.map((t) => t.toMap()).toList();
    prefs.setString('todos', jsonEncode(encoded));
  }

  // ================= ADD / EDIT DIALOG =================

  void showAddDialog({Todo? todo, int? index}) {
    final controller = TextEditingController(text: todo?.title ?? "");
    String selectedCategory = todo?.category ?? "General";
    int selectedPriority = todo?.priority ?? 2;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(todo == null ? "Add Task" : "Edit Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller, decoration: const InputDecoration(hintText: "Task title")),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .where((c) => c != "All")
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => selectedCategory = v!,
              decoration: const InputDecoration(labelText: "Category"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: selectedPriority,
              items: const [
                DropdownMenuItem(value: 1, child: Text("High")),
                DropdownMenuItem(value: 2, child: Text("Medium")),
                DropdownMenuItem(value: 3, child: Text("Low")),
              ],
              onChanged: (v) => selectedPriority = v!,
              decoration: const InputDecoration(labelText: "Priority"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              addOrEditTodo(
                todo: todo,
                index: index,
                title: controller.text.trim(),
                category: selectedCategory,
                priority: selectedPriority,
              );
              Navigator.pop(context);
            },
            child: Text(todo == null ? "Add" : "Save"),
          )
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final filteredTodos = todos.where((t) {
      final matchesCategory = selectedFilter == "All" || t.category == selectedFilter;
      final matchesSearch = t.title.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tasks"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              setState(() {
                sortHighToLow = !sortHighToLow;
                _sortTodos();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () => MyApp.of(context).toggleTheme(),
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔎 SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search tasks...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => searchQuery = v),
            ),
          ),

          // 🏷 CATEGORY CHIPS
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final category = categories[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: selectedFilter == category,
                    onSelected: (_) => setState(() => selectedFilter = category),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 📋 TASK LIST
          Expanded(
            child: filteredTodos.isEmpty
                ? const Center(child: Text("No tasks found"))
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      return TodoTile(
                        key: Key(todo.id),
                        todo: todo,
                        onTap: () => toggleTodo(todos.indexOf(todo)),
                        onDelete: () => deleteTodoAt(todos.indexOf(todo)),
                        onEdit: () => showAddDialog(todo: todo, index: todos.indexOf(todo)),
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = todos.removeAt(oldIndex);
                        todos.insert(newIndex, item);
                      });
                      _saveTodos();
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddDialog(),
        label: const Text("Add Task"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}