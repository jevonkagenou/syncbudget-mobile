import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/reimbursement_service.dart';
import '../../../services/dashboard_service.dart';
import '../../../utils/snackbar_utils.dart';
import '../riwayat_pengajuan_screen.dart';
class PengajuanTab extends StatefulWidget {
  const PengajuanTab({super.key});

  @override
  State<PengajuanTab> createState() => _PengajuanTabState();
}

class _PengajuanTabState extends State<PengajuanTab> {
  bool _isLoading = true;
  String userName = '';

  // Data dari API
  List<Map<String, dynamic>> _riwayat = [];
  List<Map<String, dynamic>> _availableBudgets = [];
  int _totalDiajukan = 0;
  int _totalPending = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Fetch riwayat pengajuan
    final reimbResult = await ReimbursementService.getMyReimbursements();
    // Fetch budget list dari dashboard
    final dashResult = await DashboardService.getDashboardData();

    if (!mounted) return;

    if (reimbResult['success']) {
      final List rawList = reimbResult['data'] ?? [];
      int totalAmount = 0;
      int pendingCount = 0;

      List<Map<String, dynamic>> mapped = [];
      for (var item in rawList) {
        String statusStr = item['status'] ?? 'pending';

        if (statusStr == 'pending') pendingCount++;
        totalAmount += double.parse(item['amount'].toString()).round();

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

        mapped.add({
          'id': item['id']?.toString() ?? '',
          'title': item['title'] ?? 'Pengajuan',
          'description': item['description'] ?? '',
          'date': dateStr,
          'amount': double.parse(item['amount'].toString()).round(),
          'rawStatus': statusStr,
          'status': formattedStatus,
          'statusColor': statusColor,
          'rejection_reason': item['rejection_reason'],
        });
      }

      _riwayat = mapped;
      _totalDiajukan = totalAmount;
      _totalPending = pendingCount;
    } else {
      SnackbarUtils.showModernSnackBar(context, reimbResult['message'] ?? 'Gagal memuat data', isError: true);
    }

    // Ambil available budgets dari dashboard
    if (dashResult['success']) {
      final data = dashResult['data'];
      userName = data['profile']['name'] ?? 'User';

      if (data['available_budgets'] != null) {
        _availableBudgets = List<Map<String, dynamic>>.from(
          (data['available_budgets'] as List).map((b) => {
            'id': b['id']?.toString() ?? '',
            'name': b['name'] ?? '',
            'category': b['category'] ?? '',
            'remaining': double.parse(b['remaining'].toString()).round(),
          }),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  // ──── Dialogs ────

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
        content: Text(
          reason ?? 'Tidak ada alasan yang diberikan.',
          style: AppTextStyles.bodyMedium,
        ),
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

  // ──── Form Pengajuan ────

  void _showBuatPengajuanModal(BuildContext context) {
    String? selectedBudgetId;
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    XFile? selectedReceipt;
    bool isSubmitting = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)],
              ),
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Form Pengajuan Dana', style: AppTextStyles.headlineSmall),
                        Container(
                          decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(LucideIcons.x, size: 20, color: AppColors.neutral),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                      ],
                    ),
                    
