import 'package:subscriptions_app/home/model/subscription_model.dart';

abstract class SubscriptionsState {}

class SubscriptionsInitial extends SubscriptionsState {}

class SubscriptionsLoading extends SubscriptionsState {}

class SubscriptionsLoaded extends SubscriptionsState {
  final List<SubscriptionModel> subscriptions;
  final double totalMonthly;

  SubscriptionsLoaded({required this.subscriptions, required this.totalMonthly});
}

class SubscriptionsError extends SubscriptionsState {
  final String message;

  SubscriptionsError(this.message);
}
