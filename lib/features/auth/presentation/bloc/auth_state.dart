import 'package:equatable/equatable.dart';
import '../../domain/entities/employee_profile.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before session check starts.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during login or initial session restoration.
class AuthLoading extends AuthState {
  final String? message;

  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Successfully authenticated with a verified employee profile.
class Authenticated extends AuthState {
  final EmployeeProfile profile;

  const Authenticated(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Not authenticated (user logged out, session expired, or no saved session).
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Authentication failed with an error message.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

