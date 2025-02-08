import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_todo_list/models/todo_model.dart';
import 'package:flutter_todo_list/repository/todo/todo_repository.dart';
import 'package:flutter_todo_list/utils/snackbar.dart';
import 'package:flutter_todo_list/utils/token.dart';

class TodoProvider with ChangeNotifier {
  TodoProvider({required this.dio});
  final Dio dio;

  final _todoRepository = TodoRepository();

  final storage = FlutterSecureStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final formKeyCreate = GlobalKey<FormState>();
  final formKeyUpdate = GlobalKey<FormState>();

  List<TodosResponseModel> _todos = [];
  List<TodosResponseModel> get todos => _todos;

  String createTodoTitle = "";
  String createTodoDescription = "";
  bool createTodoIsCompleted = false;

  final TextEditingController updateTodoTitle = TextEditingController();
  final TextEditingController updateTodoDescription = TextEditingController();
  bool updateTodoIsCompleted = false;

  @override
  void dispose() {
    updateTodoTitle.dispose();
    updateTodoDescription.dispose();
    super.dispose();
  }

  void updateTodoCompleted(bool value) {
    updateTodoIsCompleted = value;
    notifyListeners();
  }

  Future<void> createTodo(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final accesToken = await getToken(storage, "access-token");
      final response = await _todoRepository.createTodo(
        dio,
        TodoCreatePayload(
          title: createTodoTitle,
          description: createTodoDescription,
          isCompleted: createTodoIsCompleted,
        ),
        accesToken!,
      );

      response.fold((error) {
        showSnackBar(context, error);
        return;
      }, (data) {
        showSnackBar(context, data);
      });
    } on DioException catch (e) {
      if (context.mounted) {
        if (e.response != null) {
          showSnackBar(context, e.response?.data["error"] ?? "unknown error");
          return;
        }
        showSnackBar(context, "Error create todo: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAll(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final accesToken = await getToken(storage, "access-token");
      final response = await _todoRepository.getAll(
        dio,
        accesToken!,
      );
      response.fold((error) {
        showSnackBar(context, error);
        return;
      }, (data) {
        _todos = data;
        notifyListeners();
      });
    } on DioException catch (e) {
      if (context.mounted) {
        if (e.response != null) {
          showSnackBar(context, e.response?.data["error"] ?? "unknown error");
          return;
        }
        showSnackBar(context, "Error get todo: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTodo(BuildContext context, int todoID,String title,
      {bool updateAll = true}) async {
    try {
      final accesToken = await getToken(storage, "access-token");
      final response = await _todoRepository.updateTodo(
        dio,
        UpdateTodoPayload(
          title: updateTodoTitle.text,
          description: updateTodoDescription.text,
          isCompleted: updateTodoIsCompleted,
          userId: 0,
        ),
        todoID,
        accesToken!,
      );
      response.fold((error) {
        showSnackBar(context, error);
        return;
      }, (data) {
        if (updateAll) {
          showSnackBar(context, "$title updated");
        }
      });
    } on DioException catch (e) {
      if (context.mounted) {
        if (e.response != null) {
          showSnackBar(context, e.response?.data["error"] ?? "unknown error");
          return;
        }
        showSnackBar(context, "Error update todo: $e");
      }
    } finally {
      updateTodoTitle.clear();
      updateTodoDescription.clear();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(BuildContext context, int todoID, String title) async {
    try {
      final accesToken = await getToken(storage, "access-token");
      final response = await _todoRepository.deleteTodo(
        dio,
        todoID,
        accesToken!,
      );
      response.fold((error) {
        showSnackBar(context, error);
        return;
      }, (data) {
        showSnackBar(context, "$title deleted");
      });
    } on DioException catch (e) {
      if (context.mounted) {
        if (e.response != null) {
          showSnackBar(context, e.response?.data["error"] ?? "unknown error");
          return;
        }
        showSnackBar(context, "Error delete todo: $e");
      }
    } 
  }
}
