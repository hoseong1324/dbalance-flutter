import 'package:json_annotation/json_annotation.dart';

part 'session_dto.g.dart';

@JsonSerializable()
class CreateGuestSessionRequest {
  final String? deviceFingerprint;

  const CreateGuestSessionRequest({
    this.deviceFingerprint,
  });

  factory CreateGuestSessionRequest.fromJson(Map<String, dynamic> json) => _$CreateGuestSessionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateGuestSessionRequestToJson(this);
}

@JsonSerializable()
class CreateGuestSessionResponse {
  final String sessionToken;
  final String? recoveryCode;
  final String? expiresAt;

  const CreateGuestSessionResponse({
    required this.sessionToken,
    this.recoveryCode,
    this.expiresAt,
  });

  factory CreateGuestSessionResponse.fromJson(Map<String, dynamic> json) => _$CreateGuestSessionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CreateGuestSessionResponseToJson(this);
}

@JsonSerializable()
class HeartbeatResponse {
  final bool ok;

  const HeartbeatResponse({
    required this.ok,
  });

  factory HeartbeatResponse.fromJson(Map<String, dynamic> json) => _$HeartbeatResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HeartbeatResponseToJson(this);
}

@JsonSerializable()
class ClaimableSession {
  final String sessionToken;
  final String? lastSeenAt;
  final String? deviceFingerprint;

  const ClaimableSession({
    required this.sessionToken,
    this.lastSeenAt,
    this.deviceFingerprint,
  });

  factory ClaimableSession.fromJson(Map<String, dynamic> json) => _$ClaimableSessionFromJson(json);
  Map<String, dynamic> toJson() => _$ClaimableSessionToJson(this);
}

@JsonSerializable()
class ClaimSessionsRequest {
  final List<String> sessionTokens;

  const ClaimSessionsRequest({
    required this.sessionTokens,
  });

  factory ClaimSessionsRequest.fromJson(Map<String, dynamic> json) => _$ClaimSessionsRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ClaimSessionsRequestToJson(this);
}

@JsonSerializable()
class ClaimByCodeRequest {
  final String recoveryCode;

  const ClaimByCodeRequest({
    required this.recoveryCode,
  });

  factory ClaimByCodeRequest.fromJson(Map<String, dynamic> json) => _$ClaimByCodeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ClaimByCodeRequestToJson(this);
}

@JsonSerializable()
class ClaimResponse {
  final bool ok;
  final int claimedCount;

  const ClaimResponse({
    required this.ok,
    required this.claimedCount,
  });

  factory ClaimResponse.fromJson(Map<String, dynamic> json) => _$ClaimResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ClaimResponseToJson(this);
}
