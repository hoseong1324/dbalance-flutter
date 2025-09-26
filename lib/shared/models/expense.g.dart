// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: (json['id'] as num).toInt(),
  roomId: (json['roomId'] as num).toInt(),
  roundId: (json['roundId'] as num).toInt(),
  payerParticipantId: (json['payerParticipantId'] as num).toInt(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  currency: json['currency'] as String?,
  memo: json['memo'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'roomId': instance.roomId,
  'roundId': instance.roundId,
  'payerParticipantId': instance.payerParticipantId,
  'totalAmount': instance.totalAmount,
  'currency': instance.currency,
  'memo': instance.memo,
  'items': instance.items,
};

ExpenseItem _$ExpenseItemFromJson(Map<String, dynamic> json) => ExpenseItem(
  id: (json['id'] as num).toInt(),
  expenseId: (json['expenseId'] as num).toInt(),
  category: json['category'] as String,
  amount: (json['amount'] as num).toDouble(),
  participantsOverride: (json['participantsOverride'] as List<dynamic>?)
      ?.map((e) => ParticipantOverride.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ExpenseItemToJson(ExpenseItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'expenseId': instance.expenseId,
      'category': instance.category,
      'amount': instance.amount,
      'participantsOverride': instance.participantsOverride,
    };

ParticipantOverride _$ParticipantOverrideFromJson(Map<String, dynamic> json) =>
    ParticipantOverride(
      participantId: (json['participantId'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
    );

Map<String, dynamic> _$ParticipantOverrideToJson(
  ParticipantOverride instance,
) => <String, dynamic>{
  'participantId': instance.participantId,
  'weight': instance.weight,
};
