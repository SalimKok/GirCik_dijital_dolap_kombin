import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/outfit_item.dart';

// ViewModel State
class OutfitsState {
  final bool isLoading;
  final List<OutfitItem> outfits;
  final String? error;

  OutfitsState({
    this.isLoading = false,
    this.outfits = const [],
    this.error,
  });

  OutfitsState copyWith({
    bool? isLoading,
    List<OutfitItem>? outfits,
    String? error,
  }) {
    return OutfitsState(
      isLoading: isLoading ?? this.isLoading,
      outfits: outfits ?? this.outfits,
      error: error,
    );
  }

  List<OutfitItem> get favoriteOutfits {
    return outfits.where((outfit) => outfit.isFavorite).toList();
  }
}

// ViewModel (Notifier)
class OutfitsViewModel extends Notifier<OutfitsState> {
  @override
  OutfitsState build() {
    Future.microtask(() => loadOutfits());
    return OutfitsState(isLoading: true);
  }

  Future<void> loadOutfits() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Simulate API or DB
      await Future<void>.delayed(const Duration(milliseconds: 600));

      final mockData = [
        const OutfitItem(
          id: '1',
          title: 'Hafta Sonu Yürüyüş',
          style: 'Sportif',
          season: 'İlkbahar',
          isFavorite: true,
          items: [
            OutfitItemData(name: 'Kapüşonlu Sweat', icon: Icons.dry_cleaning_rounded),
            OutfitItemData(name: 'Gri Eşofman', icon: Icons.airline_seat_legroom_normal_rounded),
            OutfitItemData(name: 'Spor Ayakkabı', icon: Icons.snowshoeing_rounded),
          ],
        ),
        const OutfitItem(
          id: '2',
          title: 'Ofis Günlüğü',
          style: 'Şık / Klasik',
          season: 'Sonbahar',
          isFavorite: false,
          items: [
            OutfitItemData(name: 'Beyaz Gömlek', icon: Icons.dry_cleaning_rounded),
            OutfitItemData(name: 'Siyah Pantolon', icon: Icons.airline_seat_legroom_normal_rounded),
            OutfitItemData(name: 'Klasik Ayakkabı', icon: Icons.snowshoeing_rounded),
            OutfitItemData(name: 'Deri Kemer', icon: Icons.watch_rounded),
          ],
        ),
        const OutfitItem(
          id: '3',
          title: 'Rahat Akşam',
          style: 'Casual',
          season: 'Yaz',
          isFavorite: true,
          items: [
            OutfitItemData(name: 'Kısa Kol Tişört', icon: Icons.dry_cleaning_rounded),
            OutfitItemData(name: 'Açık Mavi Şort', icon: Icons.airline_seat_legroom_normal_rounded),
            OutfitItemData(name: 'Sneaker', icon: Icons.snowshoeing_rounded),
          ],
        ),
        const OutfitItem(
          id: '4',
          title: 'Kış Yemeği',
          style: 'Şık',
          season: 'Kış',
          isFavorite: false,
          items: [
            OutfitItemData(name: 'Bordo Kazak', icon: Icons.dry_cleaning_rounded),
            OutfitItemData(name: 'Koyu Kot Pantolon', icon: Icons.airline_seat_legroom_normal_rounded),
            OutfitItemData(name: 'Bot', icon: Icons.snowshoeing_rounded),
            OutfitItemData(name: 'Atkı', icon: Icons.watch_rounded),
          ],
        ),
      ];

      state = state.copyWith(isLoading: false, outfits: mockData);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleFavorite(String id) {
    final updatedOutfits = state.outfits.map((outfit) {
      if (outfit.id == id) {
        return outfit.copyWith(isFavorite: !outfit.isFavorite);
      }
      return outfit;
    }).toList();

    state = state.copyWith(outfits: updatedOutfits);
  }
}

// Global Provider
final outfitsViewModelProvider = NotifierProvider<OutfitsViewModel, OutfitsState>(() {
  return OutfitsViewModel();
});
