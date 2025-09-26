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
  ownerUser: (json['ownerUser'] as num?)?.toInt(),
  ownerSession: (json['ownerSession'] as num?)?.toInt(),
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'date': instance.date,
  'inviteCode': instance.inviteCode,
  'ownerUser': instance.ownerUser,
  'ownerSession': instance.ownerSession,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

Round _$RoundFromJson(Map<String, dynamic> json) => Round(
  id: (json['id'] as num).toInt(),
  roomId: (json['roomId'] as num).toInt(),
  roundNumber: (json['roundNumber'] as num).toInt(),
  placeName: json['placeName'] as String?,
  memo: json['memo'] as String?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$RoundToJson(Round instance) => <String, dynamic>{
  'id': instance.id,
  'roomId': instance.roomId,
  'roundNumber': instance.roundNumber,
  'placeName': instance.placeName,
  'memo': instance.memo,
  'createdAt': instance.createdAt,
};
