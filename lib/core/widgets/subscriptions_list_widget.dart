import 'package:flutter/material.dart';
import 'package:subscriptions_app/home/model/subscription_model.dart';
import 'package:subscriptions_app/home/ui/screen/add_subscription_page.dart';
import 'package:subscriptions_app/core/utils/payment_utils.dart';
import 'package:subscriptions_app/core/theme/color.dart';

class SubscriptionsListWidget extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;

  const SubscriptionsListWidget({super.key, required this.subscriptions});

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





class SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscription;
  final VoidCallback? onTap;
  final VoidCallback? onPaymentTap;

  const SubscriptionCard({super.key, required this.subscription, this.onTap, this.onPaymentTap});

  @override
  Widget build(BuildContext context) {
    final daysRemaining = subscription.daysRemaining;
    final isOverdue = daysRemaining < 0;
    final isDueSoon = daysRemaining <= subscription.reminderDays && daysRemaining >= 0;

    Color accentColor = Colors.blue;

    if (isOverdue) {
      accentColor = Colors.red;
    } else if (isDueSoon) {
      accentColor = Colors.orange;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(color: ColorsManager.containerColorDark, borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Leading Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.payment, color: accentColor, size: 28),
                ),
                const SizedBox(width: 16),

                // Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subscription.serviceName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          if (subscription.isPaid)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'مدفوع',
                                style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${subscription.amount.toStringAsFixed(2)} ريال',
                        style: TextStyle(color: accentColor, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOverdue
                            ? 'متأخر ${daysRemaining.abs()} يوم'
                            : daysRemaining == 0
                            ? 'اليوم'
                            : 'باقي $daysRemaining يوم',
                        style: TextStyle(
                          color: isOverdue
                              ? Colors.red
                              : isDueSoon
                              ? Colors.orange.shade700
                              : Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الدفع القادم: ${_formatDate(subscription.nextPaymentDate)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Trailing Action
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        subscription.isPaid ? Icons.check_circle : Icons.check_circle_outline,
                        color: subscription.isPaid ? Colors.green : accentColor,
                        size: 32,
                      ),
                      onPressed: subscription.isPaid ? null : onPaymentTap,
                    ),
                    if (subscription.isPaid)
                      const Text(
                        'تم الدفع',
                        style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
