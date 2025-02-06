import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_todo_list/models/token_model.dart';
import 'package:flutter_todo_list/models/user_model.dart';

class AuthRepository {
  Future<Either<String, String>> registerUser(
      Dio dio, RegisterModel register) async {
    try {
      final response = await dio.postUri(
        Uri(path: "/auth/register"),
        data: register.toJson(),
        options: Options(contentType: Headers.jsonContentType),
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
      return left("Error registering user: $e");
    }
  }

  Future<Either<String, TokenModel>> loginUser(
      Dio dio, LoginModel login) async {
    try {
      final response = await dio.postUri(
        Uri(path: "/auth/login"),
        options: Options(contentType: Headers.jsonContentType),
        data: login.toJson(),
      );
      if (response.statusCode! <= 299) {
        return right(TokenModel.fromJson(response.data));
      }
      return left("Something went wrong, try again later");
    }on DioException catch (e) {
      if (e.response != null){
        final errorMessage = e.response?.data["error"] ?? "Unknown error";
        return Left("$errorMessage");
      }
      return left("Error registering login: $e");
    }
  }
}
