import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:httpcallapi/models/login_request.dart';
import 'package:httpcallapi/services/env_service.dart';

import '../pages/post_page.dart';

// Events

abstract class LoginEvent {}

class UsernameChanged extends LoginEvent {
  final String username;

  UsernameChanged(this.username);
}

class PasswordChanged extends LoginEvent {
  final String password;

  PasswordChanged(this.password);
}

class LoginButtonPressed extends LoginEvent {
  final BuildContext context;

  LoginButtonPressed(this.context);
}

// States

abstract class LoginState {}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {
  final String successMessage;

  LoginSuccessState(this.successMessage);
}

class LoginErrorState extends LoginState {
  final String errorMessage;

  LoginErrorState(this.errorMessage);
}

// BLoC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginRequest loginData = LoginRequest(username: '', password: '');

  LoginBloc() : super(LoginInitialState()) {
    on<UsernameChanged>((event, emit) {
      loginData = loginData.copyWith(username: event.username);
    });

    on<PasswordChanged>((event, emit) {
      loginData = loginData.copyWith(password: event.password);
    });

    on<LoginButtonPressed>((event, emit) async {
      final url = Uri.parse('${EnvService.baseUrl}/auth/login');

      try {
        final response = await http.post(url,
            headers: EnvService.httpOptions,
            body: jsonEncode({
              'username': loginData.username,
              'password': loginData.password
            }));
        // await Future.delayed(Duration(seconds: 1));

        if (response.statusCode == 200) {
          emit(LoginSuccessState('${response.body}'));
          _showSuccessDialog(event.context, 'Sign in success');
        } else {
          emit(LoginErrorState('${response.body}'));
          _showErrorDialog(event.context, response.body);
        }
      } catch (e) {
        emit(LoginErrorState('$e'));
      }
    });
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Successful'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToPostList(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String responseBody) {
    final Map<String, dynamic> responseMap = jsonDecode(responseBody);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Failed'),
          content: Text(responseMap['message'] ?? 'Unknown error'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPostList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostPage()),
    );
  }
}
