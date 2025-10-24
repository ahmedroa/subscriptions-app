import 'package:hive/hive.dart';
import 'package:subscriptions_app/home/model/subscription_model.dart';

class SubscriptionRepository {
  static const String _boxName = 'subscriptions';
  Box<SubscriptionModel>? _box;

  Future<void> init() async {
    try {
      _box = await Hive.openBox<SubscriptionModel>(_boxName);
    } catch (e) {
      try {
        await Hive.deleteBoxFromDisk(_boxName);
        _box = await Hive.openBox<SubscriptionModel>(_boxName);
      } catch (e2) {
        _box = await Hive.openBox<SubscriptionModel>(_boxName);
      }
    }
  }

  Box<SubscriptionModel> get _ensureBox {
    final box = _box;
    if (box == null) {
      throw StateError('SubscriptionRepository not initialized. Call init() first.');
    }
    return box;
  }

  Future<List<SubscriptionModel>> getSubscriptions() async {
    final box = _ensureBox;
    return box.values.toList(growable: false);
  }

  Future<void> addSubscription(SubscriptionModel subscription) async {
    final box = _ensureBox;
    await box.put(subscription.id, subscription);
  }

  Future<void> updateSubscription(SubscriptionModel subscription) async {
    final box = _ensureBox;
    await box.put(subscription.id, subscription);
  }

  Future<void> deleteSubscription(String id) async {
    final box = _ensureBox;
    await box.delete(id);
  }
}
