import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/auth/repository/auth_repository.dart';
import 'package:gircik/features/laundry/repository/laundry_repository.dart';
import 'package:gircik/features/style_calendar/repository/calendar_repository.dart';

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
  late final AuthRepository _authRepo;
  late final LaundryRepository _laundryRepo;
  late final CalendarRepository _calendarRepo;

  @override
  HomeState build() {
    _authRepo = ref.watch(authRepositoryProvider);
    _laundryRepo = ref.watch(laundryRepositoryProvider);
    _calendarRepo = ref.watch(calendarRepositoryProvider);
    
    // Initial fetch when ViewModel is created
    Future.microtask(() => loadHomeData());
    return HomeState(isLoading: true);
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepo.getCurrentUser();
      final laundryItems = await _laundryRepo.getLaundryItems();
      final calendarEvents = await _calendarRepo.getEvents();

      final needsWashCount = laundryItems.where((i) => i.status.name == 'needsWash').length;
      
      String nextEventTitle = 'Yaklaşan etkinlik yok';
      String nextEventTime = '';
      
      final now = DateTime.now();
      final upcomingEvents = calendarEvents.where((e) => e.date.isAfter(now)).toList();
      if (upcomingEvents.isNotEmpty) {
        upcomingEvents.sort((a, b) => a.date.compareTo(b.date));
        final nextEvent = upcomingEvents.first;
        nextEventTitle = nextEvent.title;
        
        final diff = nextEvent.date.difference(now);
        if (diff.inDays == 0) {
          nextEventTime = 'Bugün:';
        } else if (diff.inDays == 1) {
          nextEventTime = 'Yarın:';
        } else {
          nextEventTime = '\${diff.inDays} gün sonra:';
        }
      }

      state = state.copyWith(
        isLoading: false,
        userName: user.name,
        laundryCount: needsWashCount,
        nextEventTitle: nextEventTitle,
        nextEventTime: nextEventTime,
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

