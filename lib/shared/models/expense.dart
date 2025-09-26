import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense {
  final int id;
  final int roomId;
  final int roundId;
  final int payerParticipantId;
  final double totalAmount;
  final String? currency;
  final String? memo;
  final List<ExpenseItem> items;

  const Expense({
    required this.id,
    required this.roomId,
    required this.roundId,
    required this.payerParticipantId,
    required this.totalAmount,
    this.currency,
    this.memo,
    required this.items,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}

@JsonSerializable()
class ExpenseItem {
  final int id;
  final int expenseId;
  final String category;
  final double amount;
  final List<ParticipantOverride>? participantsOverride;

  const ExpenseItem({
    required this.id,
    required this.expenseId,
    required this.category,
    required this.amount,
    this.participantsOverride,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => _$ExpenseItemFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseItemToJson(this);
}

@JsonSerializable()
class ParticipantOverride {
  final int participantId;
  final double weight;

  const ParticipantOverride({
    required this.participantId,
    required this.weight,
  });

  factory ParticipantOverride.fromJson(Map<String, dynamic> json) => _$ParticipantOverrideFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipantOverrideToJson(this);
}
