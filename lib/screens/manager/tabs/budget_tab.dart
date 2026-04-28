import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../services/budget_service.dart';
import '../../../utils/snackbar_utils.dart';

class BudgetTab extends StatefulWidget {
  const BudgetTab({super.key});

  @override
  State<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<BudgetTab> {
  bool _isLoading = true;
  List<dynamic> _budgets = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalItems = 0;
  final _searchCtrl = TextEditingController();

  // Form metadata
  List<dynamic> _fiscalYears = [];
  List<dynamic> _divisions = [];
  List<dynamic> _categories = [];

  final _currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadMetadata();
    _loadBudgets();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMetadata() async {
    final result = await BudgetService.getFormMetadata();
    if (result['success'] && mounted) {
      final d = result['data'];
      setState(() {
        _fiscalYears = d['fiscal_years'] ?? [];
        _divisions = d['divisions'] ?? [];
        _categories = d['budget_categories'] ?? [];
      });
    }
  }

  Future<void> _loadBudgets({int page = 1}) async {
    setState(() => _isLoading = true);
    final result = await BudgetService.getAll(search: _searchCtrl.text.trim(), page: page);
    if (!mounted) return;
    if (result['success']) {
      final d = result['data'];
      setState(() {
        _budgets = d['data'] ?? [];
        _currentPage = d['current_page'] ?? 1;
        _lastPage = d['last_page'] ?? 1;
        _totalItems = d['total'] ?? 0;
      });
    } else {
      SnackbarUtils.showModernSnackBar(context, result['message'] ?? 'Gagal memuat data', isError: true);
    }
    setState(() => _isLoading = false);
  }

  Color _progressColor(double pct) {
    if (pct >= 0.9) return AppColors.danger;
    if (pct >= 0.7) return AppColors.warning;
    return AppColors.success;
  }

  // ── Form Modal ──
  void _showFormModal({Map<String, dynamic>? budget}) {
    final isEdit = budget != null;
    final nameCtrl = TextEditingController(text: isEdit ? budget['name'] : '');
    final amountCtrl = TextEditingController(
      text: isEdit ? budget['total_amount'].toString() : '',
    );
    String? selFiscalYear = isEdit ? budget['fiscal_year_id']?.toString() : null;
    String? selCategory = isEdit ? budget['budget_category_id']?.toString() : null;
    String? selDivision = isEdit ? budget['division_id']?.toString() : null;
    DateTime? startDate = isEdit ? DateTime.tryParse(budget['start_date'] ?? '') : null;
    DateTime? endDate = isEdit ? DateTime.tryParse(budget['end_date'] ?? '') : null;
    bool isSubmitting = false;
    String? errorMsg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
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
                    Text(isEdit ? 'Edit Pagu Anggaran' : 'Buat Pagu Anggaran Baru',
                        style: AppTextStyles.headlineSmall),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20, color: AppColors.neutral),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                if (errorMsg != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(LucideIcons.alertCircle, color: AppColors.danger, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(errorMsg!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.danger))),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),

                // Nama Anggaran
                _label('Nama Anggaran *'),
                _textField(nameCtrl, hint: 'Contoh: Anggaran Q1 IT'),
                const SizedBox(height: 16),

