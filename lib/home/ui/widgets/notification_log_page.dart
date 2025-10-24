import 'package:flutter/material.dart';
import 'package:subscriptions_app/core/models/notification_model.dart';
import 'package:subscriptions_app/core/services/notification_log_service.dart';
import 'package:subscriptions_app/core/theme/color.dart';
import 'package:intl/intl.dart';

class NotificationLogPage extends StatefulWidget {
  const NotificationLogPage({super.key});

  @override
  State<NotificationLogPage> createState() => _NotificationLogPageState();
}

class _NotificationLogPageState extends State<NotificationLogPage> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'الكل';
  final List<String> _filterOptions = ['الكل', 'غير مقروء', 'تذكير', 'استحقاق', 'متأخر'];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await NotificationLogService.getAllNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تحميل الإشعارات: $e')));
      }
    }
  }

  List<NotificationModel> _getFilteredNotifications() {
    switch (_selectedFilter) {
      case 'غير مقروء':
        return _notifications.where((n) => !n.isRead).toList();
      case 'تذكير':
        return _notifications.where((n) => n.type == 'reminder').toList();
      case 'استحقاق':
        return _notifications.where((n) => n.type == 'payment_due').toList();
      case 'متأخر':
        return _notifications.where((n) => n.type == 'overdue').toList();
      default:
        return _notifications;
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isRead) {
      await NotificationLogService.markAsRead(notification.id);
      await _loadNotifications();
    }
  }

  Future<void> _markAllAsRead() async {
    await NotificationLogService.markAllAsRead();
    await _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تمييز جميع الإشعارات كمقروءة')));
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorsManager.containerColorDark,
        title: const Text('حذف الإشعار', style: TextStyle(color: Colors.white)),
        content: const Text('هل تريد حذف هذا الإشعار؟', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await NotificationLogService.deleteNotification(notification.id);
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الإشعار')));
      }
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'reminder':
        return Colors.blue;
      case 'payment_due':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'reminder':
        return Icons.notifications_active;
      case 'payment_due':
        return Icons.payment;
      case 'overdue':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationTypeText(String type) {
    switch (type) {
      case 'reminder':
        return 'تذكير';
      case 'payment_due':
        return 'استحقاق';
      case 'overdue':
        return 'متأخر';
      default:
        return 'إشعار';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('icon/logo.png', width: 24, height: 24),
            const SizedBox(width: 8),
            const Text('سجل الإشعارات'),
          ],
        ),
        backgroundColor: ColorsManager.backgroundColor,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            IconButton(icon: const Icon(Icons.done_all), onPressed: _markAllAsRead, tooltip: 'تمييز الكل كمقروء'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadNotifications, tooltip: 'تحديث'),
        ],
      ),
      body: Column(
        children: [
          // فلاتر الإشعارات
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: ColorsManager.containerColorDark),
            child: Row(
              children: [
                const Text('فلتر:', style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    dropdownColor: ColorsManager.containerColorDark,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: ColorsManager.backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _filterOptions.map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Text(filter, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // قائمة الإشعارات
          Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildNotificationsList()),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    final filteredNotifications = _getFilteredNotifications();

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedFilter == 'الكل' ? Icons.notifications_off : Icons.filter_alt_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'الكل' ? 'لا توجد إشعارات' : 'لا توجد إشعارات مطابقة للفلتر',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            if (_selectedFilter != 'الكل')
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'الكل';
                  });
                },
                child: const Text('عرض جميع الإشعارات', style: TextStyle(color: Colors.blue)),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final notificationColor = _getNotificationColor(notification.type);
    final notificationIcon = _getNotificationIcon(notification.type);
    final typeText = _getNotificationTypeText(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColorsManager.containerColorDark,
        borderRadius: BorderRadius.circular(12),
        border: notification.isRead ? null : Border.all(color: notificationColor, width: 2),
      ),
      child: InkWell(
        onTap: () => _markAsRead(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // أيقونة الإشعار
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: notificationColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(notificationIcon, color: notificationColor, size: 28),
              ),
              const SizedBox(width: 16),

              // محتوى الإشعار
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: notificationColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            typeText,
                            style: TextStyle(color: notificationColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(color: notification.isRead ? Colors.white70 : Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الاشتراك: ${notification.subscriptionName}',
                      style: const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تم الإرسال: ${_formatDateTime(notification.sentDate)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    if (notification.scheduledDate != notification.sentDate)
                      Text(
                        'مجدول: ${_formatDateTime(notification.scheduledDate)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                  ],
                ),
              ),

              // أزرار الإجراءات
              Column(
                children: [
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: notificationColor, shape: BoxShape.circle),
                    ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _deleteNotification(notification),
                    tooltip: 'حذف الإشعار',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
