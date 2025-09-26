import 'package:json_annotation/json_annotation.dart';

part 'session_info.g.dart';

@JsonSerializable()
class SessionInfo {
  final String sessionToken;
  final String? recoveryCode;
  final String? expiresAt;

  const SessionInfo({
    required this.sessionToken,
    this.recoveryCode,
    this.expiresAt,
  });

  factory SessionInfo.fromJson(Map<String, dynamic> json) => _$SessionInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SessionInfoToJson(this);
}
