// lib/features/auth/presentation/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // انتظر 3 ثواني ثم تحقق من الجلسة
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _waitAndNavigate();
    });
  }

  Future<void> _waitAndNavigate() async {
    // ======== انتظر حتى تنتهي استعادة الجلسة من authProvider ========
    // _restoreSession في AuthNotifier بتشتغل في الـ background
    // بننتظرها تخلص قبل ما نتنقل
    while (!ref.read(authProvider).isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;
    _navigate();
  }

  void _navigate() {
    // ======== قراءة المستخدم من authProvider مباشرة ========
    final user = ref.read(authProvider).user;

    if (user == null) {
      context.go(AppConstants.routeLogin);
      return;
    }

    switch (user.role) {
      case 'Doctor':
        context.go(AppConstants.routeDoctorHome);
        break;
      case 'Patient':
        context.go(AppConstants.routePatientHome);
        break;
      case 'Observer':
        context.go(AppConstants.routeObserverHome);
        break;
      default:
        context.go(AppConstants.routeLogin);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ======== الشعار ========
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: AppTheme.primary,
                        size: 52,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ======== اسم التطبيق ========
              const Text(
                'HealthCare',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'MANAGEMENT SYSTEM',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 48),

              // ======== خط فاصل ========
              Container(
                width: 200,
                height: 0.5,
                color: Colors.white.withOpacity(0.3),
              ),

              const SizedBox(height: 32),

              // ======== معلومات الفريق ========
              const Text(
                'Fourth Year Team',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Faculty of Science — Zagazig University',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 24),

              // ======== المشرفة ========
              Text(
                'Under the supervision of',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Dr. Hajar Ramadan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 64),

              // ======== مؤشر التحميل ========
              const _LoadingDots(),
            ],
          ),
        ),
      ),
    );
  }
}

// ======== نقاط التحميل المتحركة ========
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final val = _ctrl.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final opacity = ((val * 3 - i) % 1.0).clamp(0.2, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
