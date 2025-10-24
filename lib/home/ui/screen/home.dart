import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:subscriptions_app/core/theme/color.dart';
import 'package:subscriptions_app/home/logic/cubit.dart';
import 'package:subscriptions_app/home/logic/state.dart';
import 'package:subscriptions_app/home/ui/screen/add_subscription_page.dart';
import 'package:subscriptions_app/home/ui/screen/subscriptions_list_page.dart';
import 'package:subscriptions_app/home/ui/screen/settings_page.dart';
import 'package:subscriptions_app/home/ui/widgets/summary_card.dart';
import 'package:subscriptions_app/core/widgets/empty_state_widget.dart';
import 'package:subscriptions_app/home/ui/widgets/subscriptions_list_widget.dart';
import 'package:subscriptions_app/core/services/notification_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorsManager.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('ذكّرني', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionsListPage()));
            },
            tooltip: 'عرض جميع الاشتراكات',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              _handleSortOption(context, value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'date', child: Text('ترتيب حسب التاريخ')),
              const PopupMenuItem(value: 'amount', child: Text('ترتيب حسب المبلغ')),
              const PopupMenuItem(value: 'name', child: Text('ترتيب حسب الاسم')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              try {
                await NotificationService.showTestNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال إشعار تجريبي - تحقق من الإشعارات'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في الإشعارات: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
            tooltip: 'اختبار الإشعارات',
          ),
          IconButton(
            icon: const Icon(Icons.notification_important),
            onPressed: () async {
              try {
                await NotificationService.showSimpleNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال إشعار بسيط'),
                    backgroundColor: Colors.blue,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في الإشعار البسيط: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            tooltip: 'إشعار بسيط',
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () async {
              try {
                await NotificationService.showImmediateNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال إشعار فوري'),
                    backgroundColor: Colors.purple,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في الإشعار الفوري: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            tooltip: 'إشعار فوري',
          ),
          IconButton(
            icon: const Icon(Icons.settings_applications),
            onPressed: () async {
              try {
                await NotificationService.checkSystemSettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم فحص إعدادات النظام - تحقق من الكونسول'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في فحص النظام: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            tooltip: 'فحص النظام',
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () async {
              try {
                await NotificationService.showBasicNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال إشعار أساسي'),
                    backgroundColor: Colors.teal,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في الإشعار الأساسي: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            tooltip: 'إشعار أساسي',
          ),
          IconButton(
            icon: const Icon(Icons.minimize),
            onPressed: () async {
              try {
                await NotificationService.showMinimalNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال إشعار بسيط'),
                    backgroundColor: Colors.indigo,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في الإشعار البسيط: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            tooltip: 'إشعار بسيط',
          ),
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () async {
              try {
                await NotificationService.showRawNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال إشعار خام'),
                    backgroundColor: Colors.brown,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في الإشعار الخام: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            tooltip: 'إشعار خام',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
            },
            tooltip: 'الإعدادات',
          ),
        ],
      ),
      body: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
        buildWhen: (previous, current) {
          if (previous.runtimeType != current.runtimeType) return true;
          if (current is SubscriptionsLoaded && previous is SubscriptionsLoaded) {
            // تحديث عند تغيير عدد الاشتراكات أو المجموع
            if (previous.subscriptions.length != current.subscriptions.length ||
                previous.totalMonthly != current.totalMonthly) {
              return true;
            }

            // تحديث عند تغيير تفاصيل الاشتراكات (مثل مواعيد الدفع)
            for (int i = 0; i < current.subscriptions.length; i++) {
              if (i < previous.subscriptions.length) {
                final prevSub = previous.subscriptions[i];
                final currSub = current.subscriptions[i];
                if (prevSub.id == currSub.id &&
                    (prevSub.nextPaymentDate != currSub.nextPaymentDate || prevSub.isPaid != currSub.isPaid)) {
                  return true;
                }
              }
            }
          }

          return false;
        },
        builder: (context, state) {
          if (state is SubscriptionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SubscriptionsError) {
            return Center(
              child: Text(state.message, style: const TextStyle(color: Colors.red, fontSize: 16)),
            );
          }

          if (state is SubscriptionsLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SummaryCard(subscriptions: state.subscriptions, totalMonthly: state.totalMonthly),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: const Text(
                    'الاشتراكات القادمة',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: state.subscriptions.isEmpty
                      ? EmptyStateWidget(
                          title: 'لا توجد اشتراكات حالياً',
                          subtitle: 'اضغط على الزر أدناه لإضافة اشتراك جديد',
                          icon: Icons.subscriptions_outlined,
                        )
                      : SubscriptionsListWidget(subscriptions: state.subscriptions),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6366F1),

        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSubscriptionPage()));
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة اشتراك'),
      ),
    );
  }

  void _handleSortOption(BuildContext context, String sortType) {
    final cubit = context.read<SubscriptionsCubit>();
    switch (sortType) {
      case 'date':
        cubit.sortSubscriptions('date');
        break;
      case 'amount':
        cubit.sortSubscriptions('amount');
        break;
      case 'name':
        cubit.sortSubscriptions('name');
        break;
    }
  }
}
