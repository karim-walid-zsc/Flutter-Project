// lib/features/auth/presentation/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  String _selectedRole = AppConstants.roleDoctor;
  bool _obscurePass = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authProvider.notifier).register(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          role: _selectedRole,
          connectionCode: _selectedRole != AppConstants.roleDoctor
              ? _codeCtrl.text.trim()
              : null,
        );
    if (success && mounted) {
      final role = ref.read(authProvider).user?.role;
      if (role == AppConstants.roleDoctor) {
        context.go(AppConstants.routeDoctorHome);
      } else if (role == AppConstants.rolePatient) {
        context.go(AppConstants.routePatientHome);
      } else {
        context.go(AppConstants.routeObserverHome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final needsCode = _selectedRole != AppConstants.roleDoctor;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go(AppConstants.routeLogin),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ======== اختيار نوع الحساب ========
                Text('نوع الحساب',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _RoleChip(
                      label: '👨‍⚕️ طبيب',
                      value: AppConstants.roleDoctor,
                      selected: _selectedRole == AppConstants.roleDoctor,
                      onTap: () => setState(
                          () => _selectedRole = AppConstants.roleDoctor),
                    ),
                    const SizedBox(width: 8),
                    _RoleChip(
                      label: '🧑‍🦽 مريض',
                      value: AppConstants.rolePatient,
                      selected: _selectedRole == AppConstants.rolePatient,
                      onTap: () => setState(
                          () => _selectedRole = AppConstants.rolePatient),
                    ),
                    const SizedBox(width: 8),
                    _RoleChip(
                      label: '👁 مراقب',
                      value: AppConstants.roleObserver,
                      selected: _selectedRole == AppConstants.roleObserver,
                      onTap: () => setState(
                          () => _selectedRole = AppConstants.roleObserver),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ======== حقل الاسم ========
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    prefixIcon:
                        Icon(Icons.person_outline, color: AppTheme.primary),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'أدخل اسمك الكامل' : null,
                ),
                const SizedBox(height: 14),

                // ======== حقل البريد ========
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon:
                        Icon(Icons.email_outlined, color: AppTheme.primary),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'أدخل البريد الإلكتروني' : null,
                ),
                const SizedBox(height: 14),

                // ======== حقل رقم الهاتف ========
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon:
                        Icon(Icons.phone_outlined, color: AppTheme.primary),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'أدخل رقم الهاتف' : null,
                ),
                const SizedBox(height: 14),

                // ======== حقل كلمة المرور ========
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: AppTheme.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textSecondary),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 6
                      ? 'كلمة المرور 6 أحرف على الأقل'
                      : null,
                ),

                // ======== حقل كود الربط (للمريض والمراقب فقط) ========
                if (needsCode) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppTheme.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'أدخل كود الربط الذي أعطاك إياه طبيبك',
                            style: const TextStyle(
                                color: AppTheme.primaryDark, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _codeCtrl,
                    textDirection: TextDirection.ltr,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'كود الربط',
                      prefixIcon: Icon(Icons.link, color: AppTheme.primary),
                      hintText: 'مثال: A3BX9K2M',
                    ),
                    validator: (v) => needsCode && (v == null || v.isEmpty)
                        ? 'كود الربط مطلوب'
                        : null,
                  ),
                ],

                const SizedBox(height: 12),

                // ======== رسالة الخطأ ========
                if (authState.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(authState.error!,
                        style: const TextStyle(
                            color: AppTheme.error, fontSize: 13)),
                  ),

                const SizedBox(height: 24),

                // ======== زر التسجيل ========
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _register,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('إنشاء الحساب'),
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('لديك حساب بالفعل؟',
                        style: Theme.of(context).textTheme.bodyMedium),
                    TextButton(
                      onPressed: () => context.go(AppConstants.routeLogin),
                      child: const Text('تسجيل الدخول',
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? AppTheme.primary : AppTheme.divider),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: AppTheme.primary.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
