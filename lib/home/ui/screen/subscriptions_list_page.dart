import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:subscriptions_app/core/widgets/app_text_form_field.dart';
import 'package:subscriptions_app/core/widgets/subscriptions_list_widget.dart';
import 'package:subscriptions_app/home/logic/cubit.dart';
import 'package:subscriptions_app/home/logic/state.dart';
import 'package:subscriptions_app/home/model/subscription_model.dart';
import 'package:subscriptions_app/core/theme/color.dart';
import 'package:subscriptions_app/home/ui/screen/add_subscription_page.dart';
import 'package:subscriptions_app/core/utils/payment_utils.dart';

class SubscriptionsListPage extends StatefulWidget {
  const SubscriptionsListPage({super.key});

  @override
  State<SubscriptionsListPage> createState() => _SubscriptionsListPageState();
}

class _SubscriptionsListPageState extends State<SubscriptionsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedMonth = 'الكل';
  String _sortBy = 'date'; // date, amount, name

  final List<String> _months = [
    'الكل',
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('icon/logo.png', width: 24, height: 24),
            const SizedBox(width: 8),
            const Text('جميع الاشتراكات', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: ColorsManager.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFiltersSection(),
          Expanded(
            child: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
              builder: (context, state) {
                if (state is SubscriptionsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SubscriptionsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<SubscriptionsCubit>().loadSubscriptions(),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                } else if (state is SubscriptionsLoaded) {
                  final filteredSubscriptions = _filterSubscriptions(state.subscriptions);
                  return Column(
                    children: [
                      _buildStatsSection(filteredSubscriptions),
                      Expanded(child: _buildSubscriptionsList(filteredSubscriptions)),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ColorsManager.containerColorDark),
      child: Column(
        children: [
          // شريط البحث
          AppTextFormField(
            controller: _searchController,
            hintText: 'البحث في الاشتراكات...',
            validator: (value) => null, // لا يوجد تحقق مطلوب للبحث
            prefixIcon: const Icon(Icons.search, color: Colors.blue),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 16),
          // فلاتر الشهر والترتيب
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedMonth,
                  dropdownColor: ColorsManager.containerColorDark,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'الشهر',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: ColorsManager.backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _months.map((month) {
                    return DropdownMenuItem(
                      value: month,
                      child: Text(month, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  dropdownColor: ColorsManager.containerColorDark,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'ترتيب حسب',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: ColorsManager.backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'date',
                      child: Text('التاريخ', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 'amount',
                      child: Text('المبلغ', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 'name',
                      child: Text('الاسم', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<SubscriptionModel> _filterSubscriptions(List<SubscriptionModel> subscriptions) {
    List<SubscriptionModel> filtered = subscriptions;

    // فلتر البحث
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((subscription) {
        return subscription.serviceName.toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    }

    // فلتر الشهر
    if (_selectedMonth != 'الكل') {
      final monthIndex = _months.indexOf(_selectedMonth);
      filtered = filtered.where((subscription) {
        return subscription.nextPaymentDate.month == monthIndex;
      }).toList();
    }

    // الترتيب
    switch (_sortBy) {
      case 'date':
        filtered.sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));
        break;
      case 'amount':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'name':
        filtered.sort((a, b) => a.serviceName.compareTo(b.serviceName));
        break;
    }

    return filtered;
  }

  Widget _buildStatsSection(List<SubscriptionModel> subscriptions) {
    final total = subscriptions.fold<double>(0.0, (sum, sub) => sum + sub.amount);
    final paidCount = subscriptions.where((sub) => sub.isPaid).length;
    final unpaidCount = subscriptions.length - paidCount;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إجمالي الاشتراكات المعروضة',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  key: ValueKey(subscriptions.length),
                  '${subscriptions.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.attach_money,
                  label: 'المبلغ الإجمالي',
                  value: '${total.toStringAsFixed(0)} ر.س',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  label: 'مدفوع',
                  value: '$paidCount',
                  color: Colors.green.shade300,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.pending,
                  label: 'غير مدفوع',
                  value: '$unpaidCount',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              key: ValueKey(value),
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsList(List<SubscriptionModel> subscriptions) {
    if (subscriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty || _selectedMonth != 'الكل'
                  ? 'لا توجد نتائج للبحث'
                  : 'لا توجد اشتراكات',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            if (_searchController.text.isNotEmpty || _selectedMonth != 'الكل')
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedMonth = 'الكل';
                  });
                },
                child: const Text('مسح الفلاتر', style: TextStyle(color: Colors.blue)),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation),
                child: child,
              ),
            );
          },
          child: SubscriptionCard(
            key: ValueKey(subscription.id),
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
