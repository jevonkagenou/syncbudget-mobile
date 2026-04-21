import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Sync+Budget&background=696CFF&color=fff'), // Placeholder icon
            ),
            const SizedBox(width: 8),
            Text(
              'SyncBudget',
              style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.bell, color: AppColors.primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Text
            Text(
              'DASHBOARD',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.neutralLight,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hello, Manajer Melissa',
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 24),

            // Sisa Anggaran Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SISA ANGGARAN',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white70,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp 143.000.000',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.trendingUp, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '8.4% bulan ini',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Pengajuan Terbaru Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pengajuan Terbaru',
                  style: AppTextStyles.headlineSmall,
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Lihat Semua',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List of Reimbursements
            _buildReimbursementItem(
              name: 'Ahmad Subarjo',
              category: 'Perjalanan Dinas',
              amount: 'Rp 2.450.000',
              status: 'SELESAI',
              statusColor: AppColors.success,
              statusBgColor: AppColors.successLight,
              iconBgColor: AppColors.primaryLight,
              iconColor: AppColors.primary,
            ),
            _buildReimbursementItem(
              name: 'Siti Aminah',
              category: 'Logistik Kantor',
              amount: 'Rp 890.000',
              status: 'PENDING',
              statusColor: AppColors.warning,
              statusBgColor: AppColors.warningLight,
              iconBgColor: AppColors.info.withValues(alpha: 0.1),
              iconColor: AppColors.info,
            ),
            _buildReimbursementItem(
              name: 'Budi Setiawan',
              category: 'Aset IT',
              amount: 'Rp 15.200.000',
              status: 'DITOLAK',
              statusColor: AppColors.danger,
              statusBgColor: AppColors.dangerLight,
              iconBgColor: AppColors.secondary.withValues(alpha: 0.1),
              iconColor: AppColors.secondary,
            ),
            _buildReimbursementItem(
              name: 'Dewi Lestari',
              category: 'Promosi Digital',
              amount: 'Rp 5.000.000',
              status: 'PENDING',
              statusColor: AppColors.warning,
              statusBgColor: AppColors.warningLight,
              iconBgColor: AppColors.tertiary.withValues(alpha: 0.1),
              iconColor: AppColors.tertiary,
            ),

            const SizedBox(height: 24),

            // Bottom Usage Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PENGELUARAN',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp 24.5M',
                            style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'TERPAKAI',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '42%',
                            style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: AppColors.success),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.42,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReimbursementItem({
    required String name,
    required String category,
    required String amount,
    required String status,
    required Color statusColor,
    required Color statusBgColor,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.fileText, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.labelLarge),
                const SizedBox(height: 4),
                Text(category, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusColor,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