                    if (errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.alertCircle, color: AppColors.danger, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(errorMessage!, style: AppTextStyles.labelMedium.copyWith(color: AppColors.danger))),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),

                    // Dropdown Anggaran
                    Text('Ambil Dari Anggaran', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 20),
                      decoration: _dropdownDecoration('Pilih anggaran'),
                      items: _availableBudgets.map((b) {
                        return DropdownMenuItem<String>(
                          value: b['id'],
                          child: Text(
                            '${b['name']} (${_formatCurrency(b['remaining'])})',
                            style: AppTextStyles.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => selectedBudgetId = val,
                    ),
                    const SizedBox(height: 20),

                    // Judul
                    _buildModernTextField(
                      label: 'Judul Pengajuan',
                      hint: 'Mis: Pembelian Tinta Printer',
                      icon: LucideIcons.fileEdit,
                      controller: titleCtrl,
                    ),
                    const SizedBox(height: 20),

                    // Nominal
                    _buildModernTextField(
                      label: 'Nominal (Rp)',
                      hint: '0',
                      icon: LucideIcons.banknote,
                      keyboardType: TextInputType.number,
                      controller: amountCtrl,
                    ),
                    const SizedBox(height: 20),

                    // Bukti Struk/Nota
                    Text('Bukti Struk / Nota', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setModalState(() => selectedReceipt = pickedFile);
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: selectedReceipt == null ? AppColors.primaryLight.withValues(alpha: 0.3) : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: selectedReceipt == null ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: selectedReceipt == null ? AppColors.surface : AppColors.successLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                selectedReceipt == null ? LucideIcons.uploadCloud : LucideIcons.checkCircle,
                                color: selectedReceipt == null ? AppColors.primary : AppColors.success,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              selectedReceipt == null ? 'Klik untuk unggah dokumen' : 'Dokumen terpilih',
                              style: AppTextStyles.labelMedium.copyWith(color: selectedReceipt == null ? AppColors.primary : AppColors.success),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedReceipt == null ? 'JPG atau PNG (Maks 2MB)' : selectedReceipt!.name,
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Keterangan
                    _buildModernTextField(
                      label: 'Keterangan',
                      hint: 'Berikan deskripsi detail terkait pengajuan ini...',
                      isTextArea: true,
                      controller: descCtrl,
                    ),
                    const SizedBox(height: 32),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.neutral,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: AppColors.border),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    // Validasi
                                    setModalState(() => errorMessage = null);

                                    if (selectedBudgetId == null) {
                                      setModalState(() => errorMessage = 'Pilih anggaran terlebih dahulu');
                                      return;
                                    }
                                    if (titleCtrl.text.trim().isEmpty) {
                                      setModalState(() => errorMessage = 'Judul tidak boleh kosong');
                                      return;
                                    }
                                    final amount = double.tryParse(amountCtrl.text.replaceAll('.', '').replaceAll(',', ''));
                                    if (amount == null || amount < 1000) {
                                      setModalState(() => errorMessage = 'Nominal minimal Rp 1.000');
                                      return;
                                    }
                                    if (descCtrl.text.trim().isEmpty) {
                                      setModalState(() => errorMessage = 'Keterangan tidak boleh kosong');
                                      return;
                                    }

                                    setModalState(() => isSubmitting = true);
                                    final messenger = ScaffoldMessenger.of(context);
                                    final nav = Navigator.of(ctx);

                                    final result = await ReimbursementService.store(
                                      budgetId: selectedBudgetId!,
                                      title: titleCtrl.text.trim(),
                                      description: descCtrl.text.trim(),
                                      amount: amount,
                                      receiptFilePath: selectedReceipt?.path,
                                    );

                                    setModalState(() => isSubmitting = false);

                                    if (!mounted) return;

                                    if (result['success']) {
                                      nav.pop();
                                      SnackbarUtils.showModernSnackBarOnMessenger(messenger, result['message'] ?? 'Pengajuan berhasil dikirim');
                                      _loadData();
                                    } else {
                                      setModalState(() => errorMessage = result['message'] ?? 'Gagal mengirim pengajuan');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: isSubmitting
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Kirim Pengajuan', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.neutralLight),
      prefixIcon: const Icon(LucideIcons.wallet, size: 20, color: AppColors.neutralLight),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required String hint,
    IconData? icon,
    bool isTextArea = false,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral)),
            const Text(' *', style: TextStyle(color: AppColors.danger)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: isTextArea ? 3 : 1,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.neutralLight),
            prefixIcon: icon != null ? Icon(icon, color: AppColors.neutralLight, size: 20) : null,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  // ──── Build ────

  @override
  Widget build(BuildContext context) {
    // Tampilkan max 5 riwayat di tab ini
    final displayedRiwayat = _riwayat.length > 5 ? _riwayat.sublist(0, 5) : _riwayat;

    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primaryLight,
                              child: const Icon(LucideIcons.user, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Hello, $userName',
                              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.bell, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      children: [
                        Text('Daftar Pengajuan Dana', style: AppTextStyles.headlineLarge),
                        const SizedBox(height: 24),

                        // Buat Pengajuan Button
                        ElevatedButton.icon(
                          onPressed: () => _showBuatPengajuanModal(context),
                          icon: const Icon(LucideIcons.plusCircle, size: 20),
                          label: const Text('Buat Pengajuan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Summary Pills
                        Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('TOTAL DIAJUKAN', style: AppTextStyles.labelSmall.copyWith(letterSpacing: 0.5)),
                                    const SizedBox(height: 12),
                                    Text(
                                      _formatCurrency(_totalDiajukan),
                                      style: AppTextStyles.headlineMedium.copyWith(fontSize: 22, color: AppColors.neutral),
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEEFF4),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('STATUS AKTIF', style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary, letterSpacing: 0.5)),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8, height: 8,
                                          decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '$_totalPending Pending',
                                            style: AppTextStyles.headlineMedium.copyWith(fontSize: 16, color: AppColors.neutral),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Riwayat Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Riwayat Pengajuan', style: AppTextStyles.labelLarge),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RiwayatPengajuanScreen()),
                                );
                              },
                              child: Text('Lihat semua', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (displayedRiwayat.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            alignment: Alignment.center,
                            child: Text('Belum ada pengajuan.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight)),
                          )
                        else
                          ...displayedRiwayat.map((item) => _buildHistoryItem(item)),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
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
                Text(item['title'], style: AppTextStyles.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
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
          // Action button based on status
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
