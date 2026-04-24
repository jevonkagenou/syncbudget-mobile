import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../services/dashboard_service.dart';
import '../../../utils/snackbar_utils.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback? onNavigateToPengajuan;
  const HomeTab({super.key, this.onNavigateToPengajuan});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _isLoading = true;
  
  String userName = "";
  String userRole = "";
  String namaDivisi = "";
  String tahunAnggaran = "";
  
  int totalPengajuanMenunggu = 0;
  int totalDanaDisetujui = 0;
  
  int sisaAnggaran = 0;
  int totalAnggaran = 0;
  
  List<Map<String, dynamic>> riwayatPengajuan = [];

  // Getter untuk kalkulasi value progress bar
  double get progressAnggaran {
    if (totalAnggaran == 0) return 0;
    int digunakan = totalAnggaran - sisaAnggaran;
    return digunakan / totalAnggaran;
  }

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    final result = await DashboardService.getDashboardData();

    if (!mounted) return;

    if (result['success']) {
      final data = result['data'];
      
      // Parse Profile
      userName = data['profile']['name'] ?? 'User';
      userRole = (data['profile']['role'] ?? '').toString().toUpperCase();
      namaDivisi = data['profile']['division'] ?? '';
      
      // Parse Budget Info
      tahunAnggaran = data['fiscal_year'] ?? '';
      totalAnggaran = double.parse(data['budget']['total_amount'].toString()).round();
      sisaAnggaran = double.parse(data['budget']['remaining_amount'].toString()).round();

      // Parse Recent History
      int pendingCount = 0;
      int approvedSum = 0;
      List<Map<String, dynamic>> mappedHistory = [];

      if (data['recent_history'] != null) {
        for (var item in data['recent_history']) {
          String statusStr = item['status'] ?? 'pending';
          
          if (statusStr == 'pending') {
            pendingCount++;
          } else if (statusStr == 'approved') {
            approvedSum += double.parse(item['amount'].toString()).round();
          }

          // Map for UI
          String formattedStatus = 'PENDING';
          Color statusColor = AppColors.warning;
          IconData icon = LucideIcons.fileText;

          if (statusStr == 'approved') {
            formattedStatus = 'DISETUJUI';
            statusColor = AppColors.success;
            icon = LucideIcons.checkCircle;
          } else if (statusStr == 'rejected') {
            formattedStatus = 'DITOLAK';
            statusColor = AppColors.danger;
            icon = LucideIcons.xCircle;
          }

          // Format date assuming YYYY-MM-DD format roughly
          String dateStr = item['created_at'] != null 
              ? DateFormat('dd MMM yyyy').format(DateTime.parse(item['created_at']))
              : '';

          mappedHistory.add({
            "title": item['title'] ?? 'Pengajuan',
            "date": dateStr,
            "amount": double.parse(item['amount'].toString()).round(),
            "status": formattedStatus,
            "statusColor": statusColor,
            "icon": icon,
          });
        }
      }

      totalPengajuanMenunggu = pendingCount;
      totalDanaDisetujui = approvedSum;
      riwayatPengajuan = mappedHistory;

    } else {
      SnackbarUtils.showModernSnackBar(context, result['message'], isError: true);
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : RefreshIndicator(
            onRefresh: _loadDashboardData,
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
            if (riwayatPengajuan.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                alignment: Alignment.center,
                child: Text(
                  'Belum ada riwayat pengajuan.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight),
                ),
              )
            else
              ...riwayatPengajuan.map((item) {
                return _buildHistoryItem(
                  title: item['title'],
                  date: item['date'],
                  amount: _formatCurrency(item['amount']),
                  status: item['status'],
                  statusColor: item['statusColor'],
                  icon: item['icon'],
                );
              }),
            
            const SizedBox(height: 24),
                ],
              ),
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
