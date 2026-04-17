// lib/features/pharmacy/presentation/screens/pharmacies_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../doctor/providers/doctor_provider.dart';

class PharmaciesScreen extends ConsumerWidget {
  const PharmaciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pharmaciesAsync = ref.watch(pharmaciesProvider);

    // ======== قراءة الدور مباشرة من authProvider ========
    // authProvider هو المصدر الوحيد الموثوق للدور الحالي
    final currentUser = ref.watch(authProvider).user;
    final role = currentUser?.role ?? '';
    final isDoctor = role == AppConstants.roleDoctor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الصيدليات الموصى بها'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            // الرجوع للصفحة الصحيحة حسب الدور
            if (isDoctor) {
              context.go(AppConstants.routeDoctorHome);
            } else if (role == AppConstants.roleObserver) {
              context.go(AppConstants.routeObserverHome);
            } else {
              context.go(AppConstants.routePatientHome);
            }
          },
        ),
      ),
      body: pharmaciesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off,
                  color: AppTheme.textSecondary, size: 48),
              const SizedBox(height: 12),
              Text('تعذّر تحميل الصيدليات',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(pharmaciesProvider),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        data: (pharmacies) => pharmacies.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_pharmacy_outlined,
                        size: 64, color: AppTheme.primary.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    Text(
                      isDoctor
                          ? 'لا توجد صيدليات — اضغط + لإضافة'
                          : 'لا توجد صيدليات موصى بها بعد',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () async => ref.invalidate(pharmaciesProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pharmacies.length,
                  itemBuilder: (_, i) => _PharmacyCard(
                    pharmacy: pharmacies[i],
                    // ======== زر الحذف للطبيب فقط ========
                    isDoctor: isDoctor,
                    onDelete: isDoctor
                        ? () => ref
                            .read(pharmaciesProvider.notifier)
                            .deletePharmacy(pharmacies[i].id)
                        : null,
                  ),
                ),
              ),
      ),

      // ======== زر الإضافة للطبيب فقط ========
      floatingActionButton: isDoctor
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primary,
              onPressed: () => _showAddPharmacyDialog(context, ref),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('إضافة صيدلية',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}

// ======== بطاقة الصيدلية ========
class _PharmacyCard extends StatelessWidget {
  final dynamic pharmacy;
  final bool isDoctor;
  final VoidCallback? onDelete;

  const _PharmacyCard({
    required this.pharmacy,
    required this.isDoctor,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child:
                      const Icon(Icons.local_pharmacy, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pharmacy.name,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(pharmacy.address,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (pharmacy.hasDelivery)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('توصيل',
                        style:
                            TextStyle(color: AppTheme.success, fontSize: 11)),
                  ),
                // ======== حذف للطبيب فقط ========
                if (isDoctor && onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppTheme.error, size: 20),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const Divider(height: 16),
            if (pharmacy.phoneNumber.isNotEmpty)
              _DetailRow(
                  icon: Icons.phone_outlined, text: pharmacy.phoneNumber),
            if (pharmacy.workingHours.isNotEmpty) ...[
              const SizedBox(height: 6),
              _DetailRow(icon: Icons.access_time, text: pharmacy.workingHours),
            ],
            if (pharmacy.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              _DetailRow(icon: Icons.notes_outlined, text: pharmacy.notes),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}

// ======== ديالوج إضافة صيدلية ========
void _showAddPharmacyDialog(BuildContext context, WidgetRef ref) {
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final hoursCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  bool hasDelivery = false;

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
              const Row(
                children: [
                  Icon(Icons.local_pharmacy, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Text('إضافة صيدلية جديدة',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم الصيدلية'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'العنوان'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hoursCtrl,
                decoration: const InputDecoration(labelText: 'ساعات العمل'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Switch(
                    value: hasDelivery,
                    activeColor: AppTheme.primary,
                    onChanged: (v) => setState(() => hasDelivery = v),
                  ),
                  const Text('يوجد خدمة توصيل'),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || addressCtrl.text.isEmpty) return;
                  await ref.read(pharmaciesProvider.notifier).addPharmacy(
                        name: nameCtrl.text,
                        address: addressCtrl.text,
                        phoneNumber: phoneCtrl.text,
                        workingHours: hoursCtrl.text,
                        latitude: 0,
                        longitude: 0,
                        hasDelivery: hasDelivery,
                        notes: notesCtrl.text,
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('إضافة الصيدلية'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
