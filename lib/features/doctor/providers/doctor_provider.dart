// lib/features/doctor/providers/doctor_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/doctor_repository.dart';
import '../../../shared/models/auth_models.dart';

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository(ref.watch(apiClientProvider));
});

// ======== قائمة المرضى ========
final patientsProvider =
    AsyncNotifierProvider<PatientsNotifier, List<PatientProfile>>(
        PatientsNotifier.new);

class PatientsNotifier extends AsyncNotifier<List<PatientProfile>> {
  @override
  Future<List<PatientProfile>> build() async {
    return ref.watch(doctorRepositoryProvider).getMyPatients();
  }

  Future<PatientProfile?> createProfile({
    required String patientName,
    required int age,
    required String gender,
    required String phoneNumber,
    required String address,
    required String diagnosis,
    required String medicalHistory,
    required String allergies,
  }) async {
    try {
      final profile =
          await ref.read(doctorRepositoryProvider).createPatientProfile(
                patientName: patientName,
                age: age,
                gender: gender,
                phoneNumber: phoneNumber,
                address: address,
                diagnosis: diagnosis,
                medicalHistory: medicalHistory,
                allergies: allergies,
              );
      ref.invalidateSelf();
      return profile;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteProfile(int id) async {
    await ref.read(doctorRepositoryProvider).deletePatient(id);
    ref.invalidateSelf();
  }
}

// ======== تفاصيل مريض ========
final patientDetailProvider =
    FutureProvider.family<PatientProfile, int>((ref, id) async {
  return ref.watch(doctorRepositoryProvider).getPatientById(id);
});

// ======== الأدوية ========
final medicationsProvider =
    AsyncNotifierProviderFamily<MedicationsNotifier, List<Medication>, int>(
        MedicationsNotifier.new);

class MedicationsNotifier extends FamilyAsyncNotifier<List<Medication>, int> {
  @override
  Future<List<Medication>> build(int arg) async {
    return ref.watch(doctorRepositoryProvider).getMedications(arg);
  }

  Future<bool> addMedication({
    required int patientProfileId,
    required String name,
    required String dosage,
    required String schedule,
    required String status,
    required DateTime startDate,
    DateTime? endDate,
    required String doctorNotes,
    required bool takeWithFood,
  }) async {
    try {
      await ref.read(doctorRepositoryProvider).addMedication(
            patientProfileId: patientProfileId,
            name: name,
            dosage: dosage,
            schedule: schedule,
            status: status,
            startDate: startDate,
            endDate: endDate,
            doctorNotes: doctorNotes,
            takeWithFood: takeWithFood,
          );
      ref.invalidateSelf();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteMedication(int id) async {
    await ref.read(doctorRepositoryProvider).deleteMedication(id);
    ref.invalidateSelf();
  }
}

// ======== سجل تناول الأدوية ========
final medicationLogsProvider = AsyncNotifierProviderFamily<
    MedicationLogsNotifier,
    List<MedicationLog>,
    int>(MedicationLogsNotifier.new);

class MedicationLogsNotifier
    extends FamilyAsyncNotifier<List<MedicationLog>, int> {
  @override
  Future<List<MedicationLog>> build(int medicationId) async {
    return ref.watch(doctorRepositoryProvider).getMedicationLogs(medicationId);
  }

  Future<bool> logMedication({
    required int medicationId,
    required bool isTaken,
    required String note,
  }) async {
    try {
      await ref.read(doctorRepositoryProvider).logMedication(
            medicationId: medicationId,
            isTaken: isTaken,
            note: note,
          );
      ref.invalidateSelf();
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ======== التقارير ========
final reportsProvider =
    AsyncNotifierProviderFamily<ReportsNotifier, List<Report>, int>(
        ReportsNotifier.new);

class ReportsNotifier extends FamilyAsyncNotifier<List<Report>, int> {
  @override
  Future<List<Report>> build(int arg) async {
    return ref.watch(doctorRepositoryProvider).getReports(arg);
  }

  Future<bool> addReport({
    required int patientProfileId,
    required String title,
    required String content,
    required String reportType,
    required String updatedDiagnosis,
    required String recommendations,
    required bool isVisible,
  }) async {
    try {
      await ref.read(doctorRepositoryProvider).addReport(
            patientProfileId: patientProfileId,
            title: title,
            content: content,
            reportType: reportType,
            updatedDiagnosis: updatedDiagnosis,
            recommendations: recommendations,
            isVisible: isVisible,
          );
      ref.invalidateSelf();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteReport(int id) async {
    await ref.read(doctorRepositoryProvider).deleteReport(id);
    ref.invalidateSelf();
  }
}

// ======== الصيدليات ========
final pharmaciesProvider =
    AsyncNotifierProvider<PharmaciesNotifier, List<Pharmacy>>(
        PharmaciesNotifier.new);

class PharmaciesNotifier extends AsyncNotifier<List<Pharmacy>> {
  @override
  Future<List<Pharmacy>> build() async {
    return ref.watch(doctorRepositoryProvider).getPharmacies();
  }

  Future<bool> addPharmacy({
    required String name,
    required String address,
    required String phoneNumber,
    required String workingHours,
    required double latitude,
    required double longitude,
    required bool hasDelivery,
    required String notes,
  }) async {
    try {
      await ref.read(doctorRepositoryProvider).addPharmacy(
            name: name,
            address: address,
            phoneNumber: phoneNumber,
            workingHours: workingHours,
            latitude: latitude,
            longitude: longitude,
            hasDelivery: hasDelivery,
            notes: notes,
          );
      ref.invalidateSelf();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deletePharmacy(int id) async {
    await ref.read(doctorRepositoryProvider).deletePharmacy(id);
    ref.invalidateSelf();
  }
}
