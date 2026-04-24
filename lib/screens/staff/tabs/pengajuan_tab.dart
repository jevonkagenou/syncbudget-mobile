import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../riwayat_pengajuan_screen.dart';

class PengajuanTab extends StatefulWidget {
  const PengajuanTab({super.key});

  @override
  State<PengajuanTab> createState() => _PengajuanTabState();
}

class _PengajuanTabState extends State<PengajuanTab> {
  // Data User
  final String userName = "Klein";
  
  // Data Overview Pengajuan
  final int totalDiajukan = 12450000;
  final int totalPending = 4;
  
  // Daftar Menu Dropdown Dummy API
  final List<String> listDompetAnggaran = [
    "Anggaran Operasional Cabang",
    "Anggaran Pemasaran",
    "Anggaran IT & Infrastruktur"
  ];
  String? selectedAnggaran;

  // Data Riwayat Pengajuan - Siap ganti API
  final List<Map<String, dynamic>> riwayatPengajuan = [
    {
      "title": "Biaya Parkir Kunjungan Klien",
      "date": "14 Okt 2023",
      "amount": 50000,
      "status": "MENUNGGU",
    },
    {
      "title": "Pembelian Tinta Printer L3110",
      "date": "12 Okt 2023",
      "amount": 450000,
      "status": "DISETUJUI",
    },
    {
      "title": "Tiket Pesawat Jakarta - Bali",
      "date": "10 Okt 2023",
      "amount": 2800000,
      "status": "MENUNGGU",
    },
    {
      "title": "Makan Siang Tim Internal",
      "date": "08 Okt 2023",
      "amount": 1200000,
      "status": "DITOLAK",
    },
  ];

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

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
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
                backgroundColor: AppColors.border, // Abu-abu
                foregroundColor: AppColors.neutral,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Batal'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger, // Merah
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

  void _showBuatPengajuanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
            ],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Form Pengajuan Dana',
                      style: AppTextStyles.headlineSmall,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(LucideIcons.x, size: 20, color: AppColors.neutral),
                        onPressed: () => Navigator.pop(context),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                
                // Ambil Dari Anggaran
                Text('Ambil Dari Anggaran', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  icon: const Icon(LucideIcons.chevronDown, size: 20),
                  decoration: InputDecoration(
                    hintText: 'Pilih dompet anggaran',
                    hintStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.neutralLight),
                    prefixIcon: const Icon(LucideIcons.wallet, size: 20, color: AppColors.neutralLight),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  items: listDompetAnggaran.map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val, style: AppTextStyles.bodyMedium),
                    );
                  }).toList(),
                  onChanged: (val) {
                    selectedAnggaran = val;
                  },
                ),
                const SizedBox(height: 20),

                // Judul Pengajuan
                _buildModernTextField(
                  label: 'Judul Pengajuan',
                  hint: 'Mis: Pembelian Tinta Printer',
                  icon: LucideIcons.fileEdit,
                ),
                const SizedBox(height: 20),

                // Nominal
                _buildModernTextField(
                  label: 'Nominal (Rp)',
                  hint: '0',
                  icon: LucideIcons.banknote,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

                // Bukti Struk/Nota
                Text('Bukti Struk / Nota', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.uploadCloud, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(height: 12),
                      Text('Klik untuk unggah dokumen', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text('PDF, JPG, atau PNG (Maks 5MB)', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Keterangan Tambahan
                _buildModernTextField(
                  label: 'Keterangan Tambahan',
                  hint: 'Berikan deskripsi detail terkait pengajuan ini...',
                  isTextArea: true,
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Kirim Pengajuan',
                          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                        ),
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
  }

  Widget _buildModernTextField({
    required String label,
    required String hint,
    IconData? icon,
    bool isTextArea = false,
    TextInputType keyboardType = TextInputType.text,
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
          maxLines: isTextArea ? 3 : 1,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.neutralLight),
            prefixIcon: icon != null 
                ? Icon(icon, color: AppColors.neutralLight, size: 20)
                : null,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(LucideIcons.user, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Hello, $userName',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
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
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                Text(
                  'Daftar Pengajuan Dana',
                  style: AppTextStyles.headlineLarge,
                ),
                const SizedBox(height: 24),
                
                ElevatedButton.icon(
                  onPressed: () => _showBuatPengajuanModal(context),
                  icon: const Icon(LucideIcons.plusCircle, size: 20),
                  label: const Text('Buat Pengajuan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
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
                            Text(
                              'TOTAL DIAJUKAN',
                              style: AppTextStyles.labelSmall.copyWith(letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _formatCurrency(totalDiajukan).replaceFirst('Rp ', 'Rp '),
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
                          color: const Color(0xFFEEEFF4), // Light blue-grey
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STATUS AKTIF',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.secondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.warning,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '$totalPending Pending',
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      fontSize: 16, // A bit smaller than the massive Rp
                                      color: AppColors.neutral,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Pengajuan',
                      style: AppTextStyles.labelLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RiwayatPengajuanScreen(riwayatData: riwayatPengajuan),
                          ),
                        );
                      },
                      child: Text(
                        'Lihat semua',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                ...riwayatPengajuan.map((item) {
                  return _buildHistoryItem(
                    title: item['title'],
                    date: item['date'],
                    amount: _formatCurrency(item['amount']),
                    status: item['status'],
                  );
                }).toList(),
                
                const SizedBox(height: 24),
              ],
            ),
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
                          fontSize: 8,
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
