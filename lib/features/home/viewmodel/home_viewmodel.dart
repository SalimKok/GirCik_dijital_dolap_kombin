import 'package:flutter_riverpod/flutter_riverpod.dart';

// ViewModel State
class HomeState {
  final bool isLoading;
  final String userName;
  final int laundryCount;
  final String nextEventTitle;
  final String nextEventTime;
  final String? error;

  HomeState({
    this.isLoading = false,
    this.userName = 'Kullanıcı',
    this.laundryCount = 0,
    this.nextEventTitle = 'Veri Yok',
    this.nextEventTime = '',
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    String? userName,
    int? laundryCount,
    String? nextEventTitle,
    String? nextEventTime,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      laundryCount: laundryCount ?? this.laundryCount,
      nextEventTitle: nextEventTitle ?? this.nextEventTitle,
      nextEventTime: nextEventTime ?? this.nextEventTime,
      error: error, // Can be null to clear error
    );
  }
}

// ViewModel (Notifier)
class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    // Initial fetch when ViewModel is created
    Future.microtask(() => loadHomeData());
    return HomeState(isLoading: true);
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Simulate API or Database fetch
      await Future<void>.delayed(const Duration(milliseconds: 800));

      // Mock Data
      state = state.copyWith(
        isLoading: false,
        userName: 'Ahmet',
        laundryCount: 3,
        nextEventTitle: 'İş Yemeği',
        nextEventTime: 'Yarın akşam:',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Global Provider
final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(() {
  return HomeViewModel();
});
