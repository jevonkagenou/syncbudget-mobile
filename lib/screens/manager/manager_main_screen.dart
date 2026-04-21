import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/colors.dart';
import 'manager_dashboard_screen.dart';
import 'manager_budget_screen.dart';
import 'manager_reimbursement_screen.dart';
import 'manager_log_screen.dart';
import 'manager_profile_screen.dart';

class ManagerMainScreen extends StatefulWidget {
  const ManagerMainScreen({super.key});

  @override
  State<ManagerMainScreen> createState() => _ManagerMainScreenState();
}

class _ManagerMainScreenState extends State<ManagerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ManagerDashboardScreen(),
    const ManagerBudgetScreen(),
    const ManagerReimbursementScreen(),
    const ManagerLogScreen(),
    const ManagerProfileScreen(),
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.neutralLight,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.layoutDashboard),
              activeIcon: Icon(LucideIcons.layoutDashboard, color: AppColors.primary),
              label: 'DASHBOARD',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.wallet),
              activeIcon: Icon(LucideIcons.wallet, color: AppColors.primary),
              label: 'BUDGET',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.fileText),
              activeIcon: Icon(LucideIcons.fileText, color: AppColors.primary),
              label: 'PENGAJUAN',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.clipboardList),
              activeIcon: Icon(LucideIcons.clipboardList, color: AppColors.primary),
              label: 'LOG',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              activeIcon: Icon(LucideIcons.user, color: AppColors.primary),
              label: 'PROFIL',
            ),
          ],
        ),
      ),
    );
  }
}
