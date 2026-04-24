import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../services/dashboard_service.dart';
import '../../../utils/snackbar_utils.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _isLoading = true;
  
  String userName = "";
  String userRole = "";
  
  int sisaAnggaran = 0;
  int totalPengeluaran = 0; 
  int pendingCount = 0;
  
  List<Map<String, dynamic>> riwayatPengajuan = [];

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
      userName = data['profile']['name'] ?? 'Manajer';
      userRole = (data['profile']['role'] ?? '').toString().toUpperCase();
      
      // Parse Stats
      sisaAnggaran = double.parse(data['stats']['total_budget_remaining'].toString()).round();
      totalPengeluaran = double.parse(data['stats']['approved_this_month'].toString()).round();
      pendingCount = data['stats']['pending_count'] ?? 0;

      // We don't have total budget in manager stats from the JSON, 
      // so we just show the remaining and the approved this month.
      
      // Parse Recent History
      List<Map<String, dynamic>> mappedHistory = [];

      if (data['recent_history'] != null) {
        for (var item in data['recent_history']) {
          String statusStr = item['status'] ?? 'pending';
          
          String formattedStatus = 'PENDING';
          Color statusColor = AppColors.warning;
          Color statusBgColor = AppColors.warningLight;
          Color iconColor = AppColors.info;
          Color iconBgColor = AppColors.info.withValues(alpha: 0.1);

          if (statusStr == 'approved') {
            formattedStatus = 'DISETUJUI';
            statusColor = AppColors.success;
            statusBgColor = AppColors.successLight;
            iconColor = AppColors.primary;
            iconBgColor = AppColors.primaryLight;
          } else if (statusStr == 'rejected') {
            formattedStatus = 'DITOLAK';
            statusColor = AppColors.danger;
            statusBgColor = AppColors.dangerLight;
            iconColor = AppColors.secondary;
            iconBgColor = AppColors.secondary.withValues(alpha: 0.1);
          }

          String applicantName = 'Unknown User';
          if (item['user'] != null && item['user']['name'] != null) {
            applicantName = item['user']['name'];
          }

          mappedHistory.add({
            "name": applicantName,
            "category": item['title'] ?? 'Pengajuan',
            "amount": double.parse(item['amount'].toString()).round(),
            "status": formattedStatus,
            "statusColor": statusColor,
            "statusBgColor": statusBgColor,
            "iconBgColor": iconBgColor,
            "iconColor": iconColor,
          });
        }
      }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
              'Hello, $userName',
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 24),

            // Overview Cards (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildStatCard(
                    title: 'Tugas Persetujuan (Tim)',
                    value: '$pendingCount Menunggu',
                    icon: LucideIcons.checkSquare,
                    iconColor: AppColors.warning,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    title: 'Realisasi Divisi (Bulan Ini)',
                    value: _formatCurrency(totalPengeluaran),
                    icon: LucideIcons.trendingUp,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    title: 'Sisa Anggaran Divisi',
                    value: _formatCurrency(sisaAnggaran),
                    icon: LucideIcons.wallet,
                    iconColor: AppColors.success,
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
            if (riwayatPengajuan.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                alignment: Alignment.center,
                child: Text(
                  'Belum ada pengajuan terbaru.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight),
                ),
              )
            else
              ...riwayatPengajuan.map((item) {
                return _buildReimbursementItem(
                  name: item['name'],
                  category: item['category'],
                  amount: _formatCurrency(item['amount']),
                  status: item['status'],
                  statusColor: item['statusColor'],
                  statusBgColor: item['statusBgColor'],
                  iconBgColor: item['iconBgColor'],
                  iconColor: item['iconColor'],
                );
              }),

            const SizedBox(height: 24),
            const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 22),
          ),
        ],
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
