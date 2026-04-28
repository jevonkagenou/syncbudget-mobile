import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'tabs/home_tab.dart';
import 'tabs/pengajuan_tab.dart';
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

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      HomeTab(
        onNavigateToPengajuan: () => _changeTab(1),
      ),
      const PengajuanTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
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
              gap: 8,
              color: AppColors.neutralLight,
              activeColor: AppColors.primary,
              iconSize: 24,
              tabBackgroundColor: AppColors.primaryLight.withValues(alpha: 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              selectedIndex: _currentIndex,
              onTabChange: _changeTab,
              tabs: [
                GButton(
                  icon: LucideIcons.home,
                  text: 'Beranda',
                  textStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                ),
                GButton(
                  icon: LucideIcons.fileText,
                  text: 'Pengajuan',
                  textStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                ),
                GButton(
                  icon: LucideIcons.user,
                  text: 'Profil',
                  textStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
