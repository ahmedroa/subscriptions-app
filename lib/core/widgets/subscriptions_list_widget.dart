import 'package:flutter/material.dart';
import 'package:subscriptions_app/home/model/subscription_model.dart';
import 'package:subscriptions_app/home/ui/screen/add_subscription_page.dart';
import 'package:subscriptions_app/core/utils/payment_utils.dart';
import 'package:subscriptions_app/core/theme/color.dart';

class SubscriptionsListWidget extends StatefulWidget {
  final List<SubscriptionModel> subscriptions;

  const SubscriptionsListWidget({super.key, required this.subscriptions});

  @override
  State<SubscriptionsListWidget> createState() => _SubscriptionsListWidgetState();
}

class _SubscriptionsListWidgetState extends State<SubscriptionsListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = widget.subscriptions[index];
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: SubscriptionCard(
            key: ValueKey(subscription.id + subscription.nextPaymentDate.toString() + subscription.isPaid.toString()),
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

class SubscriptionCard extends StatefulWidget {
  final SubscriptionModel subscription;
  final VoidCallback? onTap;
  final VoidCallback? onPaymentTap;

  const SubscriptionCard({super.key, required this.subscription, this.onTap, this.onPaymentTap});

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SubscriptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // إذا تغيرت حالة isPaid، نشغل animation
    if (oldWidget.subscription.isPaid != widget.subscription.isPaid) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysRemaining = widget.subscription.daysRemaining;
    final isOverdue = daysRemaining < 0;
    final isDueSoon = daysRemaining <= widget.subscription.reminderDays && daysRemaining >= 0;

    Color accentColor = Colors.blue;

    if (isOverdue) {
      accentColor = Colors.red;
    } else if (isDueSoon) {
      accentColor = Colors.orange;
    }

    // إذا كان مدفوع، نغير اللون إلى أخضر
    if (widget.subscription.isPaid) {
      accentColor = Colors.green;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            color: ColorsManager.containerColorDark,
            borderRadius: BorderRadius.circular(12),
            border: widget.subscription.isPaid ? Border.all(color: Colors.green.withOpacity(0.3), width: 2) : null,
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Leading Icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
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
                                widget.subscription.serviceName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: widget.subscription.isPaid
                                  ? Container(
                                      key: const ValueKey('paid'),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'مدفوع',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(key: ValueKey('not_paid')),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(color: accentColor, fontWeight: FontWeight.w600, fontSize: 14),
                          child: Text('${widget.subscription.amount.toStringAsFixed(2)} ريال'),
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
                          'الدفع القادم: ${_formatDate(widget.subscription.nextPaymentDate)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  // Trailing Action
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Column(
                      key: ValueKey(widget.subscription.isPaid),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            widget.subscription.isPaid ? Icons.check_circle : Icons.check_circle_outline,
                            color: widget.subscription.isPaid ? Colors.green : accentColor,
                            size: 32,
                          ),
                          onPressed: widget.subscription.isPaid ? null : widget.onPaymentTap,
                        ),
                        if (widget.subscription.isPaid)
                          const Text(
                            'تم الدفع',
                            style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
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
