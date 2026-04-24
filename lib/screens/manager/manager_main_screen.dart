import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'tabs/home_tab.dart';
import 'tabs/budget_tab.dart';
import 'tabs/pengajuan_tab.dart';
import 'tabs/log_tab.dart';
import 'tabs/profile_tab.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class ManagerMainScreen extends StatefulWidget {
  const ManagerMainScreen({super.key});

  @override
  State<ManagerMainScreen> createState() => _ManagerMainScreenState();
}

class _ManagerMainScreenState extends State<ManagerMainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  final List<Widget> _screens = [
    const HomeTab(),
    const BudgetTab(),
    const PengajuanTab(),
    const LogTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            child: GNav(
              rippleColor: AppColors.primaryLight.withValues(alpha: 0.3),
              hoverColor: AppColors.primaryLight.withValues(alpha: 0.1),
              haptic: true,
              tabBorderRadius: 24, 
              tabActiveBorder: Border.all(color: Colors.transparent, width: 0), 
              tabBorder: Border.all(color: Colors.transparent, width: 0), 
              tabShadow: [BoxShadow(color: AppColors.primaryLight.withValues(alpha: 0.1), blurRadius: 8)],
              curve: Curves.fastOutSlowIn,
              duration: const Duration(milliseconds: 400),
              gap: 6,
              color: AppColors.neutralLight,
              activeColor: AppColors.primary,
              iconSize: 22,
              tabBackgroundColor: AppColors.primaryLight.withValues(alpha: 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              tabs: [
                GButton(
                  icon: LucideIcons.home,
                  text: 'Beranda',
                  textStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontSize: 11),
                ),
                GButton(
                  icon: LucideIcons.wallet,
                  text: 'Budget',
                  textStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontSize: 11),
                ),
                GButton(
                  icon: LucideIcons.fileText,
                  text: 'Pengajuan',
                  textStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontSize: 11),
                ),
                GButton(
                  icon: LucideIcons.clipboardList,
                  text: 'Log',
                  textStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontSize: 11),
                ),
                GButton(
                  icon: LucideIcons.user,
                  text: 'Profil',
                  textStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
