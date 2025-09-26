// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateGuestSessionRequest _$CreateGuestSessionRequestFromJson(
  Map<String, dynamic> json,
) => CreateGuestSessionRequest(
  deviceFingerprint: json['deviceFingerprint'] as String?,
);

Map<String, dynamic> _$CreateGuestSessionRequestToJson(
  CreateGuestSessionRequest instance,
) => <String, dynamic>{'deviceFingerprint': instance.deviceFingerprint};

CreateGuestSessionResponse _$CreateGuestSessionResponseFromJson(
  Map<String, dynamic> json,
) => CreateGuestSessionResponse(
  sessionToken: json['sessionToken'] as String,
  recoveryCode: json['recoveryCode'] as String?,
  expiresAt: json['expiresAt'] as String?,
);

Map<String, dynamic> _$CreateGuestSessionResponseToJson(
  CreateGuestSessionResponse instance,
) => <String, dynamic>{
  'sessionToken': instance.sessionToken,
  'recoveryCode': instance.recoveryCode,
  'expiresAt': instance.expiresAt,
};

HeartbeatResponse _$HeartbeatResponseFromJson(Map<String, dynamic> json) =>
    HeartbeatResponse(ok: json['ok'] as bool);

Map<String, dynamic> _$HeartbeatResponseToJson(HeartbeatResponse instance) =>
    <String, dynamic>{'ok': instance.ok};

ClaimableSession _$ClaimableSessionFromJson(Map<String, dynamic> json) =>
    ClaimableSession(
      sessionToken: json['sessionToken'] as String,
      lastSeenAt: json['lastSeenAt'] as String?,
      deviceFingerprint: json['deviceFingerprint'] as String?,
    );

Map<String, dynamic> _$ClaimableSessionToJson(ClaimableSession instance) =>
    <String, dynamic>{
      'sessionToken': instance.sessionToken,
      'lastSeenAt': instance.lastSeenAt,
      'deviceFingerprint': instance.deviceFingerprint,
    };

ClaimSessionsRequest _$ClaimSessionsRequestFromJson(
  Map<String, dynamic> json,
) => ClaimSessionsRequest(
  sessionTokens: (json['sessionTokens'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ClaimSessionsRequestToJson(
  ClaimSessionsRequest instance,
) => <String, dynamic>{'sessionTokens': instance.sessionTokens};

ClaimByCodeRequest _$ClaimByCodeRequestFromJson(Map<String, dynamic> json) =>
    ClaimByCodeRequest(recoveryCode: json['recoveryCode'] as String);

Map<String, dynamic> _$ClaimByCodeRequestToJson(ClaimByCodeRequest instance) =>
    <String, dynamic>{'recoveryCode': instance.recoveryCode};

ClaimResponse _$ClaimResponseFromJson(Map<String, dynamic> json) =>
    ClaimResponse(
      ok: json['ok'] as bool,
      claimedCount: (json['claimedCount'] as num).toInt(),
    );

Map<String, dynamic> _$ClaimResponseToJson(ClaimResponse instance) =>
    <String, dynamic>{'ok': instance.ok, 'claimedCount': instance.claimedCount};
