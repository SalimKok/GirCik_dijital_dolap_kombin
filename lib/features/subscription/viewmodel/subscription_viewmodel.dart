import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/subscription.dart';
import 'package:gircik/features/subscription/repository/subscription_repository.dart';

class SubscriptionViewModel extends Notifier<Subscription> {
  late final SubscriptionRepository _repository;

  @override
  Subscription build() {
    _repository = ref.watch(subscriptionRepositoryProvider);
    Future.microtask(() => loadStatus());
    
    // Varsayılan: ücretsiz plan, 0 kullanım (data gelene kadar)
    return const Subscription(
      plan: SubscriptionPlan.free,
      clothingItemCount: 0,
      outfitCount: 0,
      aiUsagesToday: 0,
      calendarEventCount: 0,
    );
  }

  Future<void> loadStatus() async {
    try {
      final sub = await _repository.getStatus();
      state = sub;
    } catch (e) {
      // Failed to load, keep default
    }
  }

  /// Pro plana yükselt
  Future<void> purchasePlan(SubscriptionPlan plan) async {
    try {
      String planStr = plan == SubscriptionPlan.monthly ? 'monthly' : 'yearly';
      final updatedSub = await _repository.purchase(planStr);
      state = updatedSub;
    } catch (e) {
      // Revert or show error handled by UI
    }
  }

  /// Pro'dan geri dön (iptal).
  Future<void> cancelSubscription() async {
    try {
      final updatedSub = await _repository.cancel();
      state = updatedSub;
    } catch (e) {
      
    }
  }

  Future<void> _incrementMetric(String metric) async {
    try {
      final updatedSub = await _repository.incrementUsage(metric);
      state = updatedSub;
    } catch (e) {
      // Handled silently
    }
  }

  /// Kıyafet ekleme sayacını artır.
  void incrementClothingCount() {
    // Optimistic UI
    state = state.copyWith(clothingItemCount: state.clothingItemCount + 1);
    _incrementMetric('clothing');
  }

  /// Kombin sayacını artır.
  void incrementOutfitCount() {
    state = state.copyWith(outfitCount: state.outfitCount + 1);
    _incrementMetric('outfit');
  }

  /// AI kullanım sayacını artır.
  void incrementAIUsage() {
    state = state.copyWith(aiUsagesToday: state.aiUsagesToday + 1);
    _incrementMetric('ai_recommendation');
  }

  /// Takvim etkinlik sayacını artır.
  void incrementCalendarEventCount() {
    state = state.copyWith(calendarEventCount: state.calendarEventCount + 1);
    _incrementMetric('calendar_event');
  }
}

final subscriptionProvider =
    NotifierProvider<SubscriptionViewModel, Subscription>(() {
  return SubscriptionViewModel();
});

