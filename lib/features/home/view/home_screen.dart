import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/home/viewmodel/home_viewmodel.dart';
import 'package:gircik/features/laundry/viewmodel/laundry_viewmodel.dart';
import 'package:gircik/features/style_calendar/viewmodel/style_calendar_viewmodel.dart';
import 'package:gircik/features/outfits/viewmodel/outfits_viewmodel.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/data/models/outfit_item.dart';
import 'package:gircik/data/models/calendar_event.dart';
import 'package:gircik/core/providers/navigation_provider.dart';
import 'package:gircik/core/constants/api_constants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final laundryState = ref.watch(laundryViewModelProvider);
    final calendarState = ref.watch(styleCalendarViewModelProvider);
    final outfitsState = ref.watch(outfitsViewModelProvider);

    final laundryCount = laundryState.needsWashItems.length;

    final now = DateTime.now();
    // Sadece bugünden sonraki günleri göster (bugün dahil)
    final today = DateTime(now.year, now.month, now.day);
    final upcomingEvents = calendarState.events.where((e) {
      final eventDay = DateTime(e.date.year, e.date.month, e.date.day);
      return !eventDay.isBefore(today);
    }).toList();
    upcomingEvents.sort((a, b) => a.date.compareTo(b.date));
    final nextEvent = upcomingEvents.isNotEmpty ? upcomingEvents.first : null;

    String nextEventTitle = nextEvent?.title ?? 'Yaklaşan etkinlik yok';
    String nextEventTime = '';
    if (nextEvent != null) {
      // Takvim günü farkını hesapla (saat bilgisi olmadan)
      final eventDay = DateTime(nextEvent.date.year, nextEvent.date.month, nextEvent.date.day);
      final dayDiff = eventDay.difference(today).inDays;
      if (dayDiff == 0) {
        nextEventTime = 'Bugün:';
      } else if (dayDiff == 1) {
        nextEventTime = 'Yarın:';
      } else {
        nextEventTime = '$dayDiff gün sonra:';
      }
    }

    final favoriteOutfits = outfitsState.outfits.where((o) => o.isFavorite).toList();

    return Scaffold(
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildWelcomeSection(context, homeState.userName),
                        const SizedBox(height: 28),
                        _buildSectionTitle(context, 'Yaklaşan Önemli Bilgiler'),
                        const SizedBox(height: 12),
                        _buildUpcomingInfo(
                          context,
                          ref,
                          laundryCount,
                          nextEventTitle,
                          nextEventTime,
                          nextEvent,
                        ),
                  const SizedBox(height: 28),
                  _buildSectionTitle(context, 'Favori Kombinler'),
                  const SizedBox(height: 12),
                  _buildFavoriteOutfits(context, ref, favoriteOutfits),
                  const SizedBox(height: 28),
                  _buildSectionTitle(context, 'Bugün'),
                  const SizedBox(height: 12),
                  _buildTodayCard(context),
                ]),
              ),
            ),
          ],
        ),
    );
  }


  Widget _buildWelcomeSection(BuildContext context, String userName) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Merhaba, $userName',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bugün ne giyeceksin?',
          style: theme.textTheme.headlineMedium,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontSize: 15,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildUpcomingInfo(
    BuildContext context,
    WidgetRef ref,
    int laundryCount,
    String nextEventTitle,
    String nextEventTime,
    CalendarEvent? nextEvent,
  ) {
    return Column(
      children: [
        _InfoCard(
          icon: Icons.local_laundry_service_rounded,
          title: 'Yıkanması Gerekenler',
          subtitle: laundryCount > 0 
            ? '$laundryCount kıyafetin yıkanma vakti geldi.' 
            : 'Yıkanacak kıyafet yok.',
          color: Colors.blue,
          onTap: () {
            // Hijyen sekmesi index 4
            ref.read(mainNavIndexProvider.notifier).navigate(4);
          },
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.event_rounded,
          title: 'Yaklaşan Etkinlik',
          subtitle: '$nextEventTime $nextEventTitle',
          color: Colors.orange,
          onTap: nextEvent != null ? () {
            // Takvim sekmesi index 3, ilgili günü seç
            ref.read(styleCalendarViewModelProvider.notifier)
                .selectDay(nextEvent.date, nextEvent.date);
            ref.read(mainNavIndexProvider.notifier).navigate(3);
          } : () {},
        ),
      ],
    );
  }

  Widget _buildFavoriteOutfits(BuildContext context, WidgetRef ref, List<OutfitItem> favorites) {
    final theme = Theme.of(context);
    final wardrobeItems = ref.watch(wardrobeViewModelProvider).items;

    if (favorites.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Henüz favori kombininiz yok.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return SizedBox(
      height: 195,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final outfit = favorites[index];

          // Kombindeki kıyafet resimlerini bul
          final outfitImages = outfit.items.map((link) {
            final item = wardrobeItems.where((w) => w.id == link.clothingItemId).firstOrNull;
            if (item?.imageUrl != null && item!.imageUrl!.isNotEmpty) {
              return item.imageUrl!.startsWith('http')
                  ? item.imageUrl!
                  : '${ApiConstants.baseUrl.replaceAll('/api', '')}${item.imageUrl}';
            }
            return null;
          }).where((url) => url != null).cast<String>().toList();

          return Container(
            width: 148,
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fotoğraf bölümü
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: outfitImages.isNotEmpty
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Arka plan: ilk kıyafet
                                    Image.network(
                                      outfitImages[0],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildOutfitPlaceholder(theme),
                                    ),
                                    // Sağ alt köşede mini üst üste fotoğraflar
                                    if (outfitImages.length > 1)
                                      Positioned(
                                        bottom: 6,
                                        right: 6,
                                        child: Row(
                                          children: outfitImages
                                              .skip(1)
                                              .take(2)
                                              .map(
                                                (url) => Container(
                                                  margin: const EdgeInsets.only(left: 4),
                                                  width: 30,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: Colors.white, width: 1.5),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: 0.2),
                                                        blurRadius: 4,
                                                      ),
                                                    ],
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(5),
                                                    child: Image.network(url, fit: BoxFit.cover),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    // Favori ikonlu üst sol rozet
                                    Positioned(
                                      top: 6,
                                      left: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade500,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.favorite_rounded, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                )
                              : _buildOutfitPlaceholder(theme),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        outfit.title,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        outfit.style,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOutfitPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.checkroom_rounded,
          size: 40,
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.wb_sunny_rounded,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hava durumuna göre öneri',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bugünkü havaya uygun kombin önerisi al',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

