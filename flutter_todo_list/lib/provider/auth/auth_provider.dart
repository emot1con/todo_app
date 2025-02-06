import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_todo_list/models/todo_model.dart';
import 'package:flutter_todo_list/models/token_model.dart';
import 'package:flutter_todo_list/models/user_model.dart';
import 'package:flutter_todo_list/repository/auth/auth_repository.dart';
import 'package:flutter_todo_list/utils/navigate_screen.dart';
import 'package:flutter_todo_list/utils/token.dart';
import 'package:flutter_todo_list/utils/snackbar.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({required this.dio});
  final Dio dio;

  final _authRepository = AuthRepository();

  final storage = FlutterSecureStorage();

  List<TodosResponseModel> _todos = [];
  List<TodosResponseModel> get todos => _todos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final formKeyRegister = GlobalKey<FormState>();
  final formKeyLogin = GlobalKey<FormState>();

  TokenModel? _token;
  TokenModel? get token => _token;

  String registerName = "";
  String registerEmail = "";
  String registerPassword = "";

  String loginEmail = "";
  String loginPasswrod = "";

  void navigateScreen(BuildContext context) async {
    print("Navigate screen");
    while (true) {
      try {
        final todoResponse = await dio.getUri(
          Uri(path: "/todo"),
          options: Options(
            headers: {
              "Authorization": await getToken(storage, "access-token")
            },
          ),
        );
        print("get todo");
        if (context.mounted) {
          if (todoResponse.statusCode! <= 299) {
            _todos = todosResponseModelFromJson(todoResponse.data);
            notifyListeners();
            toMainScreen(context);
            return;
          }
          print("valid token");

          toLoginScreen(context);
          return;
        }
        print("invalid token");
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          final refreshToken = await getToken(storage, "refresh-token");
          final expRefreshToken = await getToken(storage, "exp-refresh-token");
          if (context.mounted) {
            if (refreshToken == null || refreshToken.isEmpty) {
              toLoginScreen(context);
              return;
            }

            if (refreshToken.isEmpty || expRefreshToken!.isEmpty) {
              toLoginScreen(context);
              return;
            }
            if (DateTime.now().isAfter(DateTime.parse(expRefreshToken))) {
              toLoginScreen(context);
              return;
            }
            print("valid refresh token");
            final refreshTokenResponse = await dio.postUri(
              Uri(path: "/refresh-token"),
              options: Options(
                headers: {
                  "Authorization": await getToken(storage, "refresh-token"),
                },
              ),
            );
            if (refreshTokenResponse.statusCode! <= 299) {
              final newToken = TokenModel.fromJson(refreshTokenResponse.data);

              saveToken(storage, "access-token", newToken.accessToken);
              saveToken(storage, "exp", newToken.exp);
              saveToken(storage, "refresh-token", newToken.refreshToken);
              saveToken(storage, "exp-refresh-token", newToken.expRefreshToken);

              print("Success create new refresh token");
            } else {
              if (context.mounted) {
                deleteToken(storage);
                toLoginScreen(context);
                print("failed create refresh token");
              }
              return;
            }
          }
        } else {
          if (context.mounted) {
            toLoginScreen(context);
            showSnackBar(context, "something went wrong, try again later");
          }
          return;
        }
        if (e.response != null && context.mounted) {
          final error = e.response?.data["error"] ?? "unknown error";
          showSnackBar(context, error);
          return;
        }
      }
      print("Retrying after refreshing token...");
    }
  }

 
  Future<void> registerUser(
      String name, email, password, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _authRepository.registerUser(
        dio,
        RegisterModel(name: name, email: email, password: password),
      );
      response.fold((error) {
        showSnackBar(context, error);
      }, (data) {
        showSnackBar(context, data);
      });
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginUser(String email, password, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await _authRepository.loginUser(
        dio,
        LoginModel(email: email, password: password),
      );
      response.fold((error) {
        showSnackBar(context, error);
      }, (data) {
        _token = data;
        notifyListeners();

        saveToken(storage, "access-token", _token!.accessToken);
        saveToken(storage, "exp", _token!.exp);
        saveToken(storage, "refresh-token", _token!.refreshToken);
        saveToken(storage, "exp-refresh-token", _token!.expRefreshToken);

        navigateScreen(context);

        showSnackBar(context, "Success login to user $loginEmail");
      });
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
