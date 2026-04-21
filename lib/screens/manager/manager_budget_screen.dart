import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class ManagerBudgetScreen extends StatelessWidget {
  const ManagerBudgetScreen({super.key});

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
                Text(
                  'Anggaran Perusahaan',
                  style: AppTextStyles.headlineMedium,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.pieChart, color: AppColors.primary, size: 20),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Total Budget Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL ANGGARAN',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'TA 2026',
                                style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Rp 5.000.000.000',
                          style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Terpakai',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp 2.100.000.000',
                                    style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sisa',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp 2.900.000.000',
                                      style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Budgets per Division
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Anggaran per Divisi',
                        style: AppTextStyles.headlineSmall,
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Filter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDivisionBudgetCard(
                    division: 'IT & Engineering',
                    allocated: 'Rp 1.500.000.000',
                    used: 'Rp 850.000.000',
                    percentage: 0.56,
                    icon: LucideIcons.monitor,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildDivisionBudgetCard(
                    division: 'Marketing',
                    allocated: 'Rp 1.200.000.000',
                    used: 'Rp 900.000.000',
                    percentage: 0.75,
                    icon: LucideIcons.megaphone,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _buildDivisionBudgetCard(
                    division: 'HR & GA',
                    allocated: 'Rp 800.000.000',
                    used: 'Rp 200.000.000',
                    percentage: 0.25,
                    icon: LucideIcons.users,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  _buildDivisionBudgetCard(
                    division: 'Operations',
                    allocated: 'Rp 1.500.000.000',
                    used: 'Rp 150.000.000',
                    percentage: 0.10,
                    icon: LucideIcons.briefcase,
                    color: Colors.teal,
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

  Widget _buildDivisionBudgetCard({
    required String division,
    required String allocated,
    required String used,
    required double percentage,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      division,
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Disetujui: $allocated',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutralLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terpakai',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight),
              ),
              Text(
                used,
                style: AppTextStyles.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 0.8 ? AppColors.danger : color,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${(percentage * 100).toInt()}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: percentage > 0.8 ? AppColors.danger : color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
