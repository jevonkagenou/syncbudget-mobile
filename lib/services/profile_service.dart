import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ProfileService {
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'success': false, 'message': 'Sesi tidak valid. Silakan login kembali.'};
      }

      final Map<String, dynamic> body = {
        'name': name,
        'email': email,
      };

      if (currentPassword != null && currentPassword.isNotEmpty) {
        body['current_password'] = currentPassword;
      }
      if (newPassword != null && newPassword.isNotEmpty) {
        body['password'] = newPassword;
        body['password_confirmation'] = confirmPassword;
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Update stored user data if changed
        if (data['data'] != null && data['data']['user'] != null) {
          await prefs.setString('user_name', data['data']['user']['name']);
          await prefs.setString('user_email', data['data']['user']['email']);
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Profil berhasil diperbarui',
        };
      } else {
        // Handle validation errors from Laravel
        String errorMessage = data['message'] ?? 'Gagal memperbarui profil';
        
        // Laravel default validation errors
        if (data['errors'] != null) {
           final Map<String, dynamic> errors = data['errors'];
           final firstError = errors.values.first;
           if (firstError is List && firstError.isNotEmpty) {
             errorMessage = firstError.first;
           }
        } 
        // Custom validation errors format from user's API
        else if (data['data'] != null && data['data'] is Map && data['success'] == false) {
           final Map<String, dynamic> errors = data['data'];
           if (errors.isNotEmpty) {
             final firstError = errors.values.first;
             if (firstError is List && firstError.isNotEmpty) {
               errorMessage = firstError.first;
             } else if (firstError is String) {
               errorMessage = firstError;
             }
           }
        }
        
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('API Error update profile: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi. Pastikan server berjalan.',
      };
    }
  }
}
