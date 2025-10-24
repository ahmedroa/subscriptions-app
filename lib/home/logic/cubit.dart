import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:subscriptions_app/home/logic/state.dart';
import 'package:subscriptions_app/home/model/subscription_model.dart';
import 'package:subscriptions_app/home/repo/subscription_repository.dart';
import 'package:subscriptions_app/core/services/notification_service.dart';

class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  final SubscriptionRepository repository;

  SubscriptionsCubit(this.repository) : super(SubscriptionsInitial());

  Future<void> loadSubscriptions() async {
    try {
      emit(SubscriptionsLoading());
      final subscriptions = await repository.getSubscriptions();

      // Sort by nearest next payment date
      subscriptions.sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));

      final total = subscriptions.fold<double>(0.0, (sum, sub) => sum + sub.amount);

      // إعادة جدولة جميع التنبيهات
      await NotificationService.rescheduleAllReminders(subscriptions);

      emit(SubscriptionsLoaded(subscriptions: subscriptions, totalMonthly: total));
    } catch (e) {
      emit(SubscriptionsError('فشل تحميل الاشتراكات'));
    }
  }

  Future<void> addSubscription(SubscriptionModel subscription) async {
    try {
      await repository.addSubscription(subscription);
      // جدولة التنبيه للاشتراك الجديد
      await NotificationService.scheduleSubscriptionReminder(subscription);
      await loadSubscriptions();
    } catch (e) {
      emit(SubscriptionsError('فشل إضافة الاشتراك'));
    }
  }

  Future<void> updateSubscription(SubscriptionModel subscription) async {
    try {
      await repository.updateSubscription(subscription);
      // إلغاء التنبيه القديم وجدولة الجديد
      await NotificationService.cancelSubscriptionReminder(subscription.id);
      await NotificationService.scheduleSubscriptionReminder(subscription);
      await loadSubscriptions();
    } catch (e) {
      emit(SubscriptionsError('فشل تحديث الاشتراك'));
    }
  }

  Future<void> deleteSubscription(String id) async {
    try {
      await repository.deleteSubscription(id);
      await NotificationService.cancelSubscriptionReminder(id);
      await loadSubscriptions();
    } catch (e) {
      emit(SubscriptionsError('فشل حذف الاشتراك'));
    }
  }

  Future<void> markAsPaid(SubscriptionModel subscription) async {
    try {
      final current = subscription.nextPaymentDate;
      final int newMonth = current.month + 1;
      final int newYear = current.year + ((newMonth - 1) ~/ 12);
      final int normalizedMonth = ((newMonth - 1) % 12) + 1;
      final int lastDayOfTargetMonth = DateTime(newYear, normalizedMonth + 1, 0).day;
      final int targetDay = current.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : current.day;
      final DateTime newPaymentDate = DateTime(
        newYear,
        normalizedMonth,
        targetDay,
        current.hour,
        current.minute,
        current.second,
        current.millisecond,
        current.microsecond,
      );

      final updatedSubscription = subscription.copyWith(nextPaymentDate: newPaymentDate);

      await repository.updateSubscription(updatedSubscription);
      await NotificationService.cancelSubscriptionReminder(subscription.id);
      await NotificationService.scheduleSubscriptionReminder(updatedSubscription);

      // تحديث محلي مع إظهار التغييرات
      if (state is SubscriptionsLoaded) {
        final currentState = state as SubscriptionsLoaded;
        final updatedSubscriptions = currentState.subscriptions.map((sub) {
          return sub.id == subscription.id ? updatedSubscription : sub;
        }).toList();

        // ترتيب الاشتراكات حسب التاريخ
        updatedSubscriptions.sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));

        // حساب المجموع الجديد
        final total = updatedSubscriptions.fold<double>(0.0, (sum, sub) => sum + sub.amount);

        // إرسال حالة جديدة لإظهار التغييرات
        emit(SubscriptionsLoaded(subscriptions: updatedSubscriptions, totalMonthly: total));
      }
    } catch (e) {
      emit(SubscriptionsError('فشل تحديث حالة الدفع'));
    }
  }

  void sortSubscriptions(String sortType) {
    if (state is! SubscriptionsLoaded) return;

    final currentState = state as SubscriptionsLoaded;
    final subscriptions = List<SubscriptionModel>.from(currentState.subscriptions);

    switch (sortType) {
      case 'date':
        subscriptions.sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));
        break;
      case 'amount':
        subscriptions.sort((a, b) => b.amount.compareTo(a.amount)); // ترتيب تنازلي حسب المبلغ
        break;
      case 'name':
        subscriptions.sort((a, b) => a.serviceName.compareTo(b.serviceName));
        break;
    }

    emit(SubscriptionsLoaded(subscriptions: subscriptions, totalMonthly: currentState.totalMonthly));
  }
}
