// lib/features/doctor/data/doctor_repository.dart

import '../../../core/network/api_client.dart';
import '../../../shared/models/auth_models.dart';

class DoctorRepository {
  final ApiClient _apiClient;
  DoctorRepository(this._apiClient);

  // ======== ملفات المرضى ========
  Future<List<PatientProfile>> getMyPatients() async {
    final res = await _apiClient.dio.get('/patientprofile/my-patients');
    final list = res.data['data'] as List;
    return list.map((e) => PatientProfile.fromJson(e)).toList();
  }

  Future<PatientProfile> createPatientProfile({
    required String patientName,
    required int age,
    required String gender,
    required String phoneNumber,
    required String address,
    required String diagnosis,
    required String medicalHistory,
    required String allergies,
  }) async {
    final res = await _apiClient.dio.post('/patientprofile', data: {
      'patientName': patientName,
      'age': age,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'address': address,
      'diagnosis': diagnosis,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
    });
    return PatientProfile.fromJson(res.data['data']);
  }

  Future<PatientProfile> getPatientById(int id) async {
    final res = await _apiClient.dio.get('/patientprofile/$id');
    return PatientProfile.fromJson(res.data['data']);
  }

  Future<bool> deletePatient(int id) async {
    await _apiClient.dio.delete('/patientprofile/$id');
    return true;
  }

  // ======== الأدوية ========
  Future<List<Medication>> getMedications(int profileId) async {
    final res = await _apiClient.dio.get('/medication/profile/$profileId');
    final list = res.data['data'] as List;
    return list.map((e) => Medication.fromJson(e)).toList();
  }

  Future<Medication> addMedication({
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
    final res = await _apiClient.dio.post('/medication', data: {
      'patientProfileId': patientProfileId,
      'name': name,
      'dosage': dosage,
      'schedule': schedule,
      'status': status,
      'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
      'doctorNotes': doctorNotes,
      'takeWithFood': takeWithFood,
    });
    return Medication.fromJson(res.data['data']);
  }

  Future<bool> deleteMedication(int id) async {
    await _apiClient.dio.delete('/medication/$id');
    return true;
  }

  // ======== سجل تناول الأدوية ========
  Future<List<MedicationLog>> getMedicationLogs(int medicationId) async {
    final res =
        await _apiClient.dio.get('/medicationlog/medication/$medicationId');
    final list = res.data['data'] as List;
    return list.map((e) => MedicationLog.fromJson(e)).toList();
  }

  Future<MedicationLog> logMedication({
    required int medicationId,
    required bool isTaken,
    required String note,
  }) async {
    final res = await _apiClient.dio.post('/medicationlog', data: {
      'medicationId': medicationId,
      'isTaken': isTaken,
      'note': note,
      'logDate': DateTime.now().toIso8601String(),
    });
    return MedicationLog.fromJson(res.data['data']);
  }

  // ======== التقارير ========
  Future<List<Report>> getReports(int profileId) async {
    final res = await _apiClient.dio.get('/report/profile/$profileId');
    final list = res.data['data'] as List;
    return list.map((e) => Report.fromJson(e)).toList();
  }

  Future<Report> addReport({
    required int patientProfileId,
    required String title,
    required String content,
    required String reportType,
    required String updatedDiagnosis,
    required String recommendations,
    required bool isVisible,
  }) async {
    final res = await _apiClient.dio.post('/report', data: {
      'patientProfileId': patientProfileId,
      'title': title,
      'content': content,
      'reportType': reportType,
      'updatedDiagnosis': updatedDiagnosis,
      'recommendations': recommendations,
      'isVisible': isVisible,
    });
    return Report.fromJson(res.data['data']);
  }

  Future<bool> deleteReport(int id) async {
    await _apiClient.dio.delete('/report/$id');
    return true;
  }

  // ======== الصيدليات — كل طبيب يرى صيدلياته فقط ========
  Future<List<Pharmacy>> getPharmacies() async {
    final res = await _apiClient.dio.get('/pharmacy');
    final list = res.data['data'] as List;
    return list.map((e) => Pharmacy.fromJson(e)).toList();
  }

  Future<Pharmacy> addPharmacy({
    required String name,
    required String address,
    required String phoneNumber,
    required String workingHours,
    required double latitude,
    required double longitude,
    required bool hasDelivery,
    required String notes,
  }) async {
    final res = await _apiClient.dio.post('/pharmacy', data: {
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'workingHours': workingHours,
      'latitude': latitude,
      'longitude': longitude,
      'hasDelivery': hasDelivery,
      'notes': notes,
    });
    return Pharmacy.fromJson(res.data['data']);
  }

  Future<bool> deletePharmacy(int id) async {
    await _apiClient.dio.delete('/pharmacy/$id');
    return true;
  }
}
