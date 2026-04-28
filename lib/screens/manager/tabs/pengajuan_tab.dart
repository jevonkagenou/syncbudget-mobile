import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../services/reimbursement_service.dart';
import '../../../utils/snackbar_utils.dart';
import 'log_tab.dart';

class PengajuanTab extends StatefulWidget {
  const PengajuanTab({super.key});

  @override
  State<PengajuanTab> createState() => _PengajuanTabState();
}

class _PengajuanTabState extends State<PengajuanTab> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allRequests = [];
  String _selectedFilter = 'Semua';

  final List<String> _filterOptions = ['Semua', 'pending', 'approved', 'rejected'];
  final Map<String, String> _filterLabels = {
    'Semua': 'Semua',
    'pending': 'MENUNGGU',
    'approved': 'DISETUJUI',
    'rejected': 'DITOLAK',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final result = await ReimbursementService.getManagerReimbursements();

    if (!mounted) return;

    if (result['success']) {
      final List rawList = result['data'] ?? [];
      _allRequests = rawList.map<Map<String, dynamic>>((item) {
        final String rawStatus = item['status'] ?? 'pending';
        String displayStatus = 'MENUNGGU';
        Color statusColor = AppColors.warning;

        if (rawStatus == 'approved') {
          displayStatus = 'DISETUJUI';
          statusColor = AppColors.success;
        } else if (rawStatus == 'rejected') {
          displayStatus = 'DITOLAK';
          statusColor = AppColors.danger;
        }

        String dateStr = item['created_at'] != null
            ? DateFormat('dd MMM yyyy').format(DateTime.parse(item['created_at']))
            : '';

        String applicantName = item['user']?['name'] ?? 'Staff';
        String divisionName = item['user']?['division']?['name'] ?? '-';
        String budgetName = item['budget']?['name'] ?? 'Anggaran';

        return {
          'id': item['id']?.toString() ?? '',
          'rawStatus': rawStatus,
          'status': displayStatus,
          'statusColor': statusColor,
          'staff': applicantName,
          'division': divisionName,
          'budget': budgetName,
          'title': item['title'] ?? 'Pengajuan',
          'description': item['description'] ?? '',
          'amount': double.parse(item['amount'].toString()).round(),
          'date': dateStr,
          'rejection_reason': item['rejection_reason'],
        };
      }).toList();
    } else {
      SnackbarUtils.showModernSnackBar(context, result['message'] ?? 'Gagal memuat data', isError: true);
    }

    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 'Semua') return _allRequests;
    return _allRequests.where((r) => r['rawStatus'] == _selectedFilter).toList();
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  // ── Dialog Setujui ──
  void _showApproveDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.checkCircle2, color: AppColors.success, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Setujui Pengajuan?', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Anda akan menyetujui pengajuan "${item['title']}" senilai ${_formatCurrency(item['amount'])} dari ${item['staff']}.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Saldo anggaran "${item['budget']}" akan otomatis terpotong.',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.neutral,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Batal'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _submitStatus(item['id'], 'approved');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Setujui'),
          ),
        ],
      ),
    );
  }

  // ── Dialog Tolak ──
  void _showRejectDialog(Map<String, dynamic> item) {
    final reasonCtrl = TextEditingController();
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.xCircle, color: AppColors.danger, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tolak Pengajuan', style: AppTextStyles.headlineSmall),
                        Text(item['staff'], style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Alasan Penolakan *', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral)),
              const SizedBox(height: 8),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Tuliskan alasan penolakan yang jelas...',
                  hintStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: errorMsg != null ? AppColors.danger : AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: errorMsg != null ? AppColors.danger : AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                onChanged: (_) => setDlgState(() => errorMsg = null),
              ),
              if (errorMsg != null) ...[
                const SizedBox(height: 6),
                Text(errorMsg!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.danger)),
              ],
            ],
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: AppTextStyles.labelMedium.copyWith(color: AppColors.neutralLight)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reasonCtrl.text.trim().isEmpty) {
                  setDlgState(() => errorMsg = 'Alasan penolakan wajib diisi');
                  return;
                }
                Navigator.pop(ctx);
                await _submitStatus(item['id'], 'rejected', rejectionReason: reasonCtrl.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Tolak Pengajuan'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialog Audit ──
  void _showAuditDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.clipboardList, color: AppColors.warning, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Lakukan Audit', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Anda akan diarahkan ke halaman Log Aktivitas untuk menelusuri jejak audit pengajuan ini.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.neutral,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Batal'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LogTab()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Buka Log Aktivitas'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitStatus(String id, String status, {String? rejectionReason}) async {
    final result = await ReimbursementService.updateStatus(
      id: id,
      status: status,
      rejectionReason: rejectionReason,
    );

    if (!mounted) return;

    SnackbarUtils.showModernSnackBar(
      context,
      result['message'] ?? (result['success'] ? 'Status berhasil diperbarui' : 'Gagal memperbarui status'),
      isError: !result['success'],
    );

    if (result['success']) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Persetujuan Dana', style: AppTextStyles.headlineMedium),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.fileSignature, color: AppColors.primary, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Filter Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _filterOptions.length,
              separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final opt = _filterOptions[index];
                final isActive = _selectedFilter == opt;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      _filterLabels[opt] ?? opt,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isActive ? Colors.white : AppColors.neutralLight,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppColors.primary,
                    child: filtered.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.45,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(LucideIcons.inbox, size: 48, color: AppColors.neutralLight),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Tidak ada pengajuan ditemukan',
                                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                            itemCount: filtered.length,
                            separatorBuilder: (ctx, idx) => const SizedBox(height: 16),
                            itemBuilder: (_, i) => _buildCard(filtered[i]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final Color statusColor = item['statusColor'];
    final String rawStatus = item['rawStatus'];
    final bool isPending = rawStatus == 'pending';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['status'],
                    style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontSize: 10),
                  ),
                ),
                Text(item['date'], style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutralLight)),
              ],
            ),
            const SizedBox(height: 16),

            // Staff Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Text(
                    item['staff'].toString().substring(0, 1).toUpperCase(),
                    style: AppTextStyles.labelLarge.copyWith(color: statusColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['staff'], style: AppTextStyles.labelLarge),
                      Text(item['division'], style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutralLight)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Title + Description
            Text(item['title'], style: AppTextStyles.labelLarge),
            if (item['description'] != null && item['description'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  item['description'],
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutralLight),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 8),

            // Budget
            Row(
              children: [
                const Icon(LucideIcons.wallet, size: 14, color: AppColors.neutralLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item['budget'],
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Amount
            Text(
              _formatCurrency(item['amount']),
              style: AppTextStyles.headlineSmall.copyWith(color: statusColor),
            ),

            // Rejection reason info
            if (rawStatus == 'rejected' && item['rejection_reason'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.alertCircle, size: 14, color: AppColors.danger),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item['rejection_reason'],
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action Buttons — only for pending
            if (isPending) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(item),
                      icon: const Icon(LucideIcons.xCircle, size: 16),
                      label: const Text('Tolak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApproveDialog(item),
                      icon: const Icon(LucideIcons.checkCircle2, size: 16),
                      label: const Text('Setujui'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAuditDialog(item),
                  icon: const Icon(LucideIcons.clipboardList, size: 16),
                  label: const Text('Lakukan Audit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: BorderSide(color: AppColors.warning.withValues(alpha: 0.4)),
                    backgroundColor: AppColors.warning.withValues(alpha: 0.06),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
