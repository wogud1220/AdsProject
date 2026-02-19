import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'user_service.dart';
import 'home_page.dart';
import 'main.dart';
import 'store_create_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserInfo? _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await UserService.getCurrentUser();
      if (userData != null) {
        setState(() {
          _userInfo = UserInfo.fromJson(userData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사용자 정보를 불러오는데 실패했습니다.')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('내 프로필'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userInfo == null
          ? const Center(child: Text('사용자 정보를 찾을 수 없습니다.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 사용자 정보 섹션
                  _buildUserInfoSection(),
                  const SizedBox(height: 24),

                  // 가게 정보 섹션
                  _buildStoresSection(),
                  const SizedBox(height: 24),

                  // 로그아웃 버튼
                  _buildLogoutButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    _userInfo!.username[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userInfo!.username,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _userInfo!.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              '사업 유형',
              _getBusinessTypeText(_userInfo!.businessType),
            ),
            _buildInfoRow('계정 상태', _userInfo!.isVerified ? '인증됨' : '미인증'),
            _buildInfoRow('활성 상태', _userInfo!.isActive ? '활성' : '비활성'),
            _buildInfoRow('가입일', _formatDate(_userInfo!.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildStoresSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  '내 가게',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_userInfo!.hasStores)
              // 가게 목록
              ..._userInfo!.stores.map((store) => _buildStoreCard(store))
            else
              // 가게가 없을 때
              _buildEmptyStoresSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard(StoreInfo store) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.store, color: Colors.blue.shade700),
        ),
        title: Text(
          store.brandName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('브랜드 톤: ${store.brandTone}'),
            if (store.description != null)
              Text(
                store.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            Text('등록일: ${_formatDate(store.createdAt)}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoreCreatePage(store: store),
            ),
          );

          if (result == true) {
            // 가게 수정 성공 시 사용자 정보 다시 로드
            _loadUserInfo();
          }
        },
      ),
    );
  }

  Widget _buildEmptyStoresSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.store_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            '등록된 가게가 없습니다.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '가게를 등록하고 프로젝트를 생성해보세요.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StoreCreatePage(),
                ),
              );

              if (result == true) {
                // 가게 생성 성공 시 사용자 정보 다시 로드
                _loadUserInfo();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('가게 등록하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text('로그아웃'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  String _getBusinessTypeText(String businessType) {
    switch (businessType) {
      case 'restaurant':
        return '음식점';
      case 'clothing':
        return '의류';
      case 'service':
        return '서비스';
      case 'beauty':
        return '뷰티';
      case 'education':
        return '교육';
      case 'medical':
        return '의료';
      default:
        return businessType;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
