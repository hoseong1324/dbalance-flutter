import 'package:json_annotation/json_annotation.dart';
import '../../../shared/models/user.dart';

part 'auth_dto.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  final String? nickname;

  const RegisterRequest({
    required this.email,
    required this.password,
    this.nickname,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class SocialLoginRequest {
  final String provider;
  final String? idToken;
  final String? accessToken;
  final String? device;
  final String? nonce;

  const SocialLoginRequest({
    required this.provider,
    this.idToken,
    this.accessToken,
    this.device,
    this.nonce,
  });

  factory SocialLoginRequest.fromJson(Map<String, dynamic> json) => _$SocialLoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SocialLoginRequestToJson(this);
}

@JsonSerializable()
class RefreshRequest {
  final String refreshToken;

  const RefreshRequest({
    required this.refreshToken,
  });

  factory RefreshRequest.fromJson(Map<String, dynamic> json) => _$RefreshRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  @JsonKey(fromJson: _userFromJson, toJson: _userToJson)
  final User user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  static User _userFromJson(Map<String, dynamic> json) => User.fromJson(json);
  static Map<String, dynamic> _userToJson(User user) => user.toJson();
}
