import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // 백엔드 API 주소 (플랫폼별 분기)
  static String get _baseUrl {
    if (kIsWeb) {
      // Web 환경 (Chrome)
      return 'http://127.0.0.1:8000';
    } else {
      // 모바일 환경 (안드로이드 에뮬레이터)
      return 'http://10.0.2.2:8000';
    }
  }

  static const String _tokenKey = 'access_token';

  // 로그인 API 호출
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      // JSON 기반 로그인 엔드포인트 사용 (인코딩 문제 회피)
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/login-json'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email, // UserLogin 스키마와 필드명 일치
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // 토큰 저장
        final token = responseData['access_token'];
        await _saveToken(token);

        return {'success': true, 'token': token, 'message': '로그인 성공'};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'message': errorData['detail'] ?? '로그인 실패'};
      }
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  // 토큰 저장
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // 토큰 가져오기
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 토큰 삭제 (로그아웃)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // 현재 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Authorization 헤더 생성
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
