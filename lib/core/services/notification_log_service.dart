import 'package:hive/hive.dart';
import 'package:subscriptions_app/core/models/notification_model.dart';

class NotificationLogService {
  static const String _boxName = 'notifications';
  static Box<NotificationModel>? _box;

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(NotificationModelAdapter());
    }
    _box = await Hive.openBox<NotificationModel>(_boxName);
  }

  static Future<void> addNotification(NotificationModel notification) async {
    if (_box == null) await init();
    await _box!.put(notification.id, notification);
  }

  static Future<List<NotificationModel>> getAllNotifications() async {
    if (_box == null) await init();
    return _box!.values.toList()..sort((a, b) => b.sentDate.compareTo(a.sentDate));
  }

  static Future<List<NotificationModel>> getNotificationsBySubscription(String subscriptionId) async {
    if (_box == null) await init();
    return _box!.values.where((notification) => notification.subscriptionId == subscriptionId).toList()
      ..sort((a, b) => b.sentDate.compareTo(a.sentDate));
  }

  static Future<void> markAsRead(String notificationId) async {
    if (_box == null) await init();
    final notification = _box!.get(notificationId);
    if (notification != null) {
      await _box!.put(notificationId, notification.copyWith(isRead: true));
    }
  }

  static Future<void> markAllAsRead() async {
    if (_box == null) await init();
    final notifications = _box!.values.toList();
    for (final notification in notifications) {
      if (!notification.isRead) {
        await _box!.put(notification.id, notification.copyWith(isRead: true));
      }
    }
  }

  static Future<int> getUnreadCount() async {
    if (_box == null) await init();
    return _box!.values.where((notification) => !notification.isRead).length;
  }

  static Future<void> deleteNotification(String notificationId) async {
    if (_box == null) await init();
    await _box!.delete(notificationId);
  }

  static Future<void> deleteAllNotifications() async {
    if (_box == null) await init();
    await _box!.clear();
  }

  static Future<void> deleteNotificationsBySubscription(String subscriptionId) async {
    if (_box == null) await init();
    final notifications = _box!.values.where((notification) => notification.subscriptionId == subscriptionId).toList();

    for (final notification in notifications) {
      await _box!.delete(notification.id);
    }
  }

  static Future<void> close() async {
    await _box?.close();
  }
}
