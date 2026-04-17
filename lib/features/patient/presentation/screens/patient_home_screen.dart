// lib/features/patient/presentation/screens/patient_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../doctor/providers/doctor_provider.dart';
import '../../../../shared/models/auth_models.dart';

// ======== Provider لجلب profileId من الـ Storage ========
final myProfileIdProvider = FutureProvider<int?>((ref) async {
  return ref.watch(authRepositoryProvider).getSavedPatientProfileId();
});

// ======== Provider لجلب دور المستخدم الحالي ========
final currentUserRoleProvider = FutureProvider<String?>((ref) async {
  return ref.watch(authRepositoryProvider).getSavedRole();
});

class PatientHomeScreen extends ConsumerStatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  ConsumerState<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends ConsumerState<PatientHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileIdAsync = ref.watch(myProfileIdProvider);
    final roleAsync = ref.watch(currentUserRoleProvider);

    return profileIdAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
      data: (profileId) {
        if (profileId == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.link_off,
                      size: 64, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  const Text('لم يتم ربط حسابك بعد'),
                  TextButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go(AppConstants.routeLogin);
                    },
                    child: const Text('تسجيل الخروج'),
                  ),
                ],
              ),
            ),
          );
        }

        final profileAsync = ref.watch(patientDetailProvider(profileId));
        final role = roleAsync.value ?? AppConstants.rolePatient;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: profileAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primary)),
            error: (e, _) => Center(child: Text('خطأ: $e')),
            data: (profile) => NestedScrollView(
              headerSliverBuilder: (_, __) => [
                SliverAppBar(
                  expandedHeight: 160,
                  pinned: true,
                  backgroundColor: AppTheme.primary,
                  automaticallyImplyLeading: false,
                  actions: [
                    // ======== زر الصيدليات ========
                    IconButton(
                      icon: const Icon(Icons.local_pharmacy_outlined,
                          color: Colors.white),
                      tooltip: 'الصيدليات',
                      onPressed: () => context.go(AppConstants.routePharmacies),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go(AppConstants.routeLogin);
                        }
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                // أيقونة تدل على الدور
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    role == AppConstants.roleObserver
                                        ? '👁 مراقب'
                                        : '🧑‍🦽 مريض',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(profile.patientName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                              'الطبيب المعالج: ${profile.doctorName}',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    tabs: const [
                      Tab(text: 'ملفي'),
                      Tab(text: 'أدويتي'),
                      Tab(text: 'تقاريري'),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _PatientInfoTab(profile: profile),
                  _PatientMedsTab(profileId: profileId, role: role),
                  _PatientReportsTab(profileId: profileId),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ======== تبويب المعلومات ========
class _PatientInfoTab extends StatelessWidget {
  final PatientProfile profile;
  const _PatientInfoTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InfoTile(
              icon: Icons.medical_information_outlined,
              title: 'التشخيص',
              value: profile.diagnosis),
          _InfoTile(
              icon: Icons.history,
              title: 'التاريخ المرضي',
              value: profile.medicalHistory.isEmpty
                  ? 'لا يوجد'
                  : profile.medicalHistory),
          _InfoTile(
              icon: Icons.warning_amber_outlined,
              title: 'الحساسية',
              value: profile.allergies.isEmpty ? 'لا يوجد' : profile.allergies),
          _InfoTile(
              icon: Icons.cake_outlined,
              title: 'العمر',
              value: '${profile.age} سنة'),
          _InfoTile(icon: Icons.wc, title: 'الجنس', value: profile.gender),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoTile(
      {required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

// ======== تبويب الأدوية ========
class _PatientMedsTab extends ConsumerWidget {
  final int profileId;
  final String role;
  const _PatientMedsTab({required this.profileId, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsAsync = ref.watch(medicationsProvider(profileId));
    return medsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary)),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (meds) => meds.isEmpty
          ? const Center(child: Text('لا توجد أدوية مسجلة بعد'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meds.length,
              itemBuilder: (_, i) => _PatientMedCard(med: meds[i], role: role),
            ),
    );
  }
}

// ======== بطاقة الدواء مع زر التسجيل ========
class _PatientMedCard extends ConsumerWidget {
  final Medication med;
  final String role;
  const _PatientMedCard({required this.med, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(medicationLogsProvider(med.id));

    // هل أخذ الدواء اليوم؟
    final takenToday = logsAsync.whenOrNull(
          data: (logs) => logs.any((l) =>
              l.isTaken &&
              l.logDate.day == DateTime.now().day &&
              l.logDate.month == DateTime.now().month &&
              l.logDate.year == DateTime.now().year),
        ) ??
        false;

    final isPatient = role == AppConstants.rolePatient;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(med.name,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                // ======== زر التسجيل — المريض فقط ========
                if (isPatient)
                  GestureDetector(
                    onTap: takenToday
                        ? null // لو أخذ الدواء مش هيضغط تاني
                        : () async {
                            final note = await _showLogDialog(context);
                            if (note != null) {
                              await ref
                                  .read(medicationLogsProvider(med.id).notifier)
                                  .logMedication(
                                    medicationId: med.id,
                                    isTaken: true,
                                    note: note,
                                  );
                            }
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: takenToday
                            ? AppTheme.success
                            : AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color:
                              takenToday ? AppTheme.success : AppTheme.primary,
                          width: 2,
                        ),
                        boxShadow: takenToday
                            ? [
                                BoxShadow(
                                    color: AppTheme.success.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3))
                              ]
                            : [],
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: takenToday ? Colors.white : AppTheme.primary,
                        size: 26,
                      ),
                    ),
                  )
                else
                  // ======== المراقب يرى الحالة فقط بدون ضغط ========
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: takenToday
                          ? AppTheme.success.withOpacity(0.15)
                          : AppTheme.divider,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: takenToday
                          ? AppTheme.success
                          : AppTheme.textSecondary,
                      size: 26,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text('الجرعة: ${med.dosage}',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text('الموعد: ${med.schedule}',
                style: Theme.of(context).textTheme.bodyMedium),
            if (med.doctorNotes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('ملاحظة الطبيب: ${med.doctorNotes}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
            ],
            if (med.takeWithFood)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(Icons.restaurant, size: 14, color: AppTheme.warning),
                    SizedBox(width: 4),
                    Text('يؤخذ مع الطعام',
                        style:
                            TextStyle(color: AppTheme.warning, fontSize: 12)),
                  ],
                ),
              ),

            // ======== شريط الحالة اليومية ========
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: takenToday
                    ? AppTheme.success.withOpacity(0.1)
                    : AppTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    takenToday ? '✅' : '⏰',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    takenToday
                        ? 'تم تناول الدواء اليوم'
                        : isPatient
                            ? 'اضغط ✓ بعد أخذ الدواء'
                            : 'لم يُؤخذ بعد',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: takenToday ? AppTheme.success : AppTheme.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showLogDialog(BuildContext context) async {
    final noteCtrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.medication, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('تسجيل تناول الدواء'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('هل أخذت الدواء؟ يمكنك إضافة ملاحظة اختيارية'),
            const SizedBox(height: 14),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                labelText: 'ملاحظة (اختياري)',
                prefixIcon: Icon(Icons.note_outlined, color: AppTheme.primary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('إلغاء',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, noteCtrl.text),
            child: const Text('✅ نعم، أخذته'),
          ),
        ],
      ),
    );
  }
}

// ======== تبويب التقارير ========
class _PatientReportsTab extends ConsumerWidget {
  final int profileId;
  const _PatientReportsTab({required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider(profileId));
    return reportsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary)),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (reports) => reports.isEmpty
          ? const Center(child: Text('لا توجد تقارير بعد'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (_, i) {
                final r = reports[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.description_outlined,
                                color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(r.title,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                            ),
                          ],
                        ),
                        const Divider(height: 14),
                        Text(r.content,
                            style: Theme.of(context).textTheme.bodyMedium),
                        if (r.recommendations.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.tips_and_updates_outlined,
                                    color: AppTheme.primary, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(r.recommendations,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.primaryDark)),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '${r.reportDate.day}/${r.reportDate.month}/${r.reportDate.year}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
