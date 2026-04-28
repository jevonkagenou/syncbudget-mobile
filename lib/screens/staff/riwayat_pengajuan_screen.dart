import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/reimbursement_service.dart';
import '../../utils/snackbar_utils.dart';

class RiwayatPengajuanScreen extends StatefulWidget {
  const RiwayatPengajuanScreen({super.key});

  @override
  State<RiwayatPengajuanScreen> createState() => _RiwayatPengajuanScreenState();
}

class _RiwayatPengajuanScreenState extends State<RiwayatPengajuanScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allData = [];
  String _searchQuery = '';
  String _selectedStatus = 'Semua Status';
  final List<String> _statusOptions = ['Semua Status', 'PENDING', 'DISETUJUI', 'DITOLAK'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final result = await ReimbursementService.getMyReimbursements();
    if (!mounted) return;

    if (result['success']) {
      final List rawList = result['data'] ?? [];
      _allData = rawList.map<Map<String, dynamic>>((item) {
        String statusStr = item['status'] ?? 'pending';
        String formattedStatus = 'PENDING';
        Color statusColor = AppColors.warning;
        if (statusStr == 'approved') {
          formattedStatus = 'DISETUJUI';
          statusColor = AppColors.success;
        } else if (statusStr == 'rejected') {
          formattedStatus = 'DITOLAK';
          statusColor = AppColors.danger;
        }

        String dateStr = item['created_at'] != null
            ? DateFormat('dd MMM yyyy').format(DateTime.parse(item['created_at']))
            : '';

        return {
          'id': item['id']?.toString() ?? '',
          'title': item['title'] ?? 'Pengajuan',
          'date': dateStr,
          'amount': double.parse(item['amount'].toString()).round(),
          'rawStatus': statusStr,
          'status': formattedStatus,
          'statusColor': statusColor,
          'rejection_reason': item['rejection_reason'],
        };
      }).toList();
    } else {
      SnackbarUtils.showModernSnackBar(context, result['message'] ?? 'Gagal memuat data', isError: true);
    }

    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredData {
    return _allData.where((item) {
      final matchesSearch = item['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == 'Semua Status' || item['status'] == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  void _showPenolakanDialog(BuildContext context, String? reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(LucideIcons.alertCircle, color: AppColors.danger),
            const SizedBox(width: 8),
            Text('Alasan Penolakan', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.danger)),
          ],
        ),
        content: Text(reason ?? 'Tidak ada alasan yang diberikan.', style: AppTextStyles.bodyMedium),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.neutral,
              elevation: 0,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showBatalDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        title: Text(
          'Apakah Anda yakin ingin membatalkan pengajuan ini?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.border,
              foregroundColor: AppColors.neutral,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Batal'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final result = await ReimbursementService.destroy(id);
              if (!mounted) return;
              SnackbarUtils.showModernSnackBarOnMessenger(
                messenger,
                result['message'] ?? (result['success'] ? 'Berhasil dihapus' : 'Gagal menghapus'),
                isError: !result['success'],
              );
              if (result['success']) _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus Pengajuan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _filteredData;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Seluruh Riwayat', style: AppTextStyles.headlineSmall),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Filter bar
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            icon: const Icon(LucideIcons.chevronDown, size: 16),
                            style: AppTextStyles.labelMedium,
                            items: _statusOptions.map((String val) {
                              return DropdownMenuItem<String>(value: val, child: Text(val));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStatus = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Cari pengajuan...',
                            hintStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.neutralLight),
                            prefixIcon: const Icon(LucideIcons.search, size: 16),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppColors.primary,
                    child: filteredData.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.4,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(LucideIcons.inbox, color: AppColors.neutralLight, size: 48),
                                      const SizedBox(height: 16),
                                      Text('Tidak ada data ditemukan', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) => _buildHistoryItem(filteredData[index]),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final Color statusColor = item['statusColor'];
    final String rawStatus = item['rawStatus'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
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
                if (item['date'] != null && item['date'].isNotEmpty)
                  Text(item['date'], style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight)),
                const SizedBox(height: 2),
                Text(item['title'], style: AppTextStyles.labelLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(item['status'], style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontSize: 9)),
                    ),
                    const SizedBox(width: 8),
                    Text(_formatCurrency(item['amount']), style: AppTextStyles.labelMedium),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          if (rawStatus == 'pending')
            IconButton(
              onPressed: () => _showBatalDialog(context, item['id']),
              icon: const Icon(LucideIcons.trash2, color: AppColors.danger, size: 20),
              tooltip: 'Batalkan',
            )
          else if (rawStatus == 'rejected')
            IconButton(
              onPressed: () => _showPenolakanDialog(context, item['rejection_reason']),
              icon: const Icon(LucideIcons.info, color: AppColors.neutralLight, size: 20),
              tooltip: 'Lihat alasan',
            )
          else
            IconButton(
              onPressed: () {},
              icon: const Icon(LucideIcons.lock, color: AppColors.neutralLight, size: 20),
              tooltip: 'Sudah diproses',
            ),
        ],
      ),
    );
  }
}
