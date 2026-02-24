import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/to_do.dart';
import '../core/config/api_config.dart';

class ApiService {
  static String get _url => "${ApiConfig.baseUrl}/todos";

  static Future<List<Todo>> getTodos() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Todo.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load todos");
    }
  }

  static Future<Todo> addTodo(Todo todo) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(todo.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to add todo");
    }
  }

  static Future<void> updateTodo(Todo todo) async {
    await http.put(
      Uri.parse("$_url/${todo.id}"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(todo.toJson()),
    );
  }

  static Future<void> deleteTodo(String id) async {
    await http.delete(Uri.parse("$_url/$id"));
  }
}