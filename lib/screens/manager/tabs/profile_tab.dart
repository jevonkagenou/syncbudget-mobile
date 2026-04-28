import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/auth_service.dart';
import '../../../services/profile_service.dart';
import '../../../utils/snackbar_utils.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String userName = "Loading...";
  String userRole = "Loading...";
  String userEmail = "Loading...";
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "Unknown User";
      userRole = prefs.getString('role') ?? "Unknown Role";
      userEmail = prefs.getString('user_email') ?? "No Email";
      
      _nameController.text = userName;
      _emailController.text = userEmail;
      
      _isLoading = false;
    });
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      SnackbarUtils.showModernSnackBar(context, 'Nama dan Email tidak boleh kosong', isError: true);
      return;
    }

    if (_newPasswordController.text.isNotEmpty) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        SnackbarUtils.showModernSnackBar(context, 'Password baru dan konfirmasi tidak cocok', isError: true);
        return;
      }
      if (_currentPasswordController.text.isEmpty) {
        SnackbarUtils.showModernSnackBar(context, 'Password saat ini harus diisi jika ingin mengubah password', isError: true);
        return;
      }
      if (_newPasswordController.text.length < 8) {
        SnackbarUtils.showModernSnackBar(context, 'Password baru minimal 8 karakter', isError: true);
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    final result = await ProfileService.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (result['success']) {
      SnackbarUtils.showModernSnackBar(context, result['message']);
      
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      setState(() {
        userName = _nameController.text.trim();
        userEmail = _emailController.text.trim();
      });
    } else {
      SnackbarUtils.showModernSnackBar(context, result['message'], isError: true);
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
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
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.neutralLight,
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                
                // Panggil API logout dan hapus data lokal
                await AuthService.logout();
                
                if (!mounted) return;
                
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadUserData,
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                    userRole == 'manager' ? 'Manajer Keuangan' : 'Staff Operasional',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Update detail profil Anda di sini',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  
                  // Profile Form
                  _buildTextField(label: 'NAMA LENGKAP', controller: _nameController),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'EMAIL', controller: _emailController),
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
                        _buildPasswordField(label: 'CURRENT PASSWORD', controller: _currentPasswordController, obscure: true),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildPasswordField(label: 'NEW PASSWORD', controller: _newPasswordController, obscure: true)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPasswordField(label: 'CONFIRM', controller: _confirmPasswordController, obscure: true)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
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
                    child: _isSaving 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : Text(
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
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, String? value, TextEditingController? controller, bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: value != null ? ValueKey(value) : null,
          controller: controller,
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

  Widget _buildPasswordField({required String label, required TextEditingController controller, required bool obscure}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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
