import 'package:json_annotation/json_annotation.dart';

part 'participant.g.dart';

@JsonSerializable()
class Participant {
  final int id;
  final String displayName;
  final bool? defaultIsDrinker;

  const Participant({
    required this.id,
    required this.displayName,
    this.defaultIsDrinker,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => _$ParticipantFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipantToJson(this);
}

@JsonSerializable()
class RoomParticipant {
  final int id;
  final int roomId;
  final int participantId;
  final double attendWeight;
  final bool? isDrinker;

  const RoomParticipant({
    required this.id,
    required this.roomId,
    required this.participantId,
    required this.attendWeight,
    this.isDrinker,
  });

  factory RoomParticipant.fromJson(Map<String, dynamic> json) => _$RoomParticipantFromJson(json);
  Map<String, dynamic> toJson() => _$RoomParticipantToJson(this);
}
