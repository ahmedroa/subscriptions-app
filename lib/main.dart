import 'package:flutter/material.dart';
import 'package:subscriptions_app/home/logic/cubit.dart';
import 'package:subscriptions_app/home/model/subscription_model.dart';
import 'package:subscriptions_app/home/repo/subscription_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:subscriptions_app/core/services/notification_service.dart';
import 'package:subscriptions_app/core/services/notification_log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subscriptions_app/home/ui/widgets/bottom_nav_bar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ar_SA', null);

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));

  await NotificationService.initialize();
  await NotificationService.requestPermissions();

  // تعيين وقت التذكيرات الافتراضي إلى 8:28 صباحاً
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('notification_hour')) {
    await prefs.setInt('notification_hour', 8); // 8 AM
    await prefs.setInt('notification_minute', 28); // 28 دقيقة
    print('✅ تم تعيين وقت التذكيرات الافتراضي إلى 8:28 صباحاً');
  }

  await _clearAllHiveData();

  await Hive.initFlutter();

  Hive.registerAdapter(SubscriptionModelAdapter());

  await NotificationLogService.init();

  final repository = SubscriptionRepository();
  await repository.init();

  runApp(MyApp(repository: repository));
}

Future<void> _clearAllHiveData() async {
  try {
    await Hive.close();

    // احذف صندوق الاشتراكات تحديداً
    await Hive.deleteBoxFromDisk('subscriptions');

    print('تم مسح بيانات Hive بنجاح');
  } catch (e) {
    // تجاهل الأخطاء في الحذف
    print('تم مسح بيانات Hive: $e');
  }
}

class MyApp extends StatelessWidget {
  final SubscriptionRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionsCubit(repository)..loadSubscriptions(),
      child: MaterialApp(
        title: 'ذكّرني',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, scaffoldBackgroundColor: Colors.grey[50], fontFamily: 'Cairo'),
        locale: const Locale('ar', 'SA'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
        // home: const OnboardingPage(),
        home: const BottomNavBar(),
      ),
    );
  }
}
