import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/outfits/view/outfit_recommendation_screen.dart';
import 'package:gircik/features/outfits/viewmodel/outfits_viewmodel.dart';
import 'package:gircik/data/models/outfit_item.dart';

class OutfitsScreen extends ConsumerStatefulWidget {
  const OutfitsScreen({super.key});

  @override
  ConsumerState<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends ConsumerState<OutfitsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outfitsState = ref.watch(outfitsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tüm Kombinler'),
            Tab(text: 'Favoriler'),
          ],
        ),
      ),
      body: outfitsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOutfitsList(
                  outfitsState.outfits,
                  'Henüz kombin eklemedin.',
                  'Yeni bir kombin oluşturarak başla!',
                  theme,
                ),
                _buildOutfitsList(
                  outfitsState.favoriteOutfits,
                  'Favori kombinin yok.',
                  'Beğendiğin kombinleri favorilerine ekle.',
                  theme,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const OutfitRecommendationScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Öneri Al'),
      ),
    );
  }

  Widget _buildOutfitsList(List<OutfitItem> list, String emptyTitle, String emptySubtitle, ThemeData theme) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style_rounded, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 24),
            Text(emptyTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(emptySubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final outfit = list[index];
        return _buildOutfitCard(outfit, theme);
      },
    );
  }

  Widget _buildOutfitCard(OutfitItem outfit, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outfit.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildTag(outfit.style, theme.colorScheme.primary),
                          _buildTag(outfit.season, theme.colorScheme.secondary),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref.read(outfitsViewModelProvider.notifier).toggleFavorite(outfit.id);
                  },
                  icon: Icon(
                    outfit.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: outfit.isFavorite ? Colors.red : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // Items section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: outfit.items.map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.name,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
