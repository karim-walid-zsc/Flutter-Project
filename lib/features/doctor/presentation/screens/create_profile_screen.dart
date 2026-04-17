// lib/features/doctor/presentation/screens/create_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/doctor_provider.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _historyCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  String _gender = 'ذكر';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _diagnosisCtrl.dispose();
    _historyCtrl.dispose();
    _allergiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final profile = await ref.read(patientsProvider.notifier).createProfile(
          patientName: _nameCtrl.text.trim(),
          age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
          gender: _gender,
          phoneNumber: _phoneCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          diagnosis: _diagnosisCtrl.text.trim(),
          medicalHistory: _historyCtrl.text.trim(),
          allergies: _allergiesCtrl.text.trim(),
        );

    setState(() => _isLoading = false);

    if (profile != null && mounted) {
      // عرض كود الربط للطبيب
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.success),
              SizedBox(width: 8),
              Text('تم إنشاء الملف'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('كود الربط الخاص بالمريض:',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary),
                ),
                child: Text(
                  profile.connectionCode,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryDark,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'أعطِ هذا الكود للمريض والمراقب ليتمكنوا من التسجيل',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(AppConstants.routeDoctorHome);
              },
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _error = 'حدث خطأ أثناء إنشاء الملف');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة ملف مريض جديد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go(AppConstants.routeDoctorHome),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(title: '📋 البيانات الأساسية'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'اسم المريض',
                  prefixIcon: Icon(Icons.person, color: AppTheme.primary),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'اسم المريض مطلوب' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'العمر',
                        prefixIcon:
                            Icon(Icons.cake_outlined, color: AppTheme.primary),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(labelText: 'الجنس'),
                      items: ['ذكر', 'أنثى']
                          .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon:
                      Icon(Icons.phone_outlined, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  prefixIcon:
                      Icon(Icons.location_on_outlined, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: '🏥 المعلومات الطبية'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diagnosisCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'التشخيص',
                  prefixIcon: Icon(Icons.medical_information_outlined,
                      color: AppTheme.primary),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'التشخيص مطلوب' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _historyCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'التاريخ المرضي',
                  prefixIcon:
                      Icon(Icons.history_outlined, color: AppTheme.primary),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _allergiesCtrl,
                decoration: const InputDecoration(
                  labelText: 'الحساسية',
                  prefixIcon: Icon(Icons.warning_amber_outlined,
                      color: AppTheme.warning),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: AppTheme.error)),
                ),
              ],
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isLoading ? null : _create,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('إنشاء الملف وتوليد كود الربط'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}
