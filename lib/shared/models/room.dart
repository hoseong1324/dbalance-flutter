import 'package:json_annotation/json_annotation.dart';

part 'room.g.dart';

@JsonSerializable()
class Room {
  final int id;
  final String name;
  final String? date;
  final String? inviteCode;
  final int? ownerUser;
  final int? ownerSession;
  final String? createdAt;
  final String? updatedAt;

  const Room({
    required this.id,
    required this.name,
    this.date,
    this.inviteCode,
    this.ownerUser,
    this.ownerSession,
    this.createdAt,
    this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);
}

@JsonSerializable()
class Round {
  final int id;
  final int roomId;
  final int roundNumber;
  final String? placeName;
  final String? memo;
  final String? createdAt;

  const Round({
    required this.id,
    required this.roomId,
    required this.roundNumber,
    this.placeName,
    this.memo,
    this.createdAt,
  });

  factory Round.fromJson(Map<String, dynamic> json) => _$RoundFromJson(json);
  Map<String, dynamic> toJson() => _$RoundToJson(this);
}