import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/home/view/home_screen.dart';
import 'package:gircik/features/wardrobe/view/wardrobe_screen.dart';
import 'package:gircik/features/outfits/view/outfits_screen.dart';
import 'package:gircik/features/style_calendar/view/style_calendar_screen.dart';
import 'package:gircik/features/laundry/view/laundry_screen.dart';
import 'package:gircik/features/settings/view/settings_screen.dart';
import 'package:gircik/features/subscription/viewmodel/subscription_viewmodel.dart';
import 'package:gircik/features/subscription/view/pro_paywall_screen.dart';
import 'package:gircik/core/providers/navigation_provider.dart';
import 'package:gircik/features/pro_features/view/pro_features_hub_screen.dart';
import 'package:gircik/features/home/viewmodel/home_viewmodel.dart';

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
    const ProFeaturesHubScreen(),
    const LaundryScreen(),
  ];

  static const List<String> _titles = [
    'GiyÇık',
    'Gardırop',
    'Kombinler',
    'Stil Takvimi',
    'Pro Özellikler',
    'Hijyen & Yıkama',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscription = ref.watch(subscriptionProvider);
    final currentIndex = ref.watch(mainNavIndexProvider);
    final isHome = currentIndex == 0;

    // Sync external changes to local state
    if (_currentIndex != currentIndex) {
      _currentIndex = currentIndex;
    }

    final userName = ref.watch(homeViewModelProvider).userName;

    return Scaffold(
      appBar: AppBar(
        title: isHome
            ? ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.7),
                    theme.colorScheme.tertiary != theme.colorScheme.primary
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.secondary,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds),
                child: Text(
                  'GİYÇIK',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white, // ShaderMask boyar
                    letterSpacing: -1.0,
                    fontSize: 26,
                  ),
                ),
              )
            : Text(_titles[currentIndex]),
        leading: isHome
            ? Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: subscription.isPro
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFFFD700), // Altın sarısı
                                Color(0xFFFFA500), // Turuncu
                                Color(0xFFFF8C00), // Koyu turuncu
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                theme.colorScheme.surfaceContainerHighest,
                                theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: subscription.isPro
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                      border: subscription.isPro
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            )
                          : Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.2),
                              width: 1,
                            ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (subscription.isPro) ...[
                          const Icon(
                            Icons.workspace_premium_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.person_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ücretsiz',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            : null,
        leadingWidth: isHome ? 110 : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              tooltip: 'Ayarlar',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index == 4) { // Pro Özellikler indexi
            final isPro = ref.read(subscriptionProvider).isPro;
            if (!isPro) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pro özellikler sadece Pro üyelere özeldir.')));
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProPaywallScreen()));
              return;
            }
          }
          setState(() {
            _currentIndex = index;
          });
          ref.read(mainNavIndexProvider.notifier).navigate(index);
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
            icon: Icon(Icons.workspace_premium_outlined),
            selectedIcon: Icon(Icons.workspace_premium_rounded),
            label: 'Pro',
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
