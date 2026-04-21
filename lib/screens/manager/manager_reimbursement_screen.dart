import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class ManagerReimbursementScreen extends StatefulWidget {
  const ManagerReimbursementScreen({super.key});

  @override
  State<ManagerReimbursementScreen> createState() => _ManagerReimbursementScreenState();
}

class _ManagerReimbursementScreenState extends State<ManagerReimbursementScreen> {
  // Dummy data
  final List<Map<String, dynamic>> _requests = [
    {
      'id': 'REQ-20260401',
      'staff': 'Klein Moretti',
      'division': 'IT & Engineering',
      'amount': 'Rp 5.500.000',
      'purpose': 'Pembelian Lisensi Software & Server',
      'date': '21 Apr 2026',
      'status': 'Menunggu Persetujuan',
    },
    {
      'id': 'REQ-20260402',
      'staff': 'Audrey Hall',
      'division': 'Marketing',
      'amount': 'Rp 12.000.000',
      'purpose': 'Biaya Kampanye Iklan Q2',
      'date': '20 Apr 2026',
      'status': 'Menunggu Persetujuan',
    },
    {
      'id': 'REQ-20260403',
      'staff': 'Derrick Berg',
      'division': 'Operations',
      'amount': 'Rp 2.300.000',
      'purpose': 'Perbaikan Inventaris Kantor',
      'date': '19 Apr 2026',
      'status': 'Dalam Audit',
    },
  ];

  void _handleAction(String id, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pengajuan $id berhasil di-$action'),
        backgroundColor: action == 'tolak' ? AppColors.danger : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAuditDialog(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Mulai Audit', style: AppTextStyles.headlineSmall),
          content: Text(
            'Apakah Anda ingin melakukan audit lebih lanjut untuk pengajuan $id?',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: AppColors.neutralLight)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleAction(id, 'audit');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Mulai Audit'),
            ),
          ],
        );
      },
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
                Text(
                  'Persetujuan Dana',
                  style: AppTextStyles.headlineMedium,
                ),
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
          
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              itemCount: _requests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final request = _requests[index];
                return _buildRequestCard(request);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final isAuditing = request['status'] == 'Dalam Audit';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAuditing ? AppColors.warning.withValues(alpha: 0.1) : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request['status'],
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isAuditing ? AppColors.warning : AppColors.primary,
                  ),
                ),
              ),
              Text(
                request['date'],
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutralLight),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.border,
                child: Text(
                  request['staff'].substring(0, 1),
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.neutral),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['staff'],
                      style: AppTextStyles.labelLarge,
                    ),
                    Text(
                      request['division'],
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutralLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            request['purpose'],
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            request['amount'],
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleAction(request['id'], 'tolak'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tolak'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleAction(request['id'], 'setujui'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Setujui'),
                ),
              ),
            ],
          ),
          if (!isAuditing) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _showAuditDialog(request['id']),
                icon: const Icon(LucideIcons.search, size: 16),
                label: const Text('Lakukan Audit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
