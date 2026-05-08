// lib/features/doctor/presentation/screens/doctor_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/doctor_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../shared/models/auth_models.dart';

class DoctorHomeScreen extends ConsumerStatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  ConsumerState<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends ConsumerState<DoctorHomeScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _searchFilter = 'name'; // name / date / diagnosis

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ======== فلترة المرضى حسب نوع البحث ========
  List<PatientProfile> _filterPatients(List<PatientProfile> patients) {
    if (_searchQuery.isEmpty) return patients;

    return patients.where((p) {
      switch (_searchFilter) {
        case 'name':
          return p.patientName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
        case 'diagnosis':
          return p.diagnosis.toLowerCase().contains(_searchQuery.toLowerCase());
        case 'date':
          // البحث بالتاريخ: يقبل يوم/شهر/سنة أو جزء منها
          final dateStr =
              '${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}';
          return dateStr.contains(_searchQuery);
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('لوحة تحكم الطبيب'),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_pharmacy_outlined),
            tooltip: 'الصيدليات',
            onPressed: () => context.go(AppConstants.routePharmacies),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppConstants.routeLogin);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ======== رأس الصفحة ========
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.medical_services,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('مرحباً،',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14)),
                        const Text('قائمة مرضاك',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const Spacer(),
                    patientsAsync.when(
                      data: (patients) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${patients.length} مريض',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ======== شريط البحث ========
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(
                        fontSize: 14, color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: _getHintText(),
                      hintStyle: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14),
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.primary, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppTheme.textSecondary, size: 20),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ======== أزرار فلتر البحث ========
                Row(
                  children: [
                    _FilterChip(
                      label: '👤 الاسم',
                      value: 'name',
                      selected: _searchFilter == 'name',
                      onTap: () => setState(() => _searchFilter = 'name'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '🏥 التشخيص',
                      value: 'diagnosis',
                      selected: _searchFilter == 'diagnosis',
                      onTap: () => setState(() => _searchFilter = 'diagnosis'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '📅 التاريخ',
                      value: 'date',
                      selected: _searchFilter == 'date',
                      onTap: () => setState(() => _searchFilter = 'date'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ======== قائمة المرضى ========
          Expanded(
            child: patientsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off,
                        color: AppTheme.textSecondary, size: 48),
                    const SizedBox(height: 12),
                    Text('تعذّر تحميل البيانات',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => ref.invalidate(patientsProvider),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
              data: (patients) {
                final filtered = _filterPatients(patients);
                if (patients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: AppTheme.primary.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text('لا يوجد مرضى بعد',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('اضغط + لإضافة ملف مريض جديد',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 56, color: AppTheme.primary.withOpacity(0.4)),
                        const SizedBox(height: 14),
                        Text(
                          'لا توجد نتائج لـ "$_searchQuery"',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Text('مسح البحث'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // ======== نتائج البحث ========
                    if (_searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              '${filtered.length} نتيجة من ${patients.length}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),

                    Expanded(
                      child: RefreshIndicator(
                        color: AppTheme.primary,
                        onRefresh: () async => ref.invalidate(patientsProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 4),
                          itemBuilder: (context, i) => _PatientCard(
                            patient: filtered[i],
                            searchQuery: _searchQuery,
                            searchFilter: _searchFilter,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppConstants.routeCreateProfile),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text('مريض جديد',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  String _getHintText() {
    switch (_searchFilter) {
      case 'name':
        return 'ابحث باسم المريض...';
      case 'diagnosis':
        return 'ابحث بالتشخيص...';
      case 'date':
        return 'ابحث بالتاريخ (مثال: 20/4/2026)...';
      default:
        return 'بحث...';
    }
  }
}

// ======== زر فلتر البحث ========
class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppTheme.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}

// ======== بطاقة المريض مع تمييز نص البحث ========
class _PatientCard extends StatelessWidget {
  final PatientProfile patient;
  final String searchQuery;
  final String searchFilter;

  const _PatientCard({
    required this.patient,
    required this.searchQuery,
    required this.searchFilter,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${patient.createdAt.day}/${patient.createdAt.month}/${patient.createdAt.year}';

    return Card(
      child: InkWell(
        onTap: () => context.go('/doctor/patient/${patient.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ======== أفاتار المريض ========
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    patient.patientName.isNotEmpty
                        ? patient.patientName[0]
                        : '؟',
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ======== اسم المريض مع تمييز نص البحث ========
                    _HighlightText(
                      text: patient.patientName,
                      query: searchFilter == 'name' ? searchQuery : '',
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                    const SizedBox(height: 4),
                    // ======== التشخيص مع تمييز نص البحث ========
                    _HighlightText(
                      text: patient.diagnosis,
                      query: searchFilter == 'diagnosis' ? searchQuery : '',
                      style: Theme.of(context).textTheme.bodyMedium!,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // ======== التاريخ ========
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: searchFilter == 'date' &&
                                    searchQuery.isNotEmpty &&
                                    dateStr.contains(searchQuery)
                                ? AppTheme.primary.withOpacity(0.15)
                                : AppTheme.background,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 11,
                                color: searchFilter == 'date' &&
                                        searchQuery.isNotEmpty &&
                                        dateStr.contains(searchQuery)
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: searchFilter == 'date' &&
                                          searchQuery.isNotEmpty &&
                                          dateStr.contains(searchQuery)
                                      ? AppTheme.primary
                                      : AppTheme.textSecondary,
                                  fontWeight: searchFilter == 'date' &&
                                          searchQuery.isNotEmpty &&
                                          dateStr.contains(searchQuery)
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(
                          label: 'مريض',
                          active: patient.hasPatientLinked,
                        ),
                        const SizedBox(width: 6),
                        _StatusBadge(
                          label: 'مراقب',
                          active: patient.hasObserverLinked,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ======== Widget لتمييز نص البحث بلون مختلف ========
class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final int? maxLines;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.style,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
          style: style,
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text,
          style: style,
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null);
    }

    // تقسيم النص لثلاثة أجزاء — قبل وأثناء وبعد الكلمة المبحوثة
    return RichText(
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: style.copyWith(
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }
}

// ======== Badge حالة الربط ========
class _StatusBadge extends StatelessWidget {
  final String label;
  final bool active;
  const _StatusBadge({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? AppTheme.success.withOpacity(0.1) : AppTheme.divider,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 12,
            color: active ? AppTheme.success : AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? AppTheme.success : AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
