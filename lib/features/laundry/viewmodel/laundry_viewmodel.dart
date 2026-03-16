import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/laundry_item.dart';
import 'package:gircik/features/laundry/repository/laundry_repository.dart';

// ViewModel State
class LaundryState {
  final bool isLoading;
  final List<LaundryItem> items;
  final String? error;

  LaundryState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  LaundryState copyWith({
    bool? isLoading,
    List<LaundryItem>? items,
    String? error,
  }) {
    return LaundryState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }

  List<LaundryItem> get needsWashItems =>
      items.where((i) => i.status == LaundryStatus.needsWash).toList();

  List<LaundryItem> get washingItems =>
      items.where((i) => i.status == LaundryStatus.washing).toList();

  List<LaundryItem> get cleanItems =>
      items.where((i) => i.status == LaundryStatus.clean).toList();
}

// ViewModel (Notifier)
class LaundryViewModel extends Notifier<LaundryState> {
  late final LaundryRepository _repository;

  @override
  LaundryState build() {
    _repository = ref.watch(laundryRepositoryProvider);
    Future.microtask(() => loadItems());
    return LaundryState(isLoading: true);
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final remoteItems = await _repository.getLaundryItems();
      state = state.copyWith(isLoading: false, items: remoteItems);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _updateItemStatus(String id, String newStatusStr, LaundryStatus localStatus, {int? newWearCount}) async {
    // Optimistic UI update
    final initialItems = state.items;
    final updated = state.items.map((item) {
      if (item.id == id) {
        return item.copyWith(
          status: localStatus,
          wearCount: newWearCount ?? item.wearCount,
        );
      }
      return item;
    }).toList();
    state = state.copyWith(items: updated);

    try {
      // API Call
      await _repository.updateStatus(id, newStatusStr);
    } catch (e) {
      // Revert
      state = state.copyWith(items: initialItems, error: e.toString());
    }
  }

  void moveToWashing(String id) {
    _updateItemStatus(id, 'washing', LaundryStatus.washing);
  }

  void moveToClean(String id) {
    _updateItemStatus(id, 'clean', LaundryStatus.clean, newWearCount: 0);
  }

  void moveToNeedsWash(String id) {
    // Determine maxWear locally for optimistic update, though backend has its own logic
    final item = state.items.firstWhere((i) => i.id == id);
    _updateItemStatus(id, 'needs_wash', LaundryStatus.needsWash, newWearCount: item.maxWear);
  }
}


// Global Provider
final laundryViewModelProvider = NotifierProvider<LaundryViewModel, LaundryState>(() {
  return LaundryViewModel();
});
