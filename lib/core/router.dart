// lib/core/router.dart
// إدارة التنقل بين الشاشات باستخدام GoRouter

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healthcare_app/features/auth/presentation/screens/splash_screen.dart';
import '../core/constants/app_constants.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/doctor/presentation/screens/doctor_home_screen.dart';
import '../features/doctor/presentation/screens/create_profile_screen.dart';
import '../features/doctor/presentation/screens/patient_detail_screen.dart';
import '../features/patient/presentation/screens/patient_home_screen.dart';
import '../features/pharmacy/presentation/screens/pharmacies_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.routeDoctorHome,
        builder: (_, __) => const DoctorHomeScreen(),
      ),
      GoRoute(
        path: AppConstants.routeCreateProfile,
        builder: (_, __) => const CreateProfileScreen(),
      ),
      GoRoute(
        path: '/doctor/patient/:id',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PatientDetailScreen(patientId: id);
        },
      ),
      GoRoute(
        path: AppConstants.routePatientHome,
        builder: (_, __) => const PatientHomeScreen(),
      ),
      GoRoute(
        path: AppConstants.routeObserverHome,
        builder: (_, __) => const PatientHomeScreen(),
      ),
      GoRoute(
        path: AppConstants.routePharmacies,
        builder: (_, __) => const PharmaciesScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => const SplashScreen(),
      ),
    ],
  );
});
