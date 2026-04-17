// lib/main.dart
// نقطة بداية التطبيق

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إجبار الاتجاه العمودي فقط
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    // ProviderScope ضروري لـ Riverpod
    const ProviderScope(
      child: HealthcareApp(),
    ),
  );
}

class HealthcareApp extends ConsumerWidget {
  const HealthcareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // ======== إعدادات التطبيق ========
      title: 'نظام الرعاية الصحية',
      debugShowCheckedModeBanner: false,

      // ======== الثيم ========
      theme: AppTheme.theme,

      // ======== دعم اللغة العربية (RTL) ========
      locale: const Locale('ar', 'SA'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      // ======== الراوتر ========
      routerConfig: router,
    );
  }
}
