import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:subscriptions_app/core/theme/color.dart';
import 'package:subscriptions_app/home/logic/cubit.dart';
import 'package:subscriptions_app/home/logic/state.dart';
import 'package:subscriptions_app/home/model/subscription_model.dart';
import 'package:subscriptions_app/home/ui/screen/add_subscription_page.dart';
import 'package:subscriptions_app/home/ui/widgets/subscriptions_list_widget.dart';
import 'package:subscriptions_app/home/ui/widgets/summary_card.dart';
import 'package:subscriptions_app/core/widgets/empty_state_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorsManager.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('اشتراكاتي', style: TextStyle(color: Colors.white)),
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

            if (previous.subscriptions.length == current.subscriptions.length) {
              for (int i = 0; i < current.subscriptions.length; i++) {
                if (current.subscriptions[i].id != previous.subscriptions[i].id) {
                  return true;
                }
              }
            }

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
            return _AnimatedHomeContent(subscriptions: state.subscriptions, totalMonthly: state.totalMonthly);
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

class _AnimatedHomeContent extends StatefulWidget {
  final List<SubscriptionModel> subscriptions;
  final double totalMonthly;

  const _AnimatedHomeContent({required this.subscriptions, required this.totalMonthly});

  @override
  State<_AnimatedHomeContent> createState() => _AnimatedHomeContentState();
}

class _AnimatedHomeContentState extends State<_AnimatedHomeContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _summaryAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _listAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);

    _summaryAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    );

    _titleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.7, curve: Curves.easeInOut),
    );

    _listAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedHomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.subscriptions.length != oldWidget.subscriptions.length ||
        widget.totalMonthly != oldWidget.totalMonthly) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: _summaryAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.15),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: _summaryAnimation, curve: Curves.easeInOut)),
            child: SummaryCard(subscriptions: widget.subscriptions, totalMonthly: widget.totalMonthly),
          ),
        ),
        FadeTransition(
          opacity: _titleAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: _titleAnimation, curve: Curves.easeInOut)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: const Text(
                'الاشتراكات القادمة',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Expanded(
          child: FadeTransition(
            opacity: _listAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: _listAnimation, curve: Curves.easeInOut)),
              child: widget.subscriptions.isEmpty
                  ? EmptyStateWidget(
                      title: 'لا توجد اشتراكات حالياً',
                      subtitle: 'اضغط على الزر أدناه لإضافة اشتراك جديد',
                      icon: Icons.subscriptions_outlined,
                    )
                  : SubscriptionsListWidget(subscriptions: widget.subscriptions),
            ),
          ),
        ),
      ],
    );
  }
}