                // Tahun Anggaran + Kategori (2 col)
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Tahun Anggaran *'),
                    _dropdown(
                      value: selFiscalYear,
                      hint: '-- Pilih Tahun --',
                      items: _fiscalYears.map((e) => DropdownMenuItem(
                        value: e['id'].toString(),
                        child: Text(e['year'].toString()),
                      )).toList(),
                      onChanged: (v) => setDlg(() => selFiscalYear = v),
                    ),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Kategori *'),
                    _dropdown(
                      value: selCategory,
                      hint: '-- Pilih Kategori --',
                      items: _categories.map((e) => DropdownMenuItem(
                        value: e['id'].toString(),
                        child: Text(e['name'].toString(), overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (v) => setDlg(() => selCategory = v),
                    ),
                  ])),
                ]),
                const SizedBox(height: 16),

                // Divisi
                _label('Divisi *'),
                _dropdown(
                  value: selDivision,
                  hint: '-- Pilih Divisi --',
                  items: _divisions.map((e) => DropdownMenuItem(
                    value: e['id'].toString(),
                    child: Text(e['name'].toString()),
                  )).toList(),
                  onChanged: (v) => setDlg(() => selDivision = v),
                ),
                const SizedBox(height: 16),

                // Total Pagu
                _label('Total Pagu (Rp) *'),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: '10000000',
                    hintStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight),
                    helperText: 'Masukkan angka saja tanpa titik/koma.',
                    helperStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight, fontSize: 10),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                // Tanggal Mulai & Berakhir
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Tanggal Mulai *'),
                    _datePicker(ctx, value: startDate, hint: 'dd-mm-yyyy', onPicked: (d) => setDlg(() => startDate = d)),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Tanggal Berakhir *'),
                    _datePicker(ctx, value: endDate, hint: 'dd-mm-yyyy', onPicked: (d) => setDlg(() => endDate = d)),
                  ])),
                ]),
                const SizedBox(height: 28),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : () async {
                      setDlg(() => errorMsg = null);

                      if (nameCtrl.text.trim().isEmpty) { setDlg(() => errorMsg = 'Nama anggaran wajib diisi'); return; }
                      if (selFiscalYear == null) { setDlg(() => errorMsg = 'Pilih tahun anggaran'); return; }
                      if (selCategory == null) { setDlg(() => errorMsg = 'Pilih kategori'); return; }
                      if (selDivision == null) { setDlg(() => errorMsg = 'Pilih divisi'); return; }
                      final amt = double.tryParse(amountCtrl.text);
                      if (amt == null || amt <= 0) { setDlg(() => errorMsg = 'Total pagu tidak valid'); return; }
                      if (startDate == null) { setDlg(() => errorMsg = 'Pilih tanggal mulai'); return; }
                      if (endDate == null) { setDlg(() => errorMsg = 'Pilih tanggal berakhir'); return; }
                      if (endDate!.isBefore(startDate!)) { setDlg(() => errorMsg = 'Tanggal berakhir harus setelah tanggal mulai'); return; }

                      setDlg(() => isSubmitting = true);
                      final messenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(ctx);

                      final Map<String, dynamic> result;
                      if (isEdit) {
                        result = await BudgetService.update(
                          id: budget['id'].toString(),
                          fiscalYearId: selFiscalYear!,
                          budgetCategoryId: selCategory!,
                          divisionId: selDivision!,
                          name: nameCtrl.text.trim(),
                          totalAmount: amt,
                          startDate: DateFormat('yyyy-MM-dd').format(startDate!),
                          endDate: DateFormat('yyyy-MM-dd').format(endDate!),
                        );
                      } else {
                        result = await BudgetService.store(
                          fiscalYearId: selFiscalYear!,
                          budgetCategoryId: selCategory!,
                          divisionId: selDivision!,
                          name: nameCtrl.text.trim(),
                          totalAmount: amt,
                          startDate: DateFormat('yyyy-MM-dd').format(startDate!),
                          endDate: DateFormat('yyyy-MM-dd').format(endDate!),
                        );
                      }

                      setDlg(() => isSubmitting = false);

                      if (!mounted) return;
                      if (result['success']) {
                        nav.pop();
                        SnackbarUtils.showModernSnackBarOnMessenger(messenger, result['message'] ?? 'Berhasil');
                        _loadBudgets();
                      } else {
                        setDlg(() => errorMsg = result['message'] ?? 'Gagal menyimpan');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(isEdit ? 'Simpan Perubahan' : 'Simpan', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Anggaran?', style: AppTextStyles.headlineSmall),
        content: Text('Anggaran "$name" akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: AppTextStyles.labelMedium.copyWith(color: AppColors.neutralLight))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await BudgetService.destroy(id);
              if (!mounted) return;
              SnackbarUtils.showModernSnackBar(context, result['message'] ?? '', isError: !result['success']);
              if (result['success']) _loadBudgets();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: AppColors.neutral), onPressed: () => Navigator.pop(context)),
        title: Text('Pagu Anggaran', style: AppTextStyles.headlineSmall),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _showFormModal(),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Buat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _searchCtrl,
              style: AppTextStyles.bodyMedium,
              onSubmitted: (_) => _loadBudgets(),
              decoration: InputDecoration(
                hintText: 'Cari anggaran/divisi...',
                hintStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight),
                prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.neutralLight),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(LucideIcons.x, size: 16, color: AppColors.neutralLight), onPressed: () { _searchCtrl.clear(); _loadBudgets(); })
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Budget List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: () => _loadBudgets(),
                    color: AppColors.primary,
                    child: _budgets.isEmpty
                        ? ListView(children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                const Icon(LucideIcons.wallet, size: 48, color: AppColors.neutralLight),
                                const SizedBox(height: 16),
                                Text('Belum ada pagu anggaran', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralLight)),
                              ])),
                            )
                          ])
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            itemCount: _budgets.length + 1,
                            itemBuilder: (ctx, i) {
                              if (i == _budgets.length) return _buildPagination();
                              return _buildBudgetCard(_budgets[i]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(dynamic b) {
    final total = double.tryParse(b['total_amount'].toString()) ?? 0;
    final used = double.tryParse(b['used_amount'].toString()) ?? 0;
    final remaining = total - used;
    final pct = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final progressColor = _progressColor(pct);

    final divName = b['division']?['name'] ?? '-';
    final catName = b['budget_category']?['name'] ?? '-';
    final fyYear = b['fiscal_year']?['year']?.toString() ?? '-';
    final endDateRaw = b['end_date'];
    final start = b['start_date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(b['start_date'])) : '';
    final end = endDateRaw != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(endDateRaw)) : '';
    final isExpired = endDateRaw != null && DateTime.parse(endDateRaw).isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b['name'] ?? '-', style: AppTextStyles.labelLarge),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                  child: Text('$catName (TA: $fyYear)', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontSize: 10)),
                ),
                if (isExpired) ...[  
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.neutralLight.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Text('Kadaluarsa', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight, fontSize: 10)),
                  ),
                ],
              ]),
            ])),
            PopupMenuButton<String>(
              icon: const Icon(LucideIcons.moreVertical, color: AppColors.neutralLight, size: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: AppColors.surface,
              onSelected: (val) {
                if (val == 'edit') _showFormModal(budget: Map<String, dynamic>.from(b));
                if (val == 'delete') _confirmDelete(b['id'].toString(), b['name'] ?? '');
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(value: 'edit', child: Row(children: [const Icon(LucideIcons.pencil, size: 16, color: AppColors.primary), const SizedBox(width: 8), Text('Edit', style: AppTextStyles.labelMedium)])),
                PopupMenuItem(value: 'delete', child: Row(children: [const Icon(LucideIcons.trash2, size: 16, color: AppColors.danger), const SizedBox(width: 8), Text('Hapus', style: AppTextStyles.labelMedium.copyWith(color: AppColors.danger))])),
              ],
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(LucideIcons.building, size: 13, color: AppColors.neutralLight),
            const SizedBox(width: 4),
            Text(divName, style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight)),
            const SizedBox(width: 12),
            const Icon(LucideIcons.calendar, size: 13, color: AppColors.neutralLight),
            const SizedBox(width: 4),
            Expanded(child: Text(
              '$start s/d $end',
              style: AppTextStyles.labelSmall.copyWith(
                color: isExpired ? AppColors.neutralLight : AppColors.neutralLight,
                fontSize: 10,
                decoration: isExpired ? TextDecoration.lineThrough : null,
              ),
              overflow: TextOverflow.ellipsis,
            )),
          ]),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_currencyFmt.format(total), style: AppTextStyles.headlineSmall.copyWith(fontSize: 16)),
            Text('${(pct * 100).toStringAsFixed(1)}%', style: AppTextStyles.labelMedium.copyWith(color: progressColor)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Terpakai: ${_currencyFmt.format(used)}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight, fontSize: 11)),
            Text('Sisa: ${_currencyFmt.format(remaining)}', style: AppTextStyles.labelSmall.copyWith(color: progressColor, fontSize: 11)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildPagination() {
    if (_lastPage <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
          onPressed: _currentPage > 1 ? () => _loadBudgets(page: _currentPage - 1) : null,
          icon: Icon(LucideIcons.chevronLeft, color: _currentPage > 1 ? AppColors.primary : AppColors.neutralLight),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
          child: Text('$_currentPage / $_lastPage  ($_totalItems data)', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
        ),
        IconButton(
          onPressed: _currentPage < _lastPage ? () => _loadBudgets(page: _currentPage + 1) : null,
          icon: Icon(LucideIcons.chevronRight, color: _currentPage < _lastPage ? AppColors.primary : AppColors.neutralLight),
        ),
      ]),
    );
  }

  // Helpers
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral)),
  );

  Widget _textField(TextEditingController ctrl, {String hint = ''}) => TextField(
    controller: ctrl,
    style: AppTextStyles.bodyMedium,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight),
      filled: true, fillColor: AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );

  Widget _dropdown({required String? value, required String hint, required List<DropdownMenuItem<String>> items, required ValueChanged<String?> onChanged}) =>
    DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      hint: Text(hint, style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutralLight)),
      items: items,
      onChanged: onChanged,
      dropdownColor: AppColors.surface,
    );

  Widget _datePicker(BuildContext ctx, {DateTime? value, String hint = '', required ValueChanged<DateTime?> onPicked}) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: ctx,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
            child: child!,
          ),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Expanded(child: Text(
            value != null ? DateFormat('dd-MM-yyyy').format(value) : hint,
            style: AppTextStyles.bodyMedium.copyWith(color: value != null ? AppColors.neutral : AppColors.neutralLight),
          )),
          const Icon(LucideIcons.calendar, size: 16, color: AppColors.neutralLight),
        ]),
      ),
    );
  }
}
