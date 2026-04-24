import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'success': false, 'message': 'Sesi tidak valid'};
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard'),
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
          'message': data['message'] ?? 'Gagal memuat data dasbor',
        };
      }
    } catch (e) {
      print('API Error get dashboard: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi',
      };
    }
  }
}
