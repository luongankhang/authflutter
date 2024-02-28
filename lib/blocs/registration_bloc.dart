import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:httpcallapi/pages/login_page.dart';
import 'package:httpcallapi/services/env_service.dart';

import '../models/register_request.dart';

// Events

abstract class RegistrationEvent {}

class UsernameChanged extends RegistrationEvent {
  final String username;

  UsernameChanged(this.username);
}

class PasswordChanged extends RegistrationEvent {
  final String password;

  PasswordChanged(this.password);
}

class RegisterButtonPressed extends RegistrationEvent {
  final BuildContext context;

  RegisterButtonPressed(this.context);
}

// States

abstract class RegistrationState {}

class RegistrationInitialState extends RegistrationState {}

class RegistrationLoadingState extends RegistrationState {}

class RegistrationSuccessState extends RegistrationState {
  final String successMessage;

  RegistrationSuccessState(this.successMessage);
}

class RegistrationErrorState extends RegistrationState {
  final String errorMessage;

  RegistrationErrorState(this.errorMessage);
}

// BLoC
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegisterRequest registrationData =
      RegisterRequest(username: '', password: '');

  RegistrationBloc() : super(RegistrationInitialState()) {
    on<UsernameChanged>((event, emit) {
      registrationData = registrationData.copyWith(username: event.username);
    });

    on<PasswordChanged>((event, emit) {
      registrationData = registrationData.copyWith(password: event.password);
    });

    on<RegisterButtonPressed>((event, emit) async {
      final url = Uri.parse('${EnvService.baseUrl}/auth/register');

      try {
        final response = await http.post(url,
            headers: EnvService.httpOptions,
            body: jsonEncode({
              'username': registrationData.username,
              'password': registrationData.password
            }));
        // await Future.delayed(Duration(seconds: 1));

        if (response.statusCode == 201) {
          emit(RegistrationSuccessState('${response.body}'));
          _showSuccessDialog(event.context, 'Sign up success');
        } else {
          emit(RegistrationErrorState('${response.body}'));
          _showErrorDialog(event.context, response.body);
        }
      } catch (e) {
        emit(RegistrationErrorState('Đăng ký thất bại: $e'));
      }
    });
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration Successful'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToLogin(context);
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
          title: Text('Registration Failed'),
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

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

// @override
// Stream<RegistrationState> mapEventToState(RegistrationEvent event) async* {
//   if (event is UsernameChanged) {
//     registrationData = registrationData.copyWith(username: event.username);
//     print(registrationData);
//   } else if (event is PasswordChanged) {
//     registrationData = registrationData.copyWith(password: event.password);
//   } else if (event is RegisterButtonPressed) {
//     yield RegistrationLoadingState();
//     final url = Uri.parse('${RegisterService.baseUrl}/register');
//     try {
//       final response = await http.post(url,
//           headers: RegisterService.httpOptions,
//           body: jsonEncode({
//             'username': registrationData.username,
//             'password': registrationData.password
//           }));
//       await Future.delayed(Duration(seconds: 1));
//       if (response.statusCode == 201) {
//         yield RegistrationSuccessState('${response.body}');
//       } else {
//         yield RegistrationErrorState('${response.body}');
//       }
//     } catch (e) {
//       yield RegistrationErrorState('Đăng ký thất bại: $e');
//     }
//   }
// }
}
