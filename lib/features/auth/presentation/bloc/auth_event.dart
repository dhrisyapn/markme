import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on app initialization to restore any active session from secure storage.
class AppStarted extends AuthEvent {
  const AppStarted();
}

/// Dispatched when the user submits the login form.
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Dispatched when the user taps logout.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

