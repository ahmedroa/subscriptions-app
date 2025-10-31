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
        ],
      ),
      body: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
        buildWhen: (previous, current) {
          // دائماً نحدث إذا تغير نوع الـ state
          if (previous.runtimeType != current.runtimeType) return true;

          if (current is SubscriptionsLoaded && previous is SubscriptionsLoaded) {
            // تحديث عند تغيير عدد الاشتراكات أو المجموع
            if (previous.subscriptions.length != current.subscriptions.length ||
                previous.totalMonthly != current.totalMonthly) {
              return true;
            }

            // إنشاء خريطة للاشتراكات السابقة حسب ID للمقارنة الصحيحة
            final previousMap = {for (var sub in previous.subscriptions) sub.id: sub};

            // تحديث عند تغيير أي تفاصيل في الاشتراكات
            for (var currentSub in current.subscriptions) {
              final prevSub = previousMap[currentSub.id];
              if (prevSub != null) {
                // تحقق من تغيير التاريخ أو حالة الدفع أو المبلغ
                if (prevSub.nextPaymentDate != currentSub.nextPaymentDate ||
                    prevSub.isPaid != currentSub.isPaid ||
                    prevSub.amount != currentSub.amount ||
                    prevSub.serviceName != currentSub.serviceName) {
                  return true;
                }
              } else {
                return true;
              }
            }

            // تحديث إذا تغير ترتيب الاشتراكات (مهم جداً!)
            if (previous.subscriptions.length == current.subscriptions.length) {
              for (int i = 0; i < current.subscriptions.length; i++) {
                if (current.subscriptions[i].id != previous.subscriptions[i].id) {
                  return true; // الترتيب تغير
                }
              }
            }

            // لا يوجد تغيير
            return false;
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
