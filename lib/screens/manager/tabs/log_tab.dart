import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../services/activity_log_service.dart';

class LogTab extends StatefulWidget {
  const LogTab({super.key});

  @override
  State<LogTab> createState() => _LogTabState();
}

class _LogTabState extends State<LogTab> {
  bool _isLoading = true;
  List<dynamic> _logs = [];
  int _currentPage = 1;
  int _lastPage = 1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ActivityLogService.getLogs(page: page);

    if (!mounted) return;

    if (result['success']) {
      final data = result['data'];
      setState(() {
        _logs = data['data'] ?? [];
        _currentPage = data['current_page'] ?? 1;
        _lastPage = data['last_page'] ?? 1;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatSubjectType(String? type) {
    if (type == null) return 'Sistem';
    // Extract class name from full namespace
    final parts = type.split('\\');
    final className = parts.last;
    switch (className) {
      case 'Reimbursement':
        return 'Pengajuan Dana';
      case 'Budget':
        return 'Anggaran';
      case 'User':
        return 'Pengguna';
      case 'Division':
        return 'Divisi';
      case 'FiscalYear':
        return 'Tahun Anggaran';
      default:
        return className;
    }
  }

  IconData _getIconForSubject(String? type) {
    if (type == null) return LucideIcons.activity;
    final className = type.split('\\').last;
    switch (className) {
      case 'Reimbursement':
        return LucideIcons.fileText;
      case 'Budget':
        return LucideIcons.wallet;
      case 'User':
        return LucideIcons.user;
      case 'Division':
        return LucideIcons.building;
      case 'FiscalYear':
        return LucideIcons.calendar;
      default:
        return LucideIcons.activity;
    }
  }

  Color _getColorForDescription(String? desc) {
    if (desc == null) return AppColors.info;
    if (desc.contains('created') || desc.contains('dicreated')) return AppColors.success;
    if (desc.contains('updated') || desc.contains('diupdated')) return AppColors.primary;
    if (desc.contains('deleted') || desc.contains('dideleted')) return AppColors.danger;
    return AppColors.info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Log Aktivitas',
          style: AppTextStyles.headlineSmall,
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.alertTriangle, color: AppColors.danger, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadLogs(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadLogs(page: 1),
                  color: AppColors.primary,
                  child: _logs.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.clipboardList, color: AppColors.neutralLight, size: 48),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum ada log aktivitas',
                                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                itemCount: _logs.length,
                                itemBuilder: (context, index) {
                                  final log = _logs[index];
                                  final subjectType = log['subject_type'] as String?;
                                  final description = log['description'] as String?;
                                  final causerName = log['causer'] != null ? log['causer']['name'] : 'Sistem';
                                  final createdAt = log['created_at'] as String?;
                                  final accentColor = _getColorForDescription(description);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border(
                                        left: BorderSide(color: accentColor, width: 4),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.02),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: accentColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _getIconForSubject(subjectType),
                                            color: accentColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                description ?? 'Aktivitas tidak diketahui',
                                                style: AppTextStyles.labelMedium,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: accentColor.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      _formatSubjectType(subjectType),
                                                      style: AppTextStyles.labelSmall.copyWith(
                                                        color: accentColor,
                                                        fontSize: 9,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      '$causerName  •  ${_formatDate(createdAt)}',
                                                      style: AppTextStyles.labelSmall.copyWith(
                                                        color: AppColors.neutralLight,
                                                        fontSize: 10,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Pagination
                            if (_lastPage > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  border: Border(top: BorderSide(color: AppColors.border)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: _currentPage > 1
                                          ? () => _loadLogs(page: _currentPage - 1)
                                          : null,
                                      icon: Icon(
                                        LucideIcons.chevronLeft,
                                        color: _currentPage > 1 ? AppColors.primary : AppColors.neutralLight,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$_currentPage / $_lastPage',
                                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _currentPage < _lastPage
                                          ? () => _loadLogs(page: _currentPage + 1)
                                          : null,
                                      icon: Icon(
                                        LucideIcons.chevronRight,
                                        color: _currentPage < _lastPage ? AppColors.primary : AppColors.neutralLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
    );
  }
}
