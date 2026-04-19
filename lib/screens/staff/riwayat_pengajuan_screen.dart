import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RiwayatPengajuanScreen extends StatefulWidget {
  final List<Map<String, dynamic>> riwayatData;

  const RiwayatPengajuanScreen({super.key, required this.riwayatData});

  @override
  State<RiwayatPengajuanScreen> createState() => _RiwayatPengajuanScreenState();
}

class _RiwayatPengajuanScreenState extends State<RiwayatPengajuanScreen> {
  String _searchQuery = "";
  String _selectedStatus = "Semua Status";
  final List<String> _statusOptions = [
    "Semua Status",
    "PENDING",
    "DISETUJUI",
    "DITOLAK"
  ];

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  IconData _getIconForStatus(String status) {
    if (status == 'DISETUJUI') return LucideIcons.checkCircle;
    if (status == 'DITOLAK') return LucideIcons.xCircle;
    return LucideIcons.clock; // MENUNGGU
  }

  Color _getColorForStatus(String status) {
    if (status == 'DISETUJUI') return AppColors.success;
    if (status == 'DITOLAK') return AppColors.danger;
    return AppColors.warning; // MENUNGGU
  }

  IconData _getActionIconForStatus(String status) {
    if (status == 'DISETUJUI') return LucideIcons.lock;
    if (status == 'DITOLAK') return LucideIcons.info;
    return LucideIcons.trash2; // MENUNGGU
  }

  Color _getActionColorForStatus(String status) {
    if (status == 'MENUNGGU') return AppColors.danger;
    return AppColors.neutralLight;
  }

  void _showPenolakanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(LucideIcons.alertCircle, color: AppColors.danger),
              const SizedBox(width: 8),
              Text(
                'Alasan Penolakan',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.danger),
              ),
            ],
          ),
          content: Text(
            'Gunakan kendaraan operasional kantor yang sudah tersedia, tidak perlu sewa.',
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
        );
      },
    );
  }

  void _showBatalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.border, // Abu-abu terang (OK / Tutup)
                foregroundColor: AppColors.neutral,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Tutup'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger, // Merah (Batal / Hapus)
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Hapus Pengajuan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = widget.riwayatData.where((item) {
      final matchesSearch = item['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == "Semua Status" || item['status'] == _selectedStatus.toUpperCase();
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Seluruh Riwayat', style: AppTextStyles.headlineSmall),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  // Dropdown Filter
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
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedStatus = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Search Bar
                  Expanded(
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Cari pengajuan...',
                        hintStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.neutralLight),
                        prefixIcon: const Icon(LucideIcons.search, size: 16),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final item = filteredData[index];
                  return _buildHistoryItem(
                    title: item['title'],
                    date: item['date'],
                    amount: _formatCurrency(item['amount']),
                    status: item['status'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String date,
    required String amount,
    required String status,
  }) {
    final statusColor = _getColorForStatus(status);
    final icon = _getIconForStatus(status);
    final actionIcon = _getActionIconForStatus(status);
    final actionColor = _getActionColorForStatus(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.neutralLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTextStyles.labelLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
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
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      amount,
                      style: AppTextStyles.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (status == 'DITOLAK') {
                _showPenolakanDialog(context);
              } else if (status == 'MENUNGGU') {
                _showBatalDialog(context);
              }
            },
            icon: Icon(actionIcon, color: actionColor, size: 20),
          ),
        ],
      ),
    );
  }
}
