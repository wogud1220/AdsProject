import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
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

  // 현재 사용자 정보 조회
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/users/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to get user info: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

  // 가게 생성
  static Future<bool> createStore({
    required String brandName,
    required String brandTone,
    required String description,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/stores/'),
        headers: headers,
        body: jsonEncode({
          'brand_name': brandName,
          'brand_tone': brandTone,
          'description': description,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Store created successfully');
        return true;
      } else {
        print('Failed to create store: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating store: $e');
      throw Exception('Failed to create store: $e');
    }
  }

  // 가게 수정
  static Future<bool> updateStore({
    required int storeId,
    required String brandName,
    required String brandTone,
    required String description,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/api/v1/stores/$storeId'),
        headers: headers,
        body: jsonEncode({
          'brand_name': brandName,
          'brand_tone': brandTone,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        print('Store updated successfully');
        return true;
      } else {
        print('Failed to update store: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating store: $e');
      throw Exception('Failed to update store: $e');
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

// 사용자 정보 모델
class UserInfo {
  final int id;
  final String email;
  final String username;
  final String businessType;
  final bool isVerified;
  final bool isActive;
  final String createdAt;
  final List<StoreInfo> stores;

  UserInfo({
    required this.id,
    required this.email,
    required this.username,
    required this.businessType,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    required this.stores,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    final storesList = <StoreInfo>[];
    if (json['stores'] != null) {
      for (final store in json['stores']) {
        storesList.add(StoreInfo.fromJson(store));
      }
    }

    return UserInfo(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      businessType: json['business_type'],
      isVerified: json['is_verified'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      stores: storesList,
    );
  }

  bool get hasStores => stores.isNotEmpty;
  StoreInfo? get firstStore => stores.isNotEmpty ? stores.first : null;
}

class StoreInfo {
  final int id;
  final int userId;
  final String brandName;
  final String brandTone;
  final String? description;
  final String createdAt;

  StoreInfo({
    required this.id,
    required this.userId,
    required this.brandName,
    required this.brandTone,
    this.description,
    required this.createdAt,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['id'],
      userId: json['user_id'],
      brandName: json['brand_name'],
      brandTone: json['brand_tone'],
      description: json['description'],
      createdAt: json['created_at'],
    );
  }
}
