import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback? onNavigateToPengajuan;
  const HomeTab({super.key, this.onNavigateToPengajuan});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Dummy Data - Siap diganti dengan API (Dinamic)
  final String userName = "Klein";
  final String userRole = "STAF OPERASIONAL";
  
  final int totalPengajuanMenunggu = 2;
  final int totalDanaDisetujui = 1500000;
  
  final String namaDivisi = "Divisi Operasional";
  final String tahunAnggaran = "2024";
  final int sisaAnggaran = 76000000;
  final int totalAnggaran = 250000000;
  
  // Getter untuk kalkulasi value progress bar
  double get progressAnggaran {
    int digunakan = totalAnggaran - sisaAnggaran;
    return digunakan / totalAnggaran;
  }

  // List data riwayat pengajuan (siap di mapping dari API)
  final List<Map<String, dynamic>> riwayatPengajuan = [
    {
      "title": "Biaya Transportasi Luar Kota",
      "date": "12 Okt 2023",
      "amount": 450000,
      "status": "PENDING",
      "statusColor": AppColors.warning,
      "icon": LucideIcons.bus,
    },
    {
      "title": "Pembelian ATK Kantor",
      "date": "08 Okt 2023",
      "amount": 1050000,
      "status": "DISETUJUI",
      "statusColor": AppColors.success,
      "icon": LucideIcons.briefcase,
    },
    {
      "title": "Reimbursement Internet",
      "date": "05 Okt 2023",
      "amount": 150000,
      "status": "PENDING",
      "statusColor": AppColors.warning,
      "icon": LucideIcons.wifi,
    },
  ];

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(LucideIcons.user, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $userName',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          userRole,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.neutralLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.bell, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    icon: LucideIcons.clock,
                    iconColor: AppColors.secondary,
                    title: 'Pengajuanku(Menunggu)',
                    value: '$totalPengajuanMenunggu',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOverviewCard(
                    icon: LucideIcons.wallet,
                    iconColor: AppColors.success,
                    title: 'Total Dana(Disetujui)',
                    value: _formatCurrency(totalDanaDisetujui),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Budget Availability
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ketersediaan Anggaran Divisi',
                            style: AppTextStyles.labelLarge,
                          ),
                          Text(
                            '$namaDivisi • TA $tahunAnggaran',
                            style: AppTextStyles.labelSmall,
                          ),
                        ],
                      ),
                      Icon(LucideIcons.barChart2, color: AppColors.warning),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressAnggaran,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SISA: ${_formatCurrency(sisaAnggaran).toUpperCase()}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                      Text(
                        'Total: ${_formatCurrency(totalAnggaran)}',
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Recent Submissions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Pengajuanku',
                  style: AppTextStyles.headlineSmall,
                ),
                TextButton(
                  onPressed: () {
                    if (widget.onNavigateToPengajuan != null) {
                      widget.onNavigateToPengajuan!();
                    }
                  },
                  child: Text(
                    'LIHAT SEMUA',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Loop data riwayat dengan map
            ...riwayatPengajuan.map((item) {
              return _buildHistoryItem(
                title: item['title'],
                date: item['date'],
                amount: _formatCurrency(item['amount']),
                status: item['status'],
                statusColor: item['statusColor'],
                icon: item['icon'],
              );
            }).toList(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(height: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: statusColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.neutral, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: AppTextStyles.labelLarge,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusColor,
                    fontSize: 8,
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
