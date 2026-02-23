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

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // Add/Edit todo
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

  // Toggle completion
  void toggleTodo(int index) {
    setState(() {
      todos[index].isDone = !todos[index].isDone;
      _sortTodos();
    });
    _saveTodos();
  }

  // Delete with undo
  void deleteTodoAt(int index) {
    final removed = todos[index];
    setState(() {
      todos.removeAt(index);
    });
    _saveTodos();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Task deleted!"),
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

  // Sort todos
  void _sortTodos() {
    todos.sort((a, b) {
      if (a.isDone && !b.isDone) return 1;
      if (!a.isDone && b.isDone) return -1;
      if (sortHighToLow) {
        if (a.priority != b.priority) return a.priority - b.priority;
      } else {
        if (a.priority != b.priority) return b.priority - a.priority;
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return 0;
    });
  }

  // Load & save todos
  void _loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todosString = prefs.getString('todos');
    if (todosString != null) {
      List decoded = jsonDecode(todosString);
      setState(() {
        todos = decoded.map((t) => Todo.fromMap(t)).toList();
        _sortTodos();
      });
    }
  }

  void _saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List encoded = todos.map((t) => t.toMap()).toList();
    prefs.setString('todos', jsonEncode(encoded));
  }

  // Show Add/Edit Dialog
  void showAddDialog({Todo? todo, int? index}) {
    TextEditingController controller = TextEditingController();
    controller.text = todo?.title ?? "";

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
                  decoration: const InputDecoration(hintText: "Enter task title"),
                  autofocus: true,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: ["General", "Work", "Personal", "Shopping"]
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedCategory = value!),
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: selectedPriority,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("High")),
                    DropdownMenuItem(value: 2, child: Text("Medium")),
                    DropdownMenuItem(value: 3, child: Text("Low")),
                  ],
                  onChanged: (value) => setState(() => selectedPriority = value!),
                  decoration: const InputDecoration(labelText: "Priority"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Due Date: "),
                    Text(selectedDate != null
                        ? "${selectedDate?.toLocal().toString().split(' ')[0]}"
                        : "None"),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
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
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                addOrEditTodo(
                  todo: todo,
                  index: index,
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

  Color getTitleColor(Todo todo) {
    if (todo.dueDate == null) return Colors.black;
    final today = DateTime.now();
    final due = todo.dueDate!.toLocal();
    if (due.isBefore(today) && !todo.isDone) return Colors.red;
    if (due.year == today.year &&
        due.month == today.month &&
        due.day == today.day &&
        !todo.isDone) return Colors.orange;
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    List<Todo> filteredTodos = todos.where((t) {
      final matchesCategory = selectedFilter == "All" || t.category == selectedFilter;
      final matchesSearch = t.title.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    List<DateTime> dueDates = todos
        .where((t) => t.dueDate != null)
        .map((t) => t.dueDate!.toLocal())
        .toSet()
        .toList()
      ..sort();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Todo List"),
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
          bottom: const TabBar(
            tabs: [
              Tab(text: "Tasks"),
              Tab(text: "Calendar"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search tasks...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),
                ),
                // Category filter
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    items: ["All", "General", "Work", "Personal", "Shopping"]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedFilter = value!);
                    },
                  ),
                ),
                Expanded(
                  child: filteredTodos.isEmpty
                      ? const Center(child: Text("No tasks for this filter/search"))
                      : ReorderableListView.builder(
                          itemCount: filteredTodos.length,
                          itemBuilder: (context, index) {
                            final todo = filteredTodos[index];
                            return Dismissible(
                              key: Key(todo.id),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => deleteTodoAt(todos.indexOf(todo)),
                              child: TodoTile(
                                todo: todo,
                                onTap: () => toggleTodo(todos.indexOf(todo)),
                                onEdit: () => showAddDialog(
                                    todo: todo, index: todos.indexOf(todo)),
                                onDelete: () => deleteTodoAt(todos.indexOf(todo)),
                              ),
                            );
                          },
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final item = todos.removeAt(oldIndex);
                              todos.insert(newIndex, item);
                            });
                            _saveTodos();
                          },
                        ),
                ),
              ],
            ),
            // Calendar tab
            ListView.builder(
              itemCount: dueDates.length,
              itemBuilder: (context, index) {
                final date = dueDates[index];
                final tasksForDate =
                    todos.where((t) => t.dueDate?.toLocal() == date).toList();
                return ExpansionTile(
                  title: Text("${date.toString().split(' ')[0]}"),
                  children: tasksForDate
                      .map((t) => TodoTile(
                            todo: t,
                            onTap: () => toggleTodo(todos.indexOf(t)),
                            onEdit: () => showAddDialog(todo: t, index: todos.indexOf(t)),
                            onDelete: () => deleteTodoAt(todos.indexOf(t)),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showAddDialog(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}