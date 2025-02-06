import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_todo_list/models/todo_model.dart';

class TodoRepository {
  Future<Either<String, String>> createTodo(
    Dio dio,
    TodoCreatePayload payload,
    String accessToken,
  ) async {
    try {
      final response = await dio.postUri(
        Uri(path: "/todo"),
        data: payload.toJson(),
        options: Options(contentType: Headers.jsonContentType, headers: {
          "Authorization": accessToken,
        }),
      );
      if (response.statusCode! <= 299) {
        return right(response.data.toString());
      }
      return left("Something went wrong, try again later");
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['error'] ?? 'Unknown error';
        return left('$errorMessage');
      }
      return left("Error create todo: $e");
    }
  }

  Future<Either<String, String>> updateTodo(
      Dio dio, UpdateTodoPayload payload, int todoID, String accessToken) async {
    try {
      final response = await dio.putUri(
        Uri(path: "/todo/$todoID"),
        options: Options(contentType: Headers.jsonContentType,headers: {
          "Authorization": accessToken,
        }),
        data: payload.toJson(),
      );
      if (response.statusCode! <= 299) {
        return right("Success update todo");
      }
      return left("Something went wrong, try again later");
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data["error"] ?? "Unknown error";
        return Left("$errorMessage");
      }
      return left("Error update todo: $e");
    }
  }

  Future<Either<String, String>> deleteTodo(Dio dio, int todoID,  String accessToken) async {
    try {
      final response = await dio.deleteUri(
        Uri(path: "/todo/$todoID"),
         options: Options(contentType: Headers.jsonContentType,headers: {
          "Authorization": accessToken,
        }),
      );
      if (response.statusCode! <= 299) {
        return right("Success delete todo");
      }
      return left("Something went wrong, try again later");
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data["error"] ?? "Unknown error";
        return Left("$errorMessage");
      }
      return left("Error delete todo: $e");
    }
  }
}
