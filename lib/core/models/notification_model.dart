import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 2)
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subscriptionId;

  @HiveField(2)
  final String subscriptionName;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String body;

  @HiveField(5)
  final DateTime sentDate;

  @HiveField(6)
  final DateTime scheduledDate;

  @HiveField(7)
  final bool isRead;

  @HiveField(8)
  final String type; // 'reminder', 'payment_due', 'overdue'

  NotificationModel({
    required this.id,
    required this.subscriptionId,
    required this.subscriptionName,
    required this.title,
    required this.body,
    required this.sentDate,
    required this.scheduledDate,
    required this.isRead,
    required this.type,
  });

  NotificationModel copyWith({
    String? id,
    String? subscriptionId,
    String? subscriptionName,
    String? title,
    String? body,
    DateTime? sentDate,
    DateTime? scheduledDate,
    bool? isRead,
    String? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      subscriptionName: subscriptionName ?? this.subscriptionName,
      title: title ?? this.title,
      body: body ?? this.body,
      sentDate: sentDate ?? this.sentDate,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'subscriptionName': subscriptionName,
      'title': title,
      'body': body,
      'sentDate': sentDate.millisecondsSinceEpoch,
      'scheduledDate': scheduledDate.millisecondsSinceEpoch,
      'isRead': isRead,
      'type': type,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      subscriptionId: map['subscriptionId'] ?? '',
      subscriptionName: map['subscriptionName'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      sentDate: DateTime.fromMillisecondsSinceEpoch(map['sentDate']),
      scheduledDate: DateTime.fromMillisecondsSinceEpoch(map['scheduledDate']),
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'reminder',
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, subscriptionId: $subscriptionId, subscriptionName: $subscriptionName, title: $title, body: $body, sentDate: $sentDate, scheduledDate: $scheduledDate, isRead: $isRead, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationModel &&
        other.id == id &&
        other.subscriptionId == subscriptionId &&
        other.subscriptionName == subscriptionName &&
        other.title == title &&
        other.body == body &&
        other.sentDate == sentDate &&
        other.scheduledDate == scheduledDate &&
        other.isRead == isRead &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        subscriptionId.hashCode ^
        subscriptionName.hashCode ^
        title.hashCode ^
        body.hashCode ^
        sentDate.hashCode ^
        scheduledDate.hashCode ^
        isRead.hashCode ^
        type.hashCode;
  }
}
