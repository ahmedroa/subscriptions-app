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
import 'package:subscriptions_app/core/ui/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        home: const SplashScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(),
                const SizedBox(height: 24),

                // Monthly Summary Card
                _buildMonthlySummaryCard(context),
                const SizedBox(height: 32),

                // Quick Actions
                _buildQuickActions(context),
                const SizedBox(height: 32),

                // Upcoming Subscriptions Section
                _buildSectionHeader('الاشتراكات القادمة', 'عرض الكل'),
                const SizedBox(height: 16),
                _buildUpcomingSubscriptions(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Header with greeting
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً،',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400], fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 4),
                const Text(
                  'أحمد محمد',
                  style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF374151), borderRadius: BorderRadius.circular(16)),
              child: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF374151), width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Monthly Summary Card with gradient
  Widget _buildMonthlySummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي المصروفات الشهرية',
                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'أكتوبر 2025',
                  style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                '١,٢٥٠',
                style: TextStyle(fontSize: 42, color: Colors.white, fontWeight: FontWeight.bold, height: 1),
              ),
              SizedBox(width: 8),
              Text(
                'ر.س',
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('الاشتراكات النشطة', '8', Icons.subscriptions),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                _buildSummaryItem('قادمة هذا الأسبوع', '3', Icons.event_note),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Quick Actions Grid
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildActionCard('إضافة اشتراك', Icons.add_circle_outline, const Color(0xFF10B981), () {})),
        const SizedBox(width: 12),
        Expanded(child: _buildActionCard('التقارير', Icons.bar_chart_rounded, const Color(0xFFF59E0B), () {})),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF374151),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            actionText,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6366F1), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Upcoming Subscriptions List
  Widget _buildUpcomingSubscriptions() {
    final subscriptions = [
      {'name': 'Netflix', 'amount': '55.99', 'dueDate': 'بعد يومين', 'color': const Color(0xFFE50914), 'icon': '🎬'},
      {'name': 'Spotify', 'amount': '19.99', 'dueDate': 'بعد 5 أيام', 'color': const Color(0xFF1DB954), 'icon': '🎵'},
      {
        'name': 'Adobe Creative Cloud',
        'amount': '239.88',
        'dueDate': 'بعد أسبوع',
        'color': const Color(0xFFFF0000),
        'icon': '🎨',
      },
      {
        'name': 'Shahid VIP',
        'amount': '49.99',
        'dueDate': 'بعد 10 أيام',
        'color': const Color(0xFFFFB800),
        'icon': '📺',
      },
    ];

    return Column(
      children: subscriptions.map((sub) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSubscriptionCard(
            sub['name'] as String,
            sub['amount'] as String,
            sub['dueDate'] as String,
            sub['color'] as Color,
            sub['icon'] as String,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubscriptionCard(String name, String amount, String dueDate, Color brandColor, String emoji) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: brandColor.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 16),

          // Subscription Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(dueDate, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amount ر.س',
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: brandColor.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  'شهري',
                  style: TextStyle(fontSize: 11, color: brandColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Floating Action Button
  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add, size: 24),
        label: const Text('إضافة اشتراك', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
