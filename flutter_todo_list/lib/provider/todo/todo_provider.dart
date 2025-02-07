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

  // String _createResponse = "";
  // String get createResponse => _createResponse;

  // String _updateResponse = "";
  // String get updateResponse => _updateResponse;

  // String _deleteResponse = "";
  // String get deleteResponse => _deleteResponse;

  String createTodoTitle = "";
  String createTodoDescription = "";
  bool createTodoIsCompleted = false;

  String updateTodoTitle = "";
  String updateTodoDescription = "";
  bool updateTodoIsCompleted = false;
  int updateTodoUserID = 0;

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

  Future<void> updateTodo(BuildContext context, int todoID) async {
    _isLoading = true;
    notifyListeners();
    try {
      final accesToken = await getToken(storage, "access-token");
      final response = await _todoRepository.updateTodo(
        dio,
        UpdateTodoPayload(
          title: updateTodoTitle,
          description: updateTodoDescription,
          isCompleted: updateTodoIsCompleted,
          userId: updateTodoUserID,
        ),
        todoID,
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
        showSnackBar(context, "Error update todo: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTodo(BuildContext context, int todoID) async {
    _isLoading = true;
    notifyListeners();
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
        showSnackBar(context, data);
      });
    } on DioException catch (e) {
      if (context.mounted) {
        if (e.response != null) {
          showSnackBar(context, e.response?.data["error"] ?? "unknown error");
          return;
        }
        showSnackBar(context, "Error delete todo: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
