// lib/shared/models/auth_models.dart

class AuthResponse {
  final String token;
  final String userId;
  final String fullName;
  final String email;
  final String role;
  final int? patientProfileId;
  final DateTime expiresAt;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    this.patientProfileId,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'] ?? '',
        userId: json['userId'] ?? '',
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? '',
        patientProfileId: json['patientProfileId'],
        expiresAt: DateTime.parse(
            json['expiresAt'] ?? DateTime.now().toIso8601String()),
      );
}

// ======== Patient Profile ========
class PatientProfile {
  final int id;
  final String patientName;
  final int age;
  final String gender;
  final String phoneNumber;
  final String address;
  final String diagnosis;
  final String medicalHistory;
  final String allergies;
  final String connectionCode;
  final String doctorName;
  final bool hasPatientLinked;
  final bool hasObserverLinked;
  final bool isActive;
  final DateTime createdAt;

  PatientProfile({
    required this.id,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.address,
    required this.diagnosis,
    required this.medicalHistory,
    required this.allergies,
    required this.connectionCode,
    required this.doctorName,
    required this.hasPatientLinked,
    required this.hasObserverLinked,
    required this.isActive,
    required this.createdAt,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) => PatientProfile(
        id: json['id'] ?? 0,
        patientName: json['patientName'] ?? '',
        age: json['age'] ?? 0,
        gender: json['gender'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        address: json['address'] ?? '',
        diagnosis: json['diagnosis'] ?? '',
        medicalHistory: json['medicalHistory'] ?? '',
        allergies: json['allergies'] ?? '',
        connectionCode: json['connectionCode'] ?? '',
        doctorName: json['doctorName'] ?? '',
        hasPatientLinked: json['hasPatientLinked'] ?? false,
        hasObserverLinked: json['hasObserverLinked'] ?? false,
        isActive: json['isActive'] ?? true,
        createdAt: DateTime.parse(
            json['createdAt'] ?? DateTime.now().toIso8601String()),
      );
}

// ======== Medication ========
class Medication {
  final int id;
  final String name;
  final String dosage;
  final String schedule;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final String doctorNotes;
  final bool takeWithFood;
  final int patientProfileId;
  final String patientName;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.doctorNotes,
    required this.takeWithFood,
    required this.patientProfileId,
    required this.patientName,
  });

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        dosage: json['dosage'] ?? '',
        schedule: json['schedule'] ?? '',
        status: json['status'] ?? '',
        startDate: DateTime.parse(
            json['startDate'] ?? DateTime.now().toIso8601String()),
        endDate:
            json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        doctorNotes: json['doctorNotes'] ?? '',
        takeWithFood: json['takeWithFood'] ?? false,
        patientProfileId: json['patientProfileId'] ?? 0,
        patientName: json['patientName'] ?? '',
      );
}

// ======== MedicationLog ========
class MedicationLog {
  final int id;
  final DateTime logDate;
  final bool isTaken;
  final String note;
  final int medicationId;
  final String medicationName;

  MedicationLog({
    required this.id,
    required this.logDate,
    required this.isTaken,
    required this.note,
    required this.medicationId,
    required this.medicationName,
  });

  factory MedicationLog.fromJson(Map<String, dynamic> json) => MedicationLog(
        id: json['id'] ?? 0,
        logDate:
            DateTime.parse(json['logDate'] ?? DateTime.now().toIso8601String()),
        isTaken: json['isTaken'] ?? false,
        note: json['note'] ?? '',
        medicationId: json['medicationId'] ?? 0,
        medicationName: json['medicationName'] ?? '',
      );
}

// ======== Report ========
class Report {
  final int id;
  final String title;
  final String content;
  final String reportType;
  final String updatedDiagnosis;
  final String recommendations;
  final DateTime reportDate;
  final bool isVisible;
  final int patientProfileId;
  final String patientName;
  final String doctorName;

  Report({
    required this.id,
    required this.title,
    required this.content,
    required this.reportType,
    required this.updatedDiagnosis,
    required this.recommendations,
    required this.reportDate,
    required this.isVisible,
    required this.patientProfileId,
    required this.patientName,
    required this.doctorName,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        reportType: json['reportType'] ?? '',
        updatedDiagnosis: json['updatedDiagnosis'] ?? '',
        recommendations: json['recommendations'] ?? '',
        reportDate: DateTime.parse(
            json['reportDate'] ?? DateTime.now().toIso8601String()),
        isVisible: json['isVisible'] ?? true,
        patientProfileId: json['patientProfileId'] ?? 0,
        patientName: json['patientName'] ?? '',
        doctorName: json['doctorName'] ?? '',
      );
}

// ======== Pharmacy ========
class Pharmacy {
  final int id;
  final String name;
  final String address;
  final String phoneNumber;
  final String workingHours;
  final double latitude;
  final double longitude;
  final bool hasDelivery;
  final String notes;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.workingHours,
    required this.latitude,
    required this.longitude,
    required this.hasDelivery,
    required this.notes,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) => Pharmacy(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        workingHours: json['workingHours'] ?? '',
        latitude: (json['latitude'] ?? 0).toDouble(),
        longitude: (json['longitude'] ?? 0).toDouble(),
        hasDelivery: json['hasDelivery'] ?? false,
        notes: json['notes'] ?? '',
      );
}
