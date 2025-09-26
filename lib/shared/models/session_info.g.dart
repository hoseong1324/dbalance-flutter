// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionInfo _$SessionInfoFromJson(Map<String, dynamic> json) => SessionInfo(
  sessionToken: json['sessionToken'] as String,
  recoveryCode: json['recoveryCode'] as String?,
  expiresAt: json['expiresAt'] as String?,
);

Map<String, dynamic> _$SessionInfoToJson(SessionInfo instance) =>
    <String, dynamic>{
      'sessionToken': instance.sessionToken,
      'recoveryCode': instance.recoveryCode,
      'expiresAt': instance.expiresAt,
    };
