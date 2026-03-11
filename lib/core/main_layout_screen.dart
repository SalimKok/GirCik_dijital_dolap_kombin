import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/home/view/home_screen.dart';
import 'package:gircik/features/wardrobe/view/wardrobe_screen.dart';
import 'package:gircik/features/outfits/view/outfits_screen.dart';
import 'package:gircik/features/style_calendar/view/style_calendar_screen.dart';
import 'package:gircik/features/laundry/view/laundry_screen.dart';
import 'package:gircik/features/settings/view/settings_screen.dart';
import 'package:gircik/features/subscription/viewmodel/subscription_viewmodel.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const WardrobeScreen(),
    const OutfitsScreen(),
    const StyleCalendarScreen(),
    const LaundryScreen(),
  ];

  static const List<String> _titles = [
    'GiyÇık',
    'Gardırop',
    'Kombinler',
    'Stil Takvimi',
    'Hijyen & Yıkama',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscription = ref.watch(subscriptionProvider);
    final isHome = _currentIndex == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        leading: isHome
            ? Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: subscription.isPro
                          ? LinearGradient(
                              colors: [Colors.amber.shade600, Colors.orange.shade700],
                            )
                          : null,
                      color: subscription.isPro ? null : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          subscription.isPro ? Icons.workspace_premium_rounded : Icons.person_rounded,
                          size: 16,
                          color: subscription.isPro ? Colors.white : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subscription.isPro ? 'PRO' : 'Ücretsiz',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: subscription.isPro ? Colors.white : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
        leadingWidth: isHome ? 110 : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Ayarlar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.checkroom_outlined),
            selectedIcon: Icon(Icons.checkroom_rounded),
            label: 'Gardırop',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Kombin',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Takvim',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_laundry_service_outlined),
            selectedIcon: Icon(Icons.local_laundry_service_rounded),
            label: 'Hijyen',
          ),
        ],
      ),
    );
  }
}
