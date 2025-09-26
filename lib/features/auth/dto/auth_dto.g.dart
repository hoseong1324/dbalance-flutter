// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      nickname: json['nickname'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'nickname': instance.nickname,
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

SocialLoginRequest _$SocialLoginRequestFromJson(Map<String, dynamic> json) =>
    SocialLoginRequest(
      provider: json['provider'] as String,
      idToken: json['idToken'] as String?,
      accessToken: json['accessToken'] as String?,
      device: json['device'] as String?,
      nonce: json['nonce'] as String?,
    );

Map<String, dynamic> _$SocialLoginRequestToJson(SocialLoginRequest instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'idToken': instance.idToken,
      'accessToken': instance.accessToken,
      'device': instance.device,
      'nonce': instance.nonce,
    };

RefreshRequest _$RefreshRequestFromJson(Map<String, dynamic> json) =>
    RefreshRequest(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$RefreshRequestToJson(RefreshRequest instance) =>
    <String, dynamic>{'refreshToken': instance.refreshToken};

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  user: AuthResponse._userFromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'user': AuthResponse._userToJson(instance.user),
    };
