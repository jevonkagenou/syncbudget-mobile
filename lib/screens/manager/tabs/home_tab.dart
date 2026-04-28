import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../services/dashboard_service.dart';
import '../../../utils/snackbar_utils.dart';
import 'budget_tab.dart';
import 'log_tab.dart';

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
      
      // Parse Recent History
      List<Map<String, dynamic>> mappedHistory = [];

      if (data['recent_history'] != null) {
        for (var item in data['recent_history']) {
          String statusStr = item['status'] ?? 'pending';
          
          String formattedStatus = 'PENDING';
          Color statusColor = AppColors.warning;
          Color statusBgColor = AppColors.warningLight;

          if (statusStr == 'approved') {
            formattedStatus = 'DISETUJUI';
            statusColor = AppColors.success;
            statusBgColor = AppColors.successLight;
          } else if (statusStr == 'rejected') {
            formattedStatus = 'DITOLAK';
            statusColor = AppColors.danger;
            statusBgColor = AppColors.dangerLight;
          }

          String applicantName = 'Unknown User';
          if (item['user'] != null && item['user']['name'] != null) {
            applicantName = item['user']['name'];
          }

          String dateStr = item['created_at'] != null 
              ? DateFormat('dd MMM yyyy').format(DateTime.parse(item['created_at']))
              : '';

          mappedHistory.add({
            "name": applicantName,
            "category": item['title'] ?? 'Pengajuan',
            "date": dateStr,
            "amount": double.parse(item['amount'].toString()).round(),
            "status": formattedStatus,
            "statusColor": statusColor,
            "statusBgColor": statusBgColor,
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

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
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
                            child: const Icon(LucideIcons.user, color: AppColors.primary),
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
                          icon: LucideIcons.checkSquare,
                          iconColor: AppColors.warning,
                          title: 'Persetujuan(Menunggu)',
                          value: '$pendingCount',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOverviewCard(
                          icon: LucideIcons.trendingUp,
                          iconColor: AppColors.success,
                          title: 'Realisasi(Bulan Ini)',
                          value: _formatCurrency(totalPengeluaran),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sisa Anggaran Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF8B8EFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(LucideIcons.wallet, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Sisa Anggaran Divisi',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _formatCurrency(sisaAnggaran),
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Menu Layanan Section
                  Text(
                    'Layanan',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Menu Grid (2x2)
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      _buildMenuItem(
                        icon: LucideIcons.wallet,
                        label: 'Pagu\nAnggaran',
                        color: AppColors.primary,
                        onTap: () => _navigateTo(const BudgetTab()),
                      ),
                      _buildMenuItem(
                        icon: LucideIcons.clipboardList,
                        label: 'Log\nAktivitas',
                        color: AppColors.info,
                        onTap: () => _navigateTo(const LogTab()),
                      ),
                      _buildMenuItem(
                        icon: LucideIcons.fileBarChart,
                        label: 'Laporan\nTahunan',
                        color: AppColors.success,
                        onTap: () {
                          // TODO: Navigasi ke halaman laporan tahunan
                          SnackbarUtils.showModernSnackBar(context, 'Fitur segera hadir');
                        },
                      ),
                      _buildMenuItem(
                        icon: LucideIcons.filePlus,
                        label: 'Export\nPDF',
                        color: AppColors.warning,
                        onTap: () {
                          // TODO: Navigasi ke halaman export PDF
                          SnackbarUtils.showModernSnackBar(context, 'Fitur segera hadir');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Pengajuan Terbaru Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pengajuan Terbaru',
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
                        date: item['date'],
                        amount: _formatCurrency(item['amount']),
                        status: item['status'],
                        statusColor: item['statusColor'],
                        statusBgColor: item['statusBgColor'],
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

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReimbursementItem({
    required String name,
    required String category,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
    required Color statusBgColor,
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.fileText, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text(
                  category,
                  style: AppTextStyles.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (date.isNotEmpty)
                  Text(
                    date,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.neutralLight,
                      fontSize: 10,
                    ),
                  ),
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
