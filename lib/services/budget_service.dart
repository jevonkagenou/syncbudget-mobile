import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class BudgetService {
  /// Helper: ambil token dan header standar
  static Future<Map<String, String>?> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// GET /budgets/form-metadata — Data dropdown untuk form anggaran
  static Future<Map<String, dynamic>> getFormMetadata() async {
    try {
      final headers = await _getAuthHeaders();
      if (headers == null) return {'success': false, 'message': 'Sesi tidak valid'};

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/budgets/form-metadata'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal memuat metadata'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  /// GET /budgets — Daftar pagu anggaran (Manager, paginated, searchable)
  static Future<Map<String, dynamic>> getAll({
    String? search,
    int page = 1,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      if (headers == null) {
        return {'success': false, 'message': 'Sesi tidak valid'};
      }

      final queryParams = <String, String>{
        'page': page.toString(),
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/budgets')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memuat data anggaran',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi',
      };
    }
  }

  /// POST /budgets — Buat pagu anggaran baru (Manager)
  static Future<Map<String, dynamic>> store({
    required String fiscalYearId,
    required String budgetCategoryId,
    required String divisionId,
    required String name,
    required double totalAmount,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      if (headers == null) {
        return {'success': false, 'message': 'Sesi tidak valid'};
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/budgets'),
        headers: headers,
        body: jsonEncode({
          'fiscal_year_id': fiscalYearId,
          'budget_category_id': budgetCategoryId,
          'division_id': divisionId,
          'name': name,
          'total_amount': totalAmount,
          'start_date': startDate,
          'end_date': endDate,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Anggaran berhasil ditambahkan',
          'data': data['data'],
        };
      } else {
        String errorMessage = data['message'] ?? 'Gagal menambahkan anggaran';

        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first;
            }
          }
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi',
      };
    }
  }

  /// PUT /budgets/{id} — Edit pagu anggaran (Manager)
  static Future<Map<String, dynamic>> update({
    required String id,
    required String fiscalYearId,
    required String budgetCategoryId,
    required String divisionId,
    required String name,
    required double totalAmount,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      if (headers == null) {
        return {'success': false, 'message': 'Sesi tidak valid'};
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/budgets/$id'),
        headers: headers,
        body: jsonEncode({
          'fiscal_year_id': fiscalYearId,
          'budget_category_id': budgetCategoryId,
          'division_id': divisionId,
          'name': name,
          'total_amount': totalAmount,
          'start_date': startDate,
          'end_date': endDate,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Anggaran berhasil diperbarui',
          'data': data['data'],
        };
      } else {
        String errorMessage = data['message'] ?? 'Gagal memperbarui anggaran';

        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first;
            }
          }
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi',
      };
    }
  }

  /// DELETE /budgets/{id} — Hapus pagu anggaran (Manager)
  static Future<Map<String, dynamic>> destroy(String id) async {
    try {
      final headers = await _getAuthHeaders();
      if (headers == null) {
        return {'success': false, 'message': 'Sesi tidak valid'};
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/budgets/$id'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Anggaran berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus anggaran',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi',
      };
    }
  }
}
