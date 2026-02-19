import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'user_service.dart';
import 'project_service.dart';
import 'profile_page.dart';
import 'project_detail_page.dart';
import 'store_create_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> projects = [];
  bool _isLoading = true;
  bool _isCreating = false;
  final TextEditingController _projectTitleController = TextEditingController();
  UserInfo? _userInfo;

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

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadProjects();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userData = await UserService.getCurrentUser();
      if (userData != null) {
        setState(() {
          _userInfo = UserInfo.fromJson(userData);
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final projects = await ProjectService.getProjects();
      if (projects != null) {
        setState(() {
          this.projects = projects;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('프로젝트를 불러오는데 실패했습니다.')));
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

  Future<void> _createProject() async {
    print('=== DEBUG: _createProject called ===');
    print('User info: ${_userInfo?.email}');
    print('Has stores: ${_userInfo?.hasStores}');
    print('Stores count: ${_userInfo?.stores.length}');
    if (_userInfo?.stores.isNotEmpty == true) {
      print('First store: ${_userInfo?.firstStore?.brandName}');
    }
    print('=====================================');

    if (_projectTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('프로젝트 제목을 입력해주세요.')));
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final result = await ProjectService.createProject(
        title: _projectTitleController.text.trim(),
        description: '',
        storeId: _userInfo!.firstStore!.id,
      );

      if (result != null) {
        _projectTitleController.clear();
        Navigator.of(context).pop();
        _loadProjects(); // 프로젝트 목록 새로고침

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('프로젝트가 생성되었습니다.')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('프로젝트 생성에 실패했습니다.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  void _showCreateProjectDialog() {
    // 가게 정보 확인
    if (_userInfo == null || !_userInfo!.hasStores) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('프로젝트를 만들려면 먼저 가게를 등록해야 합니다.'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: '가게 등록',
            textColor: Colors.white,
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
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 프로젝트'),
        content: TextField(
          controller: _projectTitleController,
          decoration: const InputDecoration(
            labelText: '프로젝트 제목',
            hintText: '제목을 입력하세요',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: _isCreating ? null : _createProject,
            child: _isCreating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('생성'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('AI 광고 배너 생성기'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              // ProfilePage에서 돌아왔을 때 데이터 갱신
              _loadUserInfo();
              _loadProjects();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProjects,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Icon(
                    Icons.dashboard,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '내 프로젝트',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 프로젝트 목록
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : projects.isEmpty
                    ? _buildEmptyState()
                    : _buildProjectList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '첫 프로젝트를 만들어보세요!',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '우측 하단의 + 버튼을 눌러 새 프로젝트를 생성하세요.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                project['title'][0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              project['title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project['description'] ?? '설명 없음'),
                const SizedBox(height: 4),
                Text(
                  '생성일: ${_formatDate(project['created_at'])}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProjectDetailPage(
                    projectId: project['id'],
                    projectTitle: project['title'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  void dispose() {
    _projectTitleController.dispose();
    super.dispose();
  }
}
