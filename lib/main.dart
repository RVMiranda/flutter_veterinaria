import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/app_providers.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviderScope(
      child: Consumer<GoRouter>(
        builder: (context, router, _) {
          return MaterialApp.router(
            title: 'Flutter Veterinaria',
            theme: AppTheme.buildTheme(),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
