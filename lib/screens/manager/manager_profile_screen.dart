import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../auth/login_screen.dart';

class ManagerProfileScreen extends StatefulWidget {
  const ManagerProfileScreen({super.key});

  @override
  State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  final String userName = "Melissa Manager";
  final String userRole = "Manajer";
  final String userEmail = "manajer@syncbudget.com";

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Konfirmasi Keluar',
            style: AppTextStyles.headlineSmall,
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari sesi Manager?',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.neutralLight,
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(LucideIcons.user, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Hello, ${userName.split(" ").first}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.bell, color: AppColors.primary),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Profile Intro
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.border,
                    ),
                    child: Center(
                      child: Icon(LucideIcons.user, size: 40, color: AppColors.neutralLight),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userRole,
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Update detail profil Anda di sini',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  
                  // Profile Form
                  _buildTextField(label: 'NAMA LENGKAP', value: userName),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'EMAIL', value: userEmail),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'ROLE', 
                    value: userRole,
                    isReadOnly: true,
                  ),
                  const SizedBox(height: 32),
                  
                  // Security Area
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.shield, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              'Keamanan Akun',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pastikan kata sandi Anda kuat dan diperbarui secara berkala untuk menjaga keamanan data finansial.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildPasswordField(label: 'CURRENT PASSWORD', obscure: true),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildPasswordField(label: 'NEW PASSWORD', obscure: true)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPasswordField(label: 'CONFIRM', obscure: true)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size(double.infinity, 0),
                      elevation: 0,
                    ),
                    child: Text(
                      'Simpan Perubahan',
                      style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _confirmLogout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size(double.infinity, 0),
                      elevation: 0,
                    ),
                    child: Text(
                      'Keluar',
                      style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String value, bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          readOnly: isReadOnly,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isReadOnly ? AppColors.neutralLight : AppColors.neutral,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isReadOnly ? AppColors.border.withValues(alpha: 0.5) : AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({required String label, required bool obscure}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
