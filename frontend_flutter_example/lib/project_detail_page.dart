import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'home_page.dart';
import 'auth_service.dart';

class ProjectDetailPage extends StatefulWidget {
  final int projectId;
  final String projectTitle;

  const ProjectDetailPage({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _contents = [];
  String? _errorMessage;

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
    // 디버깅 로그: ProjectDetailPage 초기화 시 프로젝트 ID 확인
    print('🔍 DEBUG: ProjectDetailPage 초기화 - 프로젝트 ID: ${widget.projectId}');
    print('🔍 DEBUG: ProjectDetailPage 초기화 - 프로젝트 제목: ${widget.projectTitle}');
    _loadContents();
  }

  Future<void> _loadContents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/projects/${widget.projectId}/contents'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _contents = responseData.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '콘텐츠를 불러오는데 실패했습니다: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '콘텐츠를 불러오는데 실패했습니다: $e';
      });
    }
  }

  Future<void> _deleteProject() async {
    // 삭제 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로젝트 삭제'),
        content: Text(
          '정말 "${widget.projectTitle}" 프로젝트를 삭제하시겠습니까?\n\n'
          '삭제된 프로젝트와 모든 이미지는 복구할 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == null || !confirmed) return;

    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/projects/${widget.projectId}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('프로젝트가 삭제되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제 실패: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Uint8List> _loadAuthenticatedImage(String imageUrl) async {
    try {
      // 인증 헤더 가져오기
      final headers = await AuthService.getAuthHeaders();

      final response = await http.get(Uri.parse(imageUrl), headers: headers);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.projectTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteProject,
            tooltip: '프로젝트 삭제',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadContents,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 새 이미지 생성 버튼
              ElevatedButton.icon(
                onPressed: () {
                  // 디버깅 로그: 네비게이션 시점에 프로젝트 ID 확인
                  print(
                    '🔍 DEBUG: ProjectDetailPage에서 AdGeneratorPage로 이동 - 프로젝트 ID: ${widget.projectId}',
                  );
                  print(
                    '🔍 DEBUG: ProjectDetailPage에서 AdGeneratorPage로 이동 - 프로젝트 제목: ${widget.projectTitle}',
                  );

                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => AdGeneratorPage(
                            projectId: widget.projectId,
                            projectTitle: widget.projectTitle,
                          ),
                        ),
                      )
                      .then((_) {
                        // 이미지 생성 후 목록 새로고침
                        _loadContents();
                      });
                },
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('새 이미지 생성하기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // 콘텐츠 목록
              Expanded(child: _buildContentGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContents,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_contents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '생성된 이미지가 없습니다',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '위 버튼을 눌러 새 이미지를 생성해보세요',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: _contents.length,
      itemBuilder: (context, index) {
        final content = _contents[index];
        return _buildContentCard(content);
      },
    );
  }

  Widget _buildContentCard(Map<String, dynamic> content) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FutureBuilder<Uint8List>(
          future: _loadAuthenticatedImage(
            '$_baseUrl/api/v1/contents/${content['id']}/image',
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      '로드 실패',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              return Image.memory(snapshot.data!, fit: BoxFit.cover);
            } else {
              return const Center(child: Text('이미지 없음'));
            }
          },
        ),
      ),
    );
  }
}
