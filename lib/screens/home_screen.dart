import 'package:flutter/material.dart';
import '../models/to_do.dart';
import '../widgets/to_do_title.dart';
import '../main.dart';
import '../services/api_service.dart';

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
    _loadTodosFromApi();
  }

  // ================= API + LOCAL UI =================

  Future<void> _loadTodosFromApi() async {
    try {
      final fetched = await ApiService.getTodos();
      setState(() {
        todos = fetched;
        _sortTodos();
      });
    } catch (e) {
      // Handle errors here
      debugPrint("Failed to load todos: $e");
    }
  }

  Future<void> addOrEditTodoApi({
    Todo? todo,
    required String title,
    required String category,
    required int priority,
    DateTime? dueDate,
  }) async {
    if (todo == null) {
      // Add new todo
      final newTodo = Todo(
        title: title,
        category: category,
        priority: priority,
        dueDate: dueDate,
      );

      final addedTodo = await ApiService.addTodo(newTodo);

      setState(() {
        todos.add(addedTodo);
        _sortTodos();
      });
    } else {
      // Edit existing
      final updatedTodo = Todo(
        id: todo.id,
        title: title,
        category: category,
        priority: priority,
        dueDate: dueDate,
        isDone: todo.isDone,
      );
      await ApiService.updateTodo(updatedTodo);

      setState(() {
        final index = todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          todos[index] = updatedTodo;
          _sortTodos();
        }
      });
    }
  }

  Future<void> toggleTodoApi(Todo todo) async {
    final updatedTodo = Todo(
      id: todo.id,
      title: todo.title,
      category: todo.category,
      priority: todo.priority,
      dueDate: todo.dueDate,
      isDone: !todo.isDone,
    );
    await ApiService.updateTodo(updatedTodo);
    setState(() {
      final index = todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        todos[index] = updatedTodo;
        _sortTodos();
      }
    });
  }

  Future<void> deleteTodoApi(Todo todo) async {
    await ApiService.deleteTodo(todo.id);
    setState(() => todos.removeWhere((t) => t.id == todo.id));
  }

  void _sortTodos() {
    todos.sort((a, b) {
      if (a.isDone && !b.isDone) return 1;
      if (!a.isDone && b.isDone) return -1;
      return sortHighToLow ? a.priority - b.priority : b.priority - a.priority;
    });
  }

  // ================= ADD / EDIT DIALOG =================

  void showAddDialog({Todo? todo}) {
    final controller = TextEditingController(text: todo?.title ?? "");
    String selectedCategory = todo?.category ?? "General";
    int selectedPriority = todo?.priority ?? 2;
    DateTime? selectedDate = todo?.dueDate;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(todo == null ? "Add Task" : "Edit Task"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: "Task title"),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories
                      .where((c) => c != "All")
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCategory = v ?? "General"),
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
                  onChanged: (v) => setState(() => selectedPriority = v ?? 2),
                  decoration: const InputDecoration(labelText: "Priority"),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("Due Date: "),
                    Text(selectedDate != null
                        ? "${selectedDate?.toLocal().toString().split(' ')[0]}"
                        : "None"),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => selectedDate = picked);
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                await addOrEditTodoApi(
                  todo: todo,
                  title: controller.text.trim(),
                  category: selectedCategory,
                  priority: selectedPriority,
                  dueDate: selectedDate,
                );
                Navigator.pop(context);
              },
              child: Text(todo == null ? "Add" : "Save"),
            ),
          ],
        ),
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
                        onTap: () => toggleTodoApi(todo),
                        onDelete: () => deleteTodoApi(todo),
                        onEdit: () => showAddDialog(todo: todo),
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = todos.removeAt(oldIndex);
                        todos.insert(newIndex, item);
                      });
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