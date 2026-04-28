import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AnnualReportService {
  /// GET /management/annual-reports — Daftar laporan tahunan (Manager, paginated)
  static Future<Map<String, dynamic>> getReports({
    int page = 1,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'success': false, 'message': 'Sesi tidak valid'};
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/management/annual-reports')
          .replace(queryParameters: {'page': page.toString()});

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
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memuat laporan tahunan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi',
      };
    }
  }

  /// GET /management/annual-reports/{id}/download — Download file laporan
  /// Mengembalikan bytes file untuk disimpan ke storage
  static Future<Map<String, dynamic>> downloadReport(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'success': false, 'message': 'Sesi tidak valid'};
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/management/annual-reports/$id/download'),
        headers: {
          'Accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Ambil nama file dari Content-Disposition header jika ada
        String filename = 'laporan_$id.pdf';
        final contentDisposition = response.headers['content-disposition'];
        if (contentDisposition != null && contentDisposition.contains('filename=')) {
          final parts = contentDisposition.split('filename=');
          if (parts.length > 1) {
            filename = parts[1].replaceAll('"', '').replaceAll("'", '').trim();
            if (filename.contains(';')) {
              filename = filename.split(';').first.trim();
            }
          }
        }

        return {
          'success': true,
          'bytes': response.bodyBytes,
          'filename': filename,
          'message': 'File berhasil diunduh',
        };
      } else {
        // Coba parse error JSON
        String errorMessage = 'Gagal mengunduh file';
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
