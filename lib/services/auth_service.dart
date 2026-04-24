import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json', 
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save token and user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['data']['token']);
        await prefs.setString('role', data['data']['user']['role']);
        await prefs.setString('user_name', data['data']['user']['name']);
        await prefs.setString('user_email', data['data']['user']['email']);

        return {
          'success': true,
          'role': data['data']['user']['role'],
          'message': data['message'] ?? 'Login berhasil',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal. Periksa kembali email dan password.',
        };
      }
    } catch (e) {
      print('API Error login: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi. Pastikan server berjalan.',
      };
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'success': true};
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Regardless of API success, we should clear local data
      await prefs.clear();

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Gagal logout dari server'};
      }
    } catch (e) {
      print('API Error logout: $e');
      // Clear locally even if API fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return {'success': true, 'message': 'Logout offline'};
    }
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }
}
