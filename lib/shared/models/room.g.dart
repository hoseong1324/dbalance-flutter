// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  date: json['date'] as String?,
  inviteCode: json['inviteCode'] as String?,
  ownerUserId: (json['ownerUserId'] as num?)?.toInt(),
  ownerSessionId: (json['ownerSessionId'] as num?)?.toInt(),
);

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'date': instance.date,
  'inviteCode': instance.inviteCode,
  'ownerUserId': instance.ownerUserId,
  'ownerSessionId': instance.ownerSessionId,
};

Round _$RoundFromJson(Map<String, dynamic> json) => Round(
  id: (json['id'] as num).toInt(),
  roomId: (json['roomId'] as num).toInt(),
  roundNumber: (json['roundNumber'] as num).toInt(),
  placeName: json['placeName'] as String?,
  memo: json['memo'] as String?,
);

Map<String, dynamic> _$RoundToJson(Round instance) => <String, dynamic>{
  'id': instance.id,
  'roomId': instance.roomId,
  'roundNumber': instance.roundNumber,
  'placeName': instance.placeName,
  'memo': instance.memo,
};
