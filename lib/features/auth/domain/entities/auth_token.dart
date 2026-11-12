import 'package:equatable/equatable.dart';

/// Domain entity representing JWT access and refresh credentials.
class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.tokenType = 'bearer',
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn, tokenType];
}

