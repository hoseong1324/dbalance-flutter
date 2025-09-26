import 'package:json_annotation/json_annotation.dart';

part 'session.g.dart';

@JsonSerializable()
class Session {
  final String sessionToken;
  final String? recoveryCode;
  final String? expiresAt;

  const Session({
    required this.sessionToken,
    this.recoveryCode,
    this.expiresAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
  Map<String, dynamic> toJson() => _$SessionToJson(this);
}
