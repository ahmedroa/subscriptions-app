import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:subscriptions_app/home/model/subscription_model.dart';
import 'package:subscriptions_app/home/logic/cubit.dart';

class PaymentUtils {
  static void showPaymentConfirmation(BuildContext context, SubscriptionModel subscription) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد السداد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تم سداد اشتراك ${subscription.serviceName}؟'),
            const SizedBox(height: 8),
            Text(
              'سيتم تحديث موعد الدفع التالي إلى: ${formatDate(getNextPaymentDate(subscription.nextPaymentDate))}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              await context.read<SubscriptionsCubit>().markAsPaid(subscription);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم تحديث موعد الدفع القادم لـ ${subscription.serviceName}'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('تم السداد'),
          ),
        ],
      ),
    );
  }

  static String formatDate(DateTime date) {
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

  static DateTime getNextPaymentDate(DateTime currentDate) {
    final int newMonth = currentDate.month + 1;
    final int newYear = currentDate.year + ((newMonth - 1) ~/ 12);
    final int normalizedMonth = ((newMonth - 1) % 12) + 1;
    final int lastDayOfTargetMonth = DateTime(newYear, normalizedMonth + 1, 0).day;
    final int targetDay = currentDate.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : currentDate.day;
    return DateTime(
      newYear,
      normalizedMonth,
      targetDay,
      currentDate.hour,
      currentDate.minute,
      currentDate.second,
      currentDate.millisecond,
      currentDate.microsecond,
    );
  }
}
