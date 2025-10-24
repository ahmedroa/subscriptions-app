import 'package:flutter/material.dart';
import 'package:subscriptions_app/home/model/subscription_model.dart';

class SummaryCard extends StatelessWidget {
  final List<SubscriptionModel> subscriptions;
  final double totalMonthly;

  const SummaryCard({super.key, required this.subscriptions, required this.totalMonthly});

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final List<SubscriptionModel> upcomingPayments =
        subscriptions.where((SubscriptionModel sub) => sub.nextPaymentDate.isAfter(now)).toList()
          ..sort((SubscriptionModel a, SubscriptionModel b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));

    final SubscriptionModel? nextPayment = upcomingPayments.isNotEmpty ? upcomingPayments.first : null;
    final double nextPaymentAmount = nextPayment?.amount ?? 0.0;
    final int nextPaymentDays = nextPayment != null ? nextPayment.daysRemaining : 0;

    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: const EdgeInsets.all(20),
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
      // decoration: BoxDecoration(
      //   gradient: const LinearGradient(
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //     colors: [Color(0xFF1F2937), Color(0xFF374151)],
      //   ),
      //   borderRadius: BorderRadius.circular(24),
      //   boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إجمالي المصروفات الشهرية',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '${totalMonthly.toStringAsFixed(0)} ريال',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatItem(
                  icon: Icons.payment,
                  title: 'الدفعة القادمة',
                  value: '${nextPaymentAmount.toStringAsFixed(0)} ر.س',
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  icon: Icons.schedule,
                  title: 'متبقي',
                  value: nextPaymentDays > 0 ? '$nextPaymentDays ${nextPaymentDays == 1 ? 'يوم' : 'أيام'}' : 'اليوم',
                  color: nextPaymentDays <= 3 ? Colors.orange : Colors.white,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: _StatItem(
                  icon: Icons.subscriptions,
                  title: 'عدد الاشتراكات',
                  value: '${subscriptions.length}',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatItem({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: color.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
