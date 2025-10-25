import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:subscriptions_app/home/model/subscription_model.dart';
import 'package:subscriptions_app/core/models/notification_model.dart';
import 'package:subscriptions_app/core/services/notification_log_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(settings);
  }

  static Future<void> requestPermissions() async {
    try {
      print('🔐 Requesting notification permissions...');

      // طلب صلاحيات الإشعارات لـ Android
      final androidResult = await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      print('📱 Android permissions result: $androidResult');

      // طلب صلاحيات الإشعارات لـ iOS
      final iosResult = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      print('🍎 iOS permissions result: $iosResult');

      // التحقق من النتائج
      if (androidResult == true || iosResult == true) {
        print('✅ Permissions granted successfully');
      } else {
        print('⚠️ Permissions may not be granted');
      }
    } catch (e) {
      print('❌ Error requesting permissions: $e');
    }
  }

  static Future<void> scheduleSubscriptionReminder(SubscriptionModel subscription) async {
    // الحصول على وقت التنبيه من الإعدادات
    final prefs = await SharedPreferences.getInstance();
    final notificationHour = prefs.getInt('notification_hour') ?? 20; // 8 PM افتراضي
    final notificationMinute = prefs.getInt('notification_minute') ?? 0;

    // تنبيه قبل الموعد
    final reminderDate = subscription.nextPaymentDate.subtract(Duration(days: subscription.reminderDays));

    // تنبيه في يوم الموعد نفسه
    final dueDate = subscription.nextPaymentDate;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'subscription_reminders',
      'تذكيرات الاشتراكات',
      channelDescription: 'تنبيهات تذكير بمواعيد الاشتراكات',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // جدولة التنبيه قبل الموعد (إذا لم يكن في الماضي)
    if (reminderDate.isAfter(DateTime.now())) {
      final reminderDateTime = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        notificationHour,
        notificationMinute,
      );

      final reminderTitle = 'تذكير بالاشتراك';
      final reminderBody =
          'اشتراك ${subscription.serviceName} يستحق خلال ${subscription.reminderDays} ${subscription.reminderDays == 1 ? 'يوم' : 'أيام'}';

      await _notifications.zonedSchedule(
        subscription.id.hashCode, // استخدام hash كـ ID فريد
        reminderTitle,
        reminderBody,
        _convertToTZDateTime(reminderDateTime),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      // حفظ الإشعار في السجل
      final reminderNotification = NotificationModel(
        id: '${subscription.id}_reminder_${reminderDateTime.millisecondsSinceEpoch}',
        subscriptionId: subscription.id,
        subscriptionName: subscription.serviceName,
        title: reminderTitle,
        body: reminderBody,
        sentDate: DateTime.now(),
        scheduledDate: reminderDateTime,
        isRead: false,
        type: 'reminder',
      );
      await NotificationLogService.addNotification(reminderNotification);
    }

    // جدولة التنبيه في يوم الموعد نفسه
    if (dueDate.isAfter(DateTime.now())) {
      final dueDateTime = DateTime(dueDate.year, dueDate.month, dueDate.day, notificationHour, notificationMinute);

      final dueTitle = 'موعد الدفع';
      final dueBody = 'اشتراك ${subscription.serviceName} يستحق اليوم - ${subscription.amount.toStringAsFixed(0)} ريال';

      await _notifications.zonedSchedule(
        subscription.id.hashCode + 1, // استخدام ID مختلف للتنبيه الثاني
        dueTitle,
        dueBody,
        _convertToTZDateTime(dueDateTime),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      // حفظ الإشعار في السجل
      final dueNotification = NotificationModel(
        id: '${subscription.id}_due_${dueDateTime.millisecondsSinceEpoch}',
        subscriptionId: subscription.id,
        subscriptionName: subscription.serviceName,
        title: dueTitle,
        body: dueBody,
        sentDate: DateTime.now(),
        scheduledDate: dueDateTime,
        isRead: false,
        type: 'payment_due',
      );
      await NotificationLogService.addNotification(dueNotification);
    }
  }

  static Future<void> cancelSubscriptionReminder(String subscriptionId) async {
    // إلغاء التنبيه قبل الموعد
    await _notifications.cancel(subscriptionId.hashCode);
    // إلغاء التنبيه في يوم الموعد
    await _notifications.cancel(subscriptionId.hashCode + 1);

    // حذف إشعارات هذا الاشتراك من السجل
    await NotificationLogService.deleteNotificationsBySubscription(subscriptionId);
  }

  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    // حذف جميع الإشعارات من السجل
    await NotificationLogService.deleteAllNotifications();
  }

  static Future<void> rescheduleAllReminders(List<SubscriptionModel> subscriptions) async {
    await cancelAllReminders();

    for (final subscription in subscriptions) {
      await scheduleSubscriptionReminder(subscription);
    }
  }

  static Future<void> updateNotificationTimeAndReschedule(List<SubscriptionModel> subscriptions) async {
    // إلغاء جميع التنبيهات الحالية
    await cancelAllReminders();

    // إعادة جدولة التنبيهات بالوقت الجديد
    for (final subscription in subscriptions) {
      await scheduleSubscriptionReminder(subscription);
    }
  }

  static Future<bool> areNotificationsEnabled() async {
    // للـ Android
    final androidResult = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    // للـ iOS - نعتبر أن الإشعارات مفعلة إذا لم تكن هناك أخطاء
    if (androidResult != null) {
      return androidResult;
    }

    // للـ iOS - نتحقق من الصلاحيات
    final iosResult = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.checkPermissions();

    if (iosResult != null) {
      return iosResult.isEnabled;
    }

    // إذا لم نتمكن من التحقق، نعتبر أنها مفعلة
    return true;
  }

  static Future<void> showTestNotification() async {
    print('🔔 Starting test notification...');

    try {
      // طلب الصلاحيات أولاً
      print('🔐 Requesting permissions...');
      await requestPermissions();
      print('✅ Permissions requested');

      // التحقق من حالة الإشعارات
      final isEnabled = await areNotificationsEnabled();
      print('📱 Notifications enabled: $isEnabled');

      if (!isEnabled) {
        print('❌ Notifications are disabled!');
        return;
      }

      // إنشاء قناة إشعارات لـ Android
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel',
        'اختبار الإشعارات',
        channelDescription: 'قناة اختبار الإشعارات',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        showWhen: true,
        when: null,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      // إظهار الإشعار فوراً
      print('📤 Sending notification...');
      await _notifications.show(
        999, // ID فريد للاختبار
        '🔔 اختبار الإشعارات',
        'إذا رأيت هذا الإشعار، فالإشعارات تعمل بشكل صحيح! ✅',
        details,
      );

      print('✅ Test notification sent successfully');
    } catch (e) {
      print('❌ Error sending test notification: $e');
    }
  }

  static Future<void> showSimpleNotification() async {
    print('Showing simple notification...');

    // محاولة إرسال إشعار بدون طلب صلاحيات إضافية
    await _notifications.show(
      1000,
      'اختبار بسيط',
      'هذا إشعار بسيط للاختبار',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'simple_channel',
          'إشعارات بسيطة',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
    );
    print('Simple notification sent');
  }

  static Future<void> showImmediateNotification() async {
    print('Showing immediate notification...');

    // إشعار فوري بدون أي تعقيدات
    await _notifications.show(
      2000,
      'إشعار فوري',
      'إذا رأيت هذا، فالإشعارات تعمل!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'immediate_channel',
          'إشعارات فورية',
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
    );
    print('Immediate notification sent');
  }

  static Future<void> checkSystemSettings() async {
    print('Checking system settings...');

    // التحقق من إعدادات Android
    final androidResult = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    print('Android notifications enabled: $androidResult');

    // التحقق من إعدادات iOS
    final iosResult = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.checkPermissions();
    print('iOS permissions: $iosResult');

    // محاولة إرسال إشعار مباشر
    try {
      await _notifications.show(
        9999,
        'فحص النظام',
        'فحص إعدادات الإشعارات',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'system_check',
            'فحص النظام',
            importance: Importance.max,
            priority: Priority.max,
          ),
          iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
        ),
      );
      print('System check notification sent successfully');
    } catch (e) {
      print('System check notification failed: $e');
    }
  }

  static Future<void> showBasicNotification() async {
    print('Showing basic notification...');

    // إشعار أساسي جداً
    await _notifications.show(
      3000,
      'اختبار أساسي',
      'إشعار أساسي',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'basic_channel',
          'إشعارات أساسية',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
    print('Basic notification sent');
  }

  static Future<void> showMinimalNotification() async {
    print('Showing minimal notification...');

    // إشعار بسيط جداً
    await _notifications.show(
      4000,
      'اختبار',
      'اختبار',
      const NotificationDetails(
        android: AndroidNotificationDetails('minimal_channel', 'إشعارات بسيطة'),
        iOS: DarwinNotificationDetails(),
      ),
    );
    print('Minimal notification sent');
  }

  static Future<void> showRawNotification() async {
    print('Showing raw notification...');

    // إشعار خام بدون أي إعدادات
    await _notifications.show(5000, 'RAW', 'RAW TEST', const NotificationDetails());
    print('Raw notification sent');
  }

  static tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.getLocation('Asia/Riyadh'));
  }

  // دالة تشخيص شاملة لحل مشاكل الإشعارات
  static Future<void> diagnoseNotificationIssues() async {
    print('🔍 === تشخيص مشاكل الإشعارات ===');

    try {
      // 1. التحقق من التهيئة
      print('1️⃣ Checking initialization...');
      // محاولة إرسال إشعار بسيط
      await _notifications.show(888, 'اختبار التهيئة', 'اختبار بسيط للتحقق من التهيئة', const NotificationDetails());
      print('✅ Basic notification sent');

      // 2. التحقق من الصلاحيات
      print('2️⃣ Checking permissions...');
      final androidEnabled = await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      print('📱 Android notifications enabled: $androidEnabled');

      final iosPermissions = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      print('🍎 iOS permissions: $iosPermissions');

      // 3. اختبار الإشعارات المعلقة
      print('3️⃣ Checking pending notifications...');
      final pending = await _notifications.pendingNotificationRequests();
      print('📋 Pending notifications count: ${pending.length}');

      // 4. اختبار الإشعارات النشطة (Android فقط)
      print('4️⃣ Checking active notifications...');
      try {
        final active = await _notifications.getActiveNotifications();
        print('🔔 Active notifications count: ${active.length}');
      } catch (e) {
        print('⚠️ Active notifications not supported: $e');
      }

      // 5. اختبار إشعار مع تفاصيل كاملة
      print('5️⃣ Testing full notification...');
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'diagnostic_channel',
        'قناة التشخيص',
        channelDescription: 'قناة لاختبار الإشعارات',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        showWhen: true,
        autoCancel: false,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _notifications.show(777, '🔔 اختبار التشخيص', 'إذا رأيت هذا الإشعار، فكل شيء يعمل بشكل صحيح! ✅', details);

      print('✅ Full notification test completed');
      print('🎉 === انتهى التشخيص ===');
    } catch (e) {
      print('❌ Error during diagnosis: $e');
      print('💡 === نصائح لحل المشكلة ===');
      print('1. تأكد من تفعيل الإشعارات في إعدادات الجهاز');
      print('2. تأكد من تفعيل الإشعارات للتطبيق');
      print('3. تأكد من عدم وجود "Do Not Disturb"');
      print('4. جرب إعادة تشغيل التطبيق');
    }
  }

  // دالة اختبار سريعة للإشعارات
  static Future<void> quickNotificationTest() async {
    print('🚀 Quick notification test...');

    try {
      // إشعار فوري بسيط
      await _notifications.show(
        12345,
        '🔔 اختبار سريع',
        'إذا رأيت هذا الإشعار، فالإشعارات تعمل!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'quick_test',
            'اختبار سريع',
            importance: Importance.max,
            priority: Priority.max,
          ),
          iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
        ),
      );
      print('✅ Quick test notification sent');
    } catch (e) {
      print('❌ Quick test failed: $e');
    }
  }
}
