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

  final _searchCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLogs({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ActivityLogService.getLogs(
      page: page,
      search: _searchCtrl.text.trim(),
      startDate: _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : null,
      endDate: _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null,
    );

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

  void _resetFilters() {
    _searchCtrl.clear();
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadLogs();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) { _startDate = picked; }
        else { _endDate = picked; }
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  String _rawClassName(String? type) {
    if (type == null) return 'Sistem';
    return type.split('\\').last;
  }

  IconData _getIconForSubject(String? type) {
    final className = type?.split('\\').last ?? '';
    switch (className) {
      case 'Reimbursement': return LucideIcons.fileText;
      case 'Budget': return LucideIcons.wallet;
      case 'User': return LucideIcons.user;
      case 'Division': return LucideIcons.building;
      case 'FiscalYear': return LucideIcons.calendar;
      case 'BudgetCategory': return LucideIcons.tag;
      default: return LucideIcons.activity;
    }
  }

  Color _getAccentColor(String? desc) {
    if (desc == null) return AppColors.info;
    if (desc.contains('created') || desc.contains('dicreated')) return AppColors.success;
    if (desc.contains('updated') || desc.contains('diupdated')) return AppColors.primary;
    if (desc.contains('deleted') || desc.contains('dideleted')) return AppColors.danger;
    return AppColors.info;
  }

  Color _getModuleColor(String? type) {
    final className = type?.split('\\').last ?? '';
    switch (className) {
      case 'Reimbursement': return AppColors.warning;
      case 'Budget': return AppColors.success;
      case 'User': return AppColors.primary;
      case 'Division': return AppColors.info;
      case 'FiscalYear': return const Color(0xFF8B5CF6);
      case 'BudgetCategory': return AppColors.secondary;
      default: return AppColors.neutralLight;
    }
  }

  // ── Field label helper ──
  String _friendlyKey(String key) {
    const labels = {
      'name': 'Nama',
      'title': 'Judul',
      'description': 'Deskripsi',
      'amount': 'Nominal',
      'total_amount': 'Total Pagu',
      'used_amount': 'Terpakai',
      'status': 'Status',
      'rejection_reason': 'Alasan Penolakan',
      'start_date': 'Tanggal Mulai',
      'end_date': 'Tanggal Berakhir',
      'division_id': 'ID Divisi',
      'fiscal_year_id': 'ID Tahun Anggaran',
      'budget_category_id': 'ID Kategori',
      'budget_id': 'ID Anggaran',
      'user_id': 'ID Pengguna',
      'action_by': 'Diproses Oleh',
      'created_by': 'Dibuat Oleh',
      'receipt_path': 'Bukti Struk',
      'email': 'Email',
      'role': 'Peran',
      'year': 'Tahun',
      'is_active': 'Status Aktif',
      'code': 'Kode',
    };
    return labels[key] ?? key.replaceAll('_', ' ').split(' ').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  void _showDetailModal(dynamic log) {
    final properties = log['properties'];
    final Map<String, dynamic> oldData = (properties?['old'] is Map)
        ? Map<String, dynamic>.from(properties!['old'])
        : {};
    final Map<String, dynamic> newData = (properties?['attributes'] is Map)
        ? Map<String, dynamic>.from(properties!['attributes'])
        : {};

    // Compute which keys changed
    final allKeys = <String>{
      ...oldData.keys,
      ...newData.keys,
    }.toList();

    final changedKeys = allKeys.where((k) {
      return oldData[k]?.toString() != newData[k]?.toString();
    }).toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DefaultTabController(
        length: 2,
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollCtrl) => Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.gitCompare, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Detail Perubahan', style: AppTextStyles.headlineSmall),
                          Text(
                            log['description'] ?? '',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )),
                      if (changedKeys.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${changedKeys.length} diubah',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      padding: const EdgeInsets.all(4),
                      labelStyle: AppTextStyles.labelMedium,
                      unselectedLabelStyle: AppTextStyles.labelSmall,
                      labelColor: AppColors.neutral,
                      unselectedLabelColor: AppColors.neutralLight,
                      tabs: [
                        Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(LucideIcons.clock, size: 14),
                          const SizedBox(width: 6),
                          const Text('Sebelum'),
                          if (oldData.isNotEmpty) ...[const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                              child: Text('${oldData.length}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.danger, fontSize: 9)),
                            ),
                          ],
                        ])),
                        Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(LucideIcons.checkCircle2, size: 14),
                          const SizedBox(width: 6),
                          const Text('Sesudah'),
                          if (newData.isNotEmpty) ...[const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                              child: Text('${newData.length}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontSize: 9)),
                            ),
                          ],
                        ])),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tab content
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab Sebelum
                      _buildDataTab(
                        scrollCtrl: scrollCtrl,
                        data: oldData,
                        changedKeys: changedKeys,
                        accentColor: AppColors.danger,
                        emptyMsg: 'Tidak ada data sebelumnya\n(kemungkinan data baru dibuat)',
                        emptyIcon: LucideIcons.plusCircle,
                      ),
                      // Tab Sesudah
                      _buildDataTab(
                        scrollCtrl: scrollCtrl,
                        data: newData,
                        changedKeys: changedKeys,
                        accentColor: AppColors.success,
                        emptyMsg: 'Tidak ada data baru\n(kemungkinan data dihapus)',
                        emptyIcon: LucideIcons.trash2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTab({
    required ScrollController scrollCtrl,
    required Map<String, dynamic> data,
    required Set<String> changedKeys,
    required Color accentColor,
    required String emptyMsg,
    required IconData emptyIcon,
  }) {
    if (data.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(emptyIcon, size: 40, color: AppColors.neutralLight),
        const SizedBox(height: 12),
        Text(emptyMsg, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight), textAlign: TextAlign.center),
      ]));
    }

    final entries = data.entries.toList();
    // Sort: changed fields first
    entries.sort((a, b) {
      final aChanged = changedKeys.contains(a.key) ? 0 : 1;
      final bChanged = changedKeys.contains(b.key) ? 0 : 1;
      return aChanged.compareTo(bChanged);
    });

    return ListView.separated(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: entries.length,
      separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
      itemBuilder: (ctx, idx) {
        final entry = entries[idx];
        final isChanged = changedKeys.contains(entry.key);
        final value = entry.value?.toString() ?? '-';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isChanged
                ? accentColor.withValues(alpha: 0.06)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isChanged ? accentColor.withValues(alpha: 0.3) : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Changed indicator
              if (isChanged)
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 8),
                  child: Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _friendlyKey(entry.key),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isChanged ? accentColor : AppColors.neutralLight,
                        fontSize: 10,
                        fontWeight: isChanged ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 3),
                    SelectableText(
                      value.isEmpty ? '-' : value,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isChanged ? accentColor : AppColors.neutral,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isChanged)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    accentColor == AppColors.danger ? LucideIcons.arrowRight : LucideIcons.check,
                    size: 14, color: accentColor.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        );
      },
    );
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
        title: Text('Log Aktivitas', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Filter Section ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  style: AppTextStyles.bodyMedium,
                  onSubmitted: (_) => _loadLogs(),
                  decoration: InputDecoration(
                    hintText: 'Cari aktivitas/pelaku...',
                    hintStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight),
                    prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.neutralLight),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(icon: const Icon(LucideIcons.x, size: 16, color: AppColors.neutralLight), onPressed: () { _searchCtrl.clear(); _loadLogs(); })
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                // Date filters
                Row(
                  children: [
                    Expanded(child: _buildDateButton(
                      value: _startDate,
                      hint: 'Tanggal Mulai',
                      onTap: () => _pickDate(isStart: true),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDateButton(
                      value: _endDate,
                      hint: 'Tanggal Akhir',
                      onTap: () => _pickDate(isStart: false),
                    )),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _loadLogs(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Filter'),
                    ),
                    if (_startDate != null || _endDate != null || _searchCtrl.text.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: _resetFilters,
                        icon: const Icon(LucideIcons.filterX, size: 18, color: AppColors.neutralLight),
                        tooltip: 'Reset filter',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // ── Log List ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _errorMessage != null
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(LucideIcons.alertTriangle, color: AppColors.danger, size: 48),
                        const SizedBox(height: 16),
                        Text(_errorMessage!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadLogs,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                        ),
                      ]))
                    : RefreshIndicator(
                        onRefresh: () => _loadLogs(page: 1),
                        color: AppColors.primary,
                        child: _logs.isEmpty
                            ? ListView(children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.4,
                                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    const Icon(LucideIcons.clipboardList, color: AppColors.neutralLight, size: 48),
                                    const SizedBox(height: 16),
                                    Text('Belum ada log aktivitas', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight)),
                                  ])),
                                )
                              ])
                            : Column(children: [
                                Expanded(
                                  child: ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    itemCount: _logs.length,
                                    itemBuilder: (context, index) => _buildLogCard(_logs[index]),
                                  ),
                                ),
                                _buildPagination(),
                              ]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(dynamic log) {
    final subjectType = log['subject_type'] as String?;
    final description = log['description'] as String?;
    final causerName = log['causer'] != null ? log['causer']['name'] : 'Sistem Otomatis';
    final createdAt = log['created_at'] as String?;
    final accentColor = _getAccentColor(description);
    final moduleColor = _getModuleColor(subjectType);
    final rawClass = _rawClassName(subjectType);
    final hasDetail = log['properties'] != null &&
        (log['properties']['old'] != null || log['properties']['attributes'] != null);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: accentColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(_getIconForSubject(subjectType), color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Aktivitas
                Text(description ?? 'Aktivitas tidak diketahui', style: AppTextStyles.labelMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Row(children: [
                  // Modul Target badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: moduleColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5)),
                    child: Text(rawClass, style: AppTextStyles.labelSmall.copyWith(color: moduleColor, fontSize: 9, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  // Pelaku
                  Expanded(child: Text(
                    '$causerName  •  ${_formatDate(createdAt)}',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight, fontSize: 10),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  )),
                ]),
              ]),
            ),
            // Detail Button
            if (hasDetail)
              IconButton(
                onPressed: () => _showDetailModal(log),
                icon: const Icon(LucideIcons.eye, size: 18, color: AppColors.primary),
                tooltip: 'Lihat detail',
                splashRadius: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton({required DateTime? value, required String hint, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: value != null ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border),
        ),
        child: Row(children: [
          Icon(LucideIcons.calendar, size: 14, color: value != null ? AppColors.primary : AppColors.neutralLight),
          const SizedBox(width: 6),
          Expanded(child: Text(
            value != null ? DateFormat('dd/MM/yyyy').format(value) : hint,
            style: AppTextStyles.labelSmall.copyWith(
              color: value != null ? AppColors.primary : AppColors.neutralLight,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          )),
        ]),
      ),
    );
  }

  Widget _buildPagination() {
    if (_lastPage <= 1) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
          onPressed: _currentPage > 1 ? () => _loadLogs(page: _currentPage - 1) : null,
          icon: Icon(LucideIcons.chevronLeft, color: _currentPage > 1 ? AppColors.primary : AppColors.neutralLight),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
          child: Text('$_currentPage / $_lastPage', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
        ),
        IconButton(
          onPressed: _currentPage < _lastPage ? () => _loadLogs(page: _currentPage + 1) : null,
          icon: Icon(LucideIcons.chevronRight, color: _currentPage < _lastPage ? AppColors.primary : AppColors.neutralLight),
        ),
      ]),
    );
  }
}
