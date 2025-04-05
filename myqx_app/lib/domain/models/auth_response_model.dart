import 'dart:convert';
import 'package:myqx_app/domain/models/user_model.dart';

class AuthResponse {
  final String token;
  final String? refreshToken;
  final User user;
  
  AuthResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });
  
  AuthResponse copyWith({
    String? token,
    String? refreshToken,
    User? user,
  }) {
    return AuthResponse(
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'refresh_token': refreshToken,
      'user': user.toMap(),
    };
  }

  factory AuthResponse.fromMap(Map<String, dynamic> map) {
    return AuthResponse(
      token: map['token'] ?? '',
      refreshToken: map['refresh_token'],
      user: User.fromMap(map['user'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());
  
  factory AuthResponse.fromJson(String source) => AuthResponse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AuthResponse(token: $token, refreshToken: $refreshToken, user: $user)';
  }
}