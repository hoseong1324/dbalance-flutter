// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Participant _$ParticipantFromJson(Map<String, dynamic> json) => Participant(
  id: (json['id'] as num).toInt(),
  displayName: json['displayName'] as String,
  defaultIsDrinker: json['defaultIsDrinker'] as bool?,
);

Map<String, dynamic> _$ParticipantToJson(Participant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'defaultIsDrinker': instance.defaultIsDrinker,
    };

RoomParticipant _$RoomParticipantFromJson(Map<String, dynamic> json) =>
    RoomParticipant(
      id: (json['id'] as num).toInt(),
      roomId: (json['roomId'] as num).toInt(),
      participantId: (json['participantId'] as num).toInt(),
      attendWeight: (json['attendWeight'] as num).toDouble(),
      isDrinker: json['isDrinker'] as bool?,
    );

Map<String, dynamic> _$RoomParticipantToJson(RoomParticipant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'participantId': instance.participantId,
      'attendWeight': instance.attendWeight,
      'isDrinker': instance.isDrinker,
    };
