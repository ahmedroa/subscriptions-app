import 'package:flutter/material.dart';
import 'package:subscriptions_app/core/widgets/subscriptions_list_widget.dart';
import 'package:subscriptions_app/home/model/subscription_model.dart';
import 'package:subscriptions_app/home/ui/screen/add_subscription_page.dart';
import 'package:subscriptions_app/core/utils/payment_utils.dart';

class SubscriptionsListWidget extends StatefulWidget {
  final List<SubscriptionModel> subscriptions;

  const SubscriptionsListWidget({super.key, required this.subscriptions});

  @override
  State<SubscriptionsListWidget> createState() => _SubscriptionsListWidgetState();
}

class _SubscriptionsListWidgetState extends State<SubscriptionsListWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 900), vsync: this);
    _controller.forward();
  }

  @override
  void didUpdateWidget(SubscriptionsListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.subscriptions.length != oldWidget.subscriptions.length) {
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
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 80, // مساحة للـ FloatingActionButton
      ),
      physics: const ClampingScrollPhysics(),
      itemCount: widget.subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = widget.subscriptions[index];

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 60).clamp(0, 300)),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(offset: Offset(0, 15 * (1 - value)), child: child),
            );
          },
          child: SubscriptionCard(
            subscription: subscription,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddSubscriptionPage(subscription: subscription)),
              );
            },
            onPaymentTap: () {
              PaymentUtils.showPaymentConfirmation(context, subscription);
            },
          ),
        );
      },
    );
  }
}
