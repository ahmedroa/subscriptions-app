import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subscriptions_app/home/logic/cubit.dart';
import 'package:subscriptions_app/home/logic/state.dart';
import 'package:subscriptions_app/core/services/notification_service.dart';
import 'package:subscriptions_app/core/theme/color.dart';
import 'package:subscriptions_app/home/ui/screen/privacy_policy_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TimeOfDay _notificationTime = const TimeOfDay(hour: 20, minute: 0); // 8:00 PM افتراضي
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationTime();
  }

  Future<void> _loadNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('notification_hour') ?? 20; // 8 PM افتراضي
    final minute = prefs.getInt('notification_minute') ?? 0;

    setState(() {
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
      _isLoading = false;
    });
  }

  Future<void> _saveNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', time.hour);
    await prefs.setInt('notification_minute', time.minute);

    setState(() {
      _notificationTime = time;
    });

    // إعادة جدولة التنبيهات بالوقت الجديد
    final cubit = context.read<SubscriptionsCubit>();
    if (cubit.state is SubscriptionsLoaded) {
      final state = cubit.state as SubscriptionsLoaded;
      await NotificationService.updateNotificationTimeAndReschedule(state.subscriptions);
    }
  }

  Future<void> _selectNotificationTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          child: Directionality(textDirection: TextDirection.rtl, child: child!),
        );
      },
    );

    if (picked != null && picked != _notificationTime) {
      await _saveNotificationTime(picked);

      // إظهار رسالة تأكيد
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حفظ وقت التنبيه: ${_formatTime(picked)}'), backgroundColor: Colors.green),
        );
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'مساءً' : 'صباحاً';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: ColorsManager.backgroundColor,
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(color: Colors.white)),
        backgroundColor: ColorsManager.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // قسم التنبيهات
          Container(
            decoration: BoxDecoration(color: ColorsManager.containerColorDark, borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _selectNotificationTime,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorsManager.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Color(0xFF6366F1)),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'وقت التنبيه',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatTime(_notificationTime),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, color: Color(0xFF6366F1), size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()));
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorsManager.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.privacy_tip, color: Color(0xFF6366F1)),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'سياسة الخصوصية',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Color(0xFF6366F1), size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
