import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../staff/staff_main_screen.dart';
import '../manager/manager_main_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/auth_service.dart';
import '../../utils/snackbar_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    if (email.isEmpty || password.isEmpty) {
      SnackbarUtils.showModernSnackBar(context, 'Email dan password harus diisi', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.login(email, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      final role = result['role'];
      
      SnackbarUtils.showModernSnackBar(context, result['message'] ?? 'Login berhasil');

      if (role == 'manager') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ManagerMainScreen()),
        );
      } else {
        // Default to staff
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StaffMainScreen()),
        );
      }
    } else {
      SnackbarUtils.showModernSnackBar(context, result['message'] ?? 'Login gagal', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  LucideIcons.wallet,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'SyncBudget',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Masuk ke akun Anda',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'user@syncbudget.com',
                        icon: LucideIcons.mail,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Masukkan password',
                        icon: LucideIcons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => Container(
                                padding: const EdgeInsets.all(24),
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 4,
                                      margin: const EdgeInsets.only(bottom: 24),
                                      decoration: BoxDecoration(
                                        color: AppColors.border,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.warningLight.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(LucideIcons.alertTriangle, size: 32, color: AppColors.warning),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Lupa Password?',
                                      style: AppTextStyles.headlineSmall,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Demi keamanan data finansial perusahaan, Anda tidak dapat melakukan reset kata sandi secara mandiri. \n\nSilakan hubungi Administrator (Admin) atau Tim HR/IT untuk meminta pembaruan kata sandi akun Anda.',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight, height: 1.5),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: const Text('Saya Mengerti'),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Lupa Password?',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 0),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Masuk',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.white,
                                ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium,
            prefixIcon: Icon(icon, color: AppColors.neutralLight, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                      color: AppColors.neutralLight,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
