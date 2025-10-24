import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:subscriptions_app/core/widgets/app_text_form_field.dart';
import 'package:subscriptions_app/home/logic/cubit.dart';
import 'package:subscriptions_app/home/model/subscription_model.dart';
import 'package:subscriptions_app/core/theme/color.dart';

class AddSubscriptionPage extends StatefulWidget {
  final SubscriptionModel? subscription;

  const AddSubscriptionPage({super.key, this.subscription});

  @override
  State<AddSubscriptionPage> createState() => _AddSubscriptionPageState();
}

class _AddSubscriptionPageState extends State<AddSubscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serviceNameController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late int _selectedReminderDays;

  final List<int> _reminderOptions = [1, 2, 3, 7];

  @override
  void initState() {
    super.initState();
    _serviceNameController = TextEditingController(text: widget.subscription?.serviceName ?? '');
    _amountController = TextEditingController(text: widget.subscription?.amount.toString() ?? '');
    _notesController = TextEditingController(text: widget.subscription?.notes ?? '');
    _selectedDate = widget.subscription?.nextPaymentDate ?? DateTime.now();
    _selectedReminderDays = widget.subscription?.reminderDays ?? 1;
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subscription != null;

    return Scaffold(
      backgroundColor: ColorsManager.backgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل الاشتراك' : 'إضافة اشتراك جديد', style: TextStyle(color: Colors.white)),
        backgroundColor: ColorsManager.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteSubscription,
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextFormField(
              controller: _serviceNameController,
              hintText: 'اسم الخدمة',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم الخدمة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              controller: _amountController,
              hintText: 'المبلغ',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال المبلغ';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),
            AppTextFormField(
              controller: _notesController,
              hintText: 'ملاحظات (اختياري)',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الملاحظات';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: ColorsManager.containerColorDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تاريخ الدفع القادم',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'التذكير قبل موعد الدفع',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _reminderOptions.map((days) {
                final isSelected = _selectedReminderDays == days;
                return ChoiceChip(
                  label: Text(
                    days == 1
                        ? 'يوم واحد'
                        : days == 2
                        ? 'يومين'
                        : days == 3
                        ? '٣ أيام'
                        : 'أسبوع',
                    style: TextStyle(color: isSelected ? Colors.white : Colors.white),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF6366F1),
                  backgroundColor: ColorsManager.containerColorDark,
                  onSelected: (selected) {
                    setState(() {
                      _selectedReminderDays = days;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: ColorsManager.containerColorDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: _notesController,
                // style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  labelStyle: const TextStyle(color: Colors.white),
                  hintText: 'مثال: تغيير طريقة الدفع',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.note, color: Colors.blue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEditing ? 'حفظ التعديلات' : 'إضافة الاشتراك',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: ColorsManager.containerColorDark,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: ColorsManager.containerColorDark,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveSubscription() {
    if (_formKey.currentState!.validate()) {
      final subscription = SubscriptionModel(
        id: widget.subscription?.id ?? DateTime.now().toString(),
        serviceName: _serviceNameController.text,
        amount: double.parse(_amountController.text),
        nextPaymentDate: _selectedDate,
        reminderDays: _selectedReminderDays,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        isPaid: widget.subscription?.isPaid ?? false,
        createdAt: widget.subscription?.createdAt ?? DateTime.now(),
      );

      if (widget.subscription == null) {
        context.read<SubscriptionsCubit>().addSubscription(subscription);
      } else {
        context.read<SubscriptionsCubit>().updateSubscription(subscription);
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.subscription == null ? 'تم إضافة الاشتراك بنجاح' : 'تم تحديث الاشتراك بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteSubscription() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ColorsManager.containerColorDark,
        title: const Text('حذف الاشتراك', style: TextStyle(color: Colors.white)),
        content: const Text('هل أنت متأكد من حذف هذا الاشتراك؟', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SubscriptionsCubit>().deleteSubscription(widget.subscription!.id);
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('تم حذف الاشتراك'), backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
