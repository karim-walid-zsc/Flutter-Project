// lib/features/doctor/presentation/screens/patient_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/doctor_provider.dart';
import '../../../../shared/models/auth_models.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  final int patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  ConsumerState<PatientDetailScreen> createState() =>
      _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen>
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
    final profileAsync = ref.watch(patientDetailProvider(widget.patientId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: profileAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (profile) => NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: AppTheme.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => context.go(AppConstants.routeDoctorHome),
              ),
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
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              profile.patientName.isNotEmpty
                                  ? profile.patientName[0]
                                  : '؟',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.patientName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('${profile.age} سنة • ${profile.gender}',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 14)),
                              const SizedBox(height: 6),
                              // كود الربط
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'كود الربط: ${profile.connectionCode}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1),
                                ),
                              ),
                            ],
                          ),
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
                  Tab(text: 'معلومات'),
                  Tab(text: 'أدوية'),
                  Tab(text: 'تقارير'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _InfoTab(profile: profile),
              _MedicationsTab(profileId: widget.patientId),
              _ReportsTab(profileId: widget.patientId),
            ],
          ),
        ),
      ),
    );
  }
}

// ======== تبويب المعلومات ========
class _InfoTab extends StatelessWidget {
  final PatientProfile profile;
  const _InfoTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InfoCard(
              title: 'التشخيص',
              value: profile.diagnosis,
              icon: Icons.medical_information_outlined),
          _InfoCard(
              title: 'التاريخ المرضي',
              value: profile.medicalHistory.isEmpty
                  ? 'لا يوجد'
                  : profile.medicalHistory,
              icon: Icons.history),
          _InfoCard(
              title: 'الحساسية',
              value: profile.allergies.isEmpty ? 'لا يوجد' : profile.allergies,
              icon: Icons.warning_amber_outlined),
          _InfoCard(
              title: 'العنوان',
              value: profile.address.isEmpty ? 'غير محدد' : profile.address,
              icon: Icons.location_on_outlined),
          _InfoCard(
              title: 'الهاتف',
              value: profile.phoneNumber.isEmpty
                  ? 'غير محدد'
                  : profile.phoneNumber,
              icon: Icons.phone_outlined),
          Row(
            children: [
              Expanded(
                  child: _StatusCard(
                      label: 'المريض مرتبط', active: profile.hasPatientLinked)),
              const SizedBox(width: 10),
              Expanded(
                  child: _StatusCard(
                      label: 'المراقب مرتبط',
                      active: profile.hasObserverLinked)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _InfoCard(
      {required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final bool active;
  const _StatusCard({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              active ? Icons.check_circle : Icons.cancel_outlined,
              color: active ? AppTheme.success : AppTheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ======== تبويب الأدوية ========
class _MedicationsTab extends ConsumerWidget {
  final int profileId;
  const _MedicationsTab({required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsAsync = ref.watch(medicationsProvider(profileId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: medsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (meds) => meds.isEmpty
            ? const Center(child: Text('لا توجد أدوية — اضغط + لإضافة دواء'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: meds.length,
                itemBuilder: (_, i) => _MedCard(
                  med: meds[i],
                  onDelete: () => ref
                      .read(medicationsProvider(profileId).notifier)
                      .deleteMedication(meds[i].id),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _showAddMedDialog(context, ref, profileId),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _MedCard extends StatelessWidget {
  final Medication med;
  final VoidCallback onDelete;
  const _MedCard({required this.med, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        med.status == 'نشط' ? AppTheme.success : AppTheme.textSecondary;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(med.name,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(med.status,
                      style: TextStyle(color: statusColor, fontSize: 12)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.error, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            const Divider(height: 16),
            Text('الجرعة: ${med.dosage}',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text('الجدول: ${med.schedule}',
                style: Theme.of(context).textTheme.bodyMedium),
            if (med.doctorNotes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('ملاحظات: ${med.doctorNotes}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
            if (med.takeWithFood)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: const [
                    Icon(Icons.restaurant, size: 14, color: AppTheme.warning),
                    SizedBox(width: 4),
                    Text('يؤخذ مع الطعام',
                        style:
                            TextStyle(color: AppTheme.warning, fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ======== تبويب التقارير ========
class _ReportsTab extends ConsumerWidget {
  final int profileId;
  const _ReportsTab({required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider(profileId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: reportsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (reports) => reports.isEmpty
            ? const Center(child: Text('لا توجد تقارير — اضغط + لإضافة تقرير'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                itemBuilder: (_, i) => _ReportCard(
                  report: reports[i],
                  onDelete: () => ref
                      .read(reportsProvider(profileId).notifier)
                      .deleteReport(reports[i].id),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _showAddReportDialog(context, ref, profileId),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onDelete;
  const _ReportCard({required this.report, required this.onDelete});

  @override
  Widget build(BuildContext context) {
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
                    color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(report.title,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.error, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            const Divider(height: 16),
            Text(report.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium),
            if (report.recommendations.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('التوصيات: ${report.recommendations}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${report.reportDate.day}/${report.reportDate.month}/${report.reportDate.year}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: report.isVisible
                        ? AppTheme.success.withOpacity(0.1)
                        : AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    report.isVisible ? 'مرئي للمريض' : 'مخفي',
                    style: TextStyle(
                        color: report.isVisible
                            ? AppTheme.success
                            : AppTheme.error,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ======== ديالوج إضافة دواء ========
void _showAddMedDialog(BuildContext context, WidgetRef ref, int profileId) {
  final nameCtrl = TextEditingController();
  final dosageCtrl = TextEditingController();
  final scheduleCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  bool takeWithFood = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إضافة دواء جديد',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'اسم الدواء'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dosageCtrl,
              decoration: const InputDecoration(labelText: 'الجرعة'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: scheduleCtrl,
              decoration: const InputDecoration(labelText: 'جدول الجرعات'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(labelText: 'ملاحظات الطبيب'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: takeWithFood,
                  activeColor: AppTheme.primary,
                  onChanged: (v) => setState(() => takeWithFood = v!),
                ),
                const Text('يؤخذ مع الطعام'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(medicationsProvider(profileId).notifier)
                    .addMedication(
                      patientProfileId: profileId,
                      name: nameCtrl.text,
                      dosage: dosageCtrl.text,
                      schedule: scheduleCtrl.text,
                      status: 'نشط',
                      startDate: DateTime.now(),
                      doctorNotes: notesCtrl.text,
                      takeWithFood: takeWithFood,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('إضافة الدواء'),
            ),
          ],
        ),
      ),
    ),
  );
}

// ======== ديالوج إضافة تقرير ========
void _showAddReportDialog(BuildContext context, WidgetRef ref, int profileId) {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final diagnosisCtrl = TextEditingController();
  final recommendCtrl = TextEditingController();
  bool isVisible = true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إضافة تقرير جديد',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'عنوان التقرير'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'محتوى التقرير'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: diagnosisCtrl,
                decoration: const InputDecoration(labelText: 'التشخيص المحدّث'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: recommendCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'التوصيات'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Switch(
                    value: isVisible,
                    activeColor: AppTheme.primary,
                    onChanged: (v) => setState(() => isVisible = v),
                  ),
                  Text(isVisible ? 'مرئي للمريض والمراقب' : 'مخفي عن المريض'),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(reportsProvider(profileId).notifier).addReport(
                        patientProfileId: profileId,
                        title: titleCtrl.text,
                        content: contentCtrl.text,
                        reportType: 'متابعة دورية',
                        updatedDiagnosis: diagnosisCtrl.text,
                        recommendations: recommendCtrl.text,
                        isVisible: isVisible,
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('إضافة التقرير'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
