import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_bank/core/router/app_router.dart';
// If a custom AppTheme isn't available, fall back to Flutter's built-in theme.

class SmartBankApp extends ConsumerWidget {
  const SmartBankApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'SmartBank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      routerConfig: router,
    );
  }
}