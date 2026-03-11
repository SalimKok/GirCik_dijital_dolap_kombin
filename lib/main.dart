import 'package:flutter/material.dart';
import 'package:gircik/core/app_start_screen.dart';
import 'package:gircik/theme/app_theme.dart';
import 'package:gircik/theme/theme_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: GircikApp(),
    ),
  );
}

class GircikApp extends ConsumerWidget {
  const GircikApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'GiyÇık',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AppStartScreen(),
    );
  }
}
