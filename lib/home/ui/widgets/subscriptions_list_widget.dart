import 'package:flutter/material.dart';
import 'package:subscriptions_app/core/widgets/subscriptions_list_widget.dart';
import 'package:subscriptions_app/home/model/subscription_model.dart';
import 'package:subscriptions_app/home/ui/screen/add_subscription_page.dart';
import 'package:subscriptions_app/core/utils/payment_utils.dart';

class SubscriptionsListWidget extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;

  const SubscriptionsListWidget({
    super.key,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        return SubscriptionCard(
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
        );
      },
    );
  }
}
