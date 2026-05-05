import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../services/annual_report_service.dart';
import '../../../utils/snackbar_utils.dart';
import '../../../utils/file_download_utils.dart';

class ArsipTab extends StatefulWidget {
  const ArsipTab({super.key});

  @override
  State<ArsipTab> createState() => _ArsipTabState();
}

class _ArsipTabState extends State<ArsipTab> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  final List<Map<String, dynamic>> _reports = [];
  int _currentPage = 1;
  int _lastPage = 1;

  final _searchCtrl = TextEditingController();
  String _searchText = '';

  final Set<String> _downloadingIds = {};

  @override
  void initState() {
    super.initState();
    _loadReports(reset: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadReports({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _reports.clear();
        _currentPage = 1;
      });
    } else {
      if (_isLoadingMore || _currentPage > _lastPage) return;
      setState(() => _isLoadingMore = true);
    }

    final result = await AnnualReportService.getReports(
      page: _currentPage,
      search: _searchText.isNotEmpty ? _searchText : null,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final paginatedData = result['data'] as Map<String, dynamic>;
      final items = (paginatedData['data'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];

      setState(() {
        _reports.addAll(items);
        _lastPage = paginatedData['last_page'] ?? 1;
        _currentPage++;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _error = result['message'] ?? 'Gagal memuat data';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onSearch(String value) {
    setState(() => _searchText = value);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_searchText == value) _loadReports(reset: true);
    });
  }

  Future<void> _downloadReport(Map<String, dynamic> report) async {
    final id = report['id'].toString();
    setState(() => _downloadingIds.add(id));

    final messenger = ScaffoldMessenger.of(context);
    final result = await AnnualReportService.downloadReport(id);

    if (!mounted) return;
    setState(() => _downloadingIds.remove(id));

    if (result['success'] == true) {
      final bytes = result['bytes'] as List<int>;
      final filename = result['filename'] as String;
      await FileDownloadUtils.saveAndOpen(
        messenger: messenger,
        bytes: bytes,
        filename: filename,
      );
    } else {
      SnackbarUtils.showModernSnackBarOnMessenger(
        messenger,
        result['message'] ?? 'Gagal mengunduh laporan',
        isError: true,
      );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
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
        title: Text('Arsip Laporan', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Cari laporan...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight),
                prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.neutralLight),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 18, color: AppColors.neutralLight),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // ── Body ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                    ? _buildError()
                    : _reports.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh: () => _loadReports(reset: true),
                            color: AppColors.primary,
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                if (notification is ScrollEndNotification &&
                                    notification.metrics.pixels >=
                                        notification.metrics.maxScrollExtent - 100) {
                                  _loadReports();
                                }
                                return false;
                              },
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                itemCount: _reports.length + (_isLoadingMore ? 1 : 0),
                                separatorBuilder: (_, i) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  if (index == _reports.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  return _buildReportCard(_reports[index]);
                                },
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final id = report['id'].toString();
    final isDownloading = _downloadingIds.contains(id);
    final fiscalYear = report['fiscal_year'];
    final yearLabel = fiscalYear != null ? 'TA ${fiscalYear['year']}' : 'Laporan';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(LucideIcons.fileText, color: AppColors.danger, size: 22),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report['title'] ?? 'Laporan Keuangan',
                    style: AppTextStyles.labelMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          yearLabel,
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(LucideIcons.calendar, size: 12, color: AppColors.neutralLight),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _formatDate(report['created_at']),
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutralLight),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (report['description'] != null &&
                      report['description'].toString().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      report['description'],
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutralLight),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Download Button
            GestureDetector(
              onTap: isDownloading ? null : () => _downloadReport(report),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDownloading
                      ? AppColors.border
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isDownloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(LucideIcons.download, color: AppColors.primary, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.border,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.archive, size: 40, color: AppColors.neutralLight),
          ),
          const SizedBox(height: 16),
          Text(
            _searchText.isNotEmpty ? 'Laporan tidak ditemukan' : 'Belum ada laporan',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _searchText.isNotEmpty
                ? 'Coba kata kunci yang berbeda'
                : 'Laporan tahunan akan muncul di sini\nsetelah diterbitkan oleh admin',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.wifiOff, size: 48, color: AppColors.neutralLight),
          const SizedBox(height: 16),
          Text('Gagal memuat data', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Terjadi kesalahan',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _loadReports(reset: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
