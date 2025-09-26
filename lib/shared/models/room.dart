import 'package:json_annotation/json_annotation.dart';

part 'room.g.dart';

@JsonSerializable()
class Room {
  final int id;
  final String name;
  final String? date;
  final String? inviteCode;
  final int? ownerUserId;
  final int? ownerSessionId;

  const Room({
    required this.id,
    required this.name,
    this.date,
    this.inviteCode,
    this.ownerUserId,
    this.ownerSessionId,
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

  const Round({
    required this.id,
    required this.roomId,
    required this.roundNumber,
    this.placeName,
    this.memo,
  });

  factory Round.fromJson(Map<String, dynamic> json) => _$RoundFromJson(json);
  Map<String, dynamic> toJson() => _$RoundToJson(this);
}
