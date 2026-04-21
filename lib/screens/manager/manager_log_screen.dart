import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class ManagerLogScreen extends StatelessWidget {
  const ManagerLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Log Aktivitas\n(Segera Hadir)',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium,
        ),
      ),
    );
  }
}
