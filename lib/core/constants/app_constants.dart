// lib/core/constants/app_constants.dart
// ثوابت التطبيق — كل القيم الثابتة في مكان واحد

class AppConstants {
  // ======== API ========
  // 10.0.2.2 هو localhost الجهاز من داخل Android Emulator
  static const String baseUrl = 'http://10.0.2.2:5030/api';

  // ======== Secure Storage Keys ========
  static const String tokenKey = 'jwt_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String userNameKey = 'user_name';
  static const String patientProfileIdKey = 'patient_profile_id';

  // ======== أدوار المستخدمين ========
  static const String roleDoctor = 'Doctor';
  static const String rolePatient = 'Patient';
  static const String roleObserver = 'Observer';

  // ======== Routes ========
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeDoctorHome = '/doctor';
  static const String routePatientHome = '/patient';
  static const String routeObserverHome = '/observer';
  static const String routeCreateProfile = '/doctor/create-profile';
  static const String routePatientDetail = '/doctor/patient/:id';
  static const String routePharmacies = '/pharmacies';
}
