import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: DBalanceApp(),
    ),
  );
}

class DBalanceApp extends ConsumerWidget {
  const DBalanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'D-Balance',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: const Color(0xFF4ECDC4),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4ECDC4),
          brightness: Brightness.light,
        ),
      ),
      routerConfig: router,
    );
  }
}