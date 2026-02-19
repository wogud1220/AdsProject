import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProjectService {
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

  // 프로젝트 생성
  static Future<Map<String, dynamic>?> createProject({
    required String title,
    required String description,
    required int storeId,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/projects'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'store_id': storeId, // int 타입으로 전송
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 200) {
        // FastAPI가 200을 반환하는 경우도 처리
        return jsonDecode(response.body);
      } else {
        print('Failed to create project: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating project: $e');
      return null;
    }
  }

  // 프로젝트 목록 조회
  static Future<List<dynamic>?> getProjects() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/projects'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // 백엔드 응답이 배열인지 객체인지 확인
        if (responseData is List) {
          return responseData;
        } else if (responseData is Map &&
            responseData.containsKey('projects')) {
          return responseData['projects'];
        } else {
          return responseData; // 그냥 배열로 반환
        }
      } else {
        print('Failed to get projects: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting projects: $e');
      return null;
    }
  }

  // 인증 헤더 생성
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
