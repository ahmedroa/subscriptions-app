import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 0)
class SubscriptionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String serviceName;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime nextPaymentDate;

  @HiveField(4)
  final int reminderDays;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final bool isPaid;

  @HiveField(7)
  final DateTime createdAt;

  SubscriptionModel({
    required this.id,
    required this.serviceName,
    required this.amount,
    required this.nextPaymentDate,
    required this.reminderDays,
    this.notes,
    this.isPaid = false,
    required this.createdAt,
  });

  SubscriptionModel copyWith({
    String? id,
    String? serviceName,
    double? amount,
    DateTime? nextPaymentDate,
    int? reminderDays,
    String? notes,
    bool? isPaid,
    DateTime? createdAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      amount: amount ?? this.amount,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      reminderDays: reminderDays ?? this.reminderDays,
      notes: notes ?? this.notes,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get daysRemaining {
    final now = DateTime.now();
    final difference = nextPaymentDate.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }
}
