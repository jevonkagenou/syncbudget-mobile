import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ReimbursementService {
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

  /// GET /reimbursements/manager — Semua pengajuan dalam divisi manager (semua status)
  static Future<Map<String, dynamic>> getManagerReimbursements({String? status}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {'success': false, 'message': 'Sesi tidak valid'};
      }

      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/reimbursements/manager')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal memuat data pengajuan'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  /// GET /reimbursements — Riwayat pengajuan milik user yang login
  static Future<Map<String, dynamic>> getMyReimbursements() async {
    try {
      final headers = await _getAuthHeaders();
      if (headers == null) {
        return {'success': false, 'message': 'Sesi tidak valid'};
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reimbursements'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memuat riwayat pengajuan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi',
      };
    }
  }

  /// GET /reimbursements/pending — Daftar pengajuan pending (Manager/Admin)
  static Future<Map<String, dynamic>> getPendingList() async {
    try {
      final headers = await _getAuthHeaders();
      if (headers == null) {
        return {'success': false, 'message': 'Sesi tidak valid'};
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reimbursements/pending'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memuat daftar pengajuan pending',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi',
      };
    }
  }

  /// POST /reimbursements — Buat pengajuan baru (Staff)
  /// Menggunakan multipart request karena ada field file receipt (opsional)
  static Future<Map<String, dynamic>> store({
    required String budgetId,
    required String title,
    required String description,
    required double amount,
    String? receiptFilePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {'success': false, 'message': 'Sesi tidak valid'};
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/reimbursements');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['budget_id'] = budgetId;
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['amount'] = amount.toString();

      if (receiptFilePath != null && receiptFilePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('receipt', receiptFilePath),
        );
      }

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (streamedResponse.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Pengajuan berhasil dikirim',
          'data': data['data'],
        };
      } else {
        // Handle validation errors
        String errorMessage = data['message'] ?? 'Gagal mengirim pengajuan';

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

  /// PUT /reimbursements/{id}/status — Setujui atau Tolak (Manager/Admin)
  static Future<Map<String, dynamic>> updateStatus({
    required String id,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      if (headers == null) {
        return {'success': false, 'message': 'Sesi tidak valid'};
      }

      final Map<String, dynamic> body = {
        'status': status,
      };

      if (status == 'rejected' && rejectionReason != null) {
        body['rejection_reason'] = rejectionReason;
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/reimbursements/$id/status'),
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Status berhasil diperbarui',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memperbarui status pengajuan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi',
      };
    }
  }

  /// DELETE /reimbursements/{id} — Hapus pengajuan pending
  static Future<Map<String, dynamic>> destroy(String id) async {
    try {
      final headers = await _getAuthHeaders();
      if (headers == null) {
        return {'success': false, 'message': 'Sesi tidak valid'};
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/reimbursements/$id'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Pengajuan berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus pengajuan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi',
      };
    }
  }

  /// GET /reimbursements/export/pdf — Download PDF LPJ (Manager)
  /// Mengembalikan bytes PDF untuk disimpan atau ditampilkan
  static Future<Map<String, dynamic>> exportPdf({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return {'success': false, 'message': 'Sesi tidak valid'};
      }

      final queryParams = <String, String>{};
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/reimbursements/export/pdf')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/pdf',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'bytes': response.bodyBytes,
          'message': 'PDF berhasil diunduh',
        };
      } else {
        // Coba parse error JSON jika bukan PDF
        String errorMessage = 'Gagal mengunduh PDF';
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? errorMessage;
        } catch (_) {}

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
}
