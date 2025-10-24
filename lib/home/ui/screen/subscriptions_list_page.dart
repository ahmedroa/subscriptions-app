import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:subscriptions_app/core/widgets/app_text_form_field.dart';
import 'package:subscriptions_app/core/widgets/subscriptions_list_widget.dart';
import 'package:subscriptions_app/home/logic/cubit.dart';
import 'package:subscriptions_app/home/logic/state.dart';
import 'package:subscriptions_app/home/model/subscription_model.dart';
import 'package:subscriptions_app/core/theme/color.dart';

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
                  return _buildSubscriptionsList(filteredSubscriptions);
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
      padding: const EdgeInsets.all(16),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        return SubscriptionCard(subscription: subscription, onTap: () {}, onPaymentTap: () {});
      },
    );
  }
}
