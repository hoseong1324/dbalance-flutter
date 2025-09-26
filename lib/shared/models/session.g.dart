// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session _$SessionFromJson(Map<String, dynamic> json) => Session(
  sessionToken: json['sessionToken'] as String,
  recoveryCode: json['recoveryCode'] as String?,
  expiresAt: json['expiresAt'] as String?,
);

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
  'sessionToken': instance.sessionToken,
  'recoveryCode': instance.recoveryCode,
  'expiresAt': instance.expiresAt,
};
