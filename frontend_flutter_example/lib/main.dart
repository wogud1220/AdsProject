import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI 광고 배너 생성기',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    setState(() {
      _isLoading = false;
      _isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isLoggedIn ? const HomePage() : const LoginPage();
  }
}

class AdGeneratorPage extends StatefulWidget {
  final int projectId;
  final String projectTitle;

  const AdGeneratorPage({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<AdGeneratorPage> createState() => _AdGeneratorPageState();
}

class _AdGeneratorPageState extends State<AdGeneratorPage> {
  final _formKey = GlobalKey<FormState>();
  final _adDescriptionController = TextEditingController(); // 광고 내용
  final _textInImageController = TextEditingController(); // 이미지 안의 텍스트
  final _imagePromptController = TextEditingController(); // 이미지 묘사

  String _selectedSampler = 'euler';
  String _selectedSize = 'instagram'; // 기본값: 인스타 (1:1)
  bool _isLoading = false;
  String? _generatedImageUrl;
  String? _errorMessage;
  String? _optimizedPrompt; // AI가 최적화한 프롬프트
  String? _adCopy; // AI가 생성한 광고 문구

  @override
  void initState() {
    super.initState();
    // 디버깅 로그: 페이지 초기화 시 프로젝트 ID 확인
    print('🔍 DEBUG: AdGeneratorPage 초기화 - 프로젝트 ID: ${widget.projectId}');
    print('🔍 DEBUG: AdGeneratorPage 초기화 - 프로젝트 제목: ${widget.projectTitle}');
  }

  // 이미지 사이즈 옵션
  static const Map<String, Map<String, int>> _sizeOptions = {
    'instagram': {'width': 1024, 'height': 1024}, // 인스타 (1:1)
    'youtube': {'width': 1216, 'height': 832}, // 유튜브 썸네일 (16:9)
    'story': {'width': 832, 'height': 1216}, // 인스타 스토리 (9:16)
    'blog': {'width': 1024, 'height': 768}, // 블로그/일반 (4:3)
  };

  // 사이즈 옵션 표시 이름
  static const Map<String, String> _sizeLabels = {
    'instagram': '인스타 (1:1)',
    'youtube': '유튜브 썸네일 (16:9)',
    'story': '인스타 스토리 (9:16)',
    'blog': '블로그/일반 (4:3)',
  };

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

  static String get _apiUrl => '$_baseUrl/api/v1/contents/generate';

  // 지원되는 샘플러 목록
  static const List<String> _samplers = [
    'euler',
    'euler_ancestral',
    'heun',
    'dpm_2',
    'dpm_2_ancestral',
    'lms',
    'dpm_fast',
    'dpm_adaptive',
    'dpmpp_2s_ancestral',
    'dpmpp_sde',
    'dpmpp_2m',
    'ddim',
  ];

  Future<void> _generateImage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _generatedImageUrl = null;
      _errorMessage = null;
      _optimizedPrompt = null;
      _adCopy = null;
    });

    try {
      // 인증 헤더 가져오기
      final headers = await AuthService.getAuthHeaders();

      // 디버깅 로그: 현재 프로젝트 ID 확인
      print('🔍 DEBUG: 이미지 생성 요청 - 프로젝트 ID: ${widget.projectId}');
      print('🔍 DEBUG: 광고 내용: ${_adDescriptionController.text}');
      print('🔍 DEBUG: 이미지 묘사: ${_imagePromptController.text}');

      // 전송할 데이터 로그 확인
      final selectedSize = _sizeOptions[_selectedSize]!;
      final requestData = {
        'project_id': widget.projectId,
        'ad_description': _adDescriptionController.text, // 광고 내용
        'image_prompt': _imagePromptController.text, // 이미지 묘사
        'text_in_image': _textInImageController.text, // 이미지 안의 텍스트
        'negative_prompt': '',
        'cfg': 1.0,
        'sampler_name': _selectedSampler,
        'scheduler': 'simple',
        'steps': 8,
        'width': selectedSize['width'],
        'height': selectedSize['height'],
        'seed': 12345,
      };
      print('🔍 DEBUG: 전송할 데이터: $requestData');
      print(
        '🔍 DEBUG: 선택된 사이즈: ${_sizeLabels[_selectedSize]} (${selectedSize['width']}x${selectedSize['height']})',
      );

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          // content_id를 저장하고 API를 통해 이미지를 가져오도록 수정
          final contentId = responseData['content_id'] as int;
          setState(() {
            _generatedImageUrl = '$_baseUrl/api/v1/contents/$contentId/image';
            _optimizedPrompt = responseData['optimized_prompt'] as String?;
            _adCopy = responseData['ad_copy'] as String?;
          });
        } else {
          setState(() {
            _errorMessage = responseData['message'] ?? '이미지 생성에 실패했습니다.';
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = '인증이 만료되었습니다. 다시 로그인해주세요.';
        });
      } else {
        setState(() {
          _errorMessage = '서버 오류: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '네트워크 오류: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 광고 내용 입력 필드 (상단)
              TextFormField(
                controller: _adDescriptionController,
                decoration: const InputDecoration(
                  labelText: '광고할 제품/가게 설명',
                  hintText: '가게 특징, 타겟 고객, 강조할 점 등을 입력하세요...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '광고 내용을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 이미지 안의 텍스트 입력 필드
              TextFormField(
                controller: _textInImageController,
                decoration: const InputDecoration(
                  labelText: '상호명/텍스트 (선택)',
                  hintText: '이미지 안에 들어갈 텍스트 (예: 맛있는 빵집)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),

              // 이미지 묘사 입력 필드 (하단)
              TextFormField(
                controller: _imagePromptController,
                decoration: const InputDecoration(
                  labelText: '생성할 이미지 묘사',
                  hintText: '구도, 배경, 분위기, 시각적 요소 등을 설명하세요...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '이미지 묘사를 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 이미지 사이즈 선택 드롭다운
              DropdownButtonFormField<String>(
                value: _selectedSize,
                decoration: const InputDecoration(
                  labelText: '이미지 사이즈',
                  border: OutlineInputBorder(),
                ),
                items: _sizeOptions.keys.map((sizeKey) {
                  return DropdownMenuItem(
                    value: sizeKey,
                    child: Text(_sizeLabels[sizeKey]!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSize = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 샘플러 선택 드롭다운
              DropdownButtonFormField<String>(
                value: _selectedSampler,
                decoration: const InputDecoration(
                  labelText: '샘플러',
                  border: OutlineInputBorder(),
                ),
                items: _samplers.map((sampler) {
                  return DropdownMenuItem(
                    value: sampler,
                    child: Text(sampler.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSampler = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // 생성 버튼
              ElevatedButton(
                onPressed: _isLoading ? null : _generateImage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('생성 중...'),
                        ],
                      )
                    : const Text('광고 배너 생성', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),

              // 에러 메시지
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ),
                    ],
                  ),
                ),

              // 생성된 이미지 표시
              if (_generatedImageUrl != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '생성된 광고 배너:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: FutureBuilder<Uint8List>(
                              future: _loadAuthenticatedImage(
                                _generatedImageUrl!,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '이미지를 불러올 수 없습니다',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.contain,
                                  );
                                } else {
                                  return const Center(child: Text('이미지 없음'));
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // AI가 생성한 광고 문구 및 최적화된 프롬프트 표시
              if (_adCopy != null || _optimizedPrompt != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AI 생성 결과',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // AI 광고 문구
                      if (_adCopy != null) ...[
                        const Text(
                          '📝 AI가 쓴 광고 문구',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.blue.shade100),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _adCopy!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 최적화된 프롬프트
                      if (_optimizedPrompt != null) ...[
                        const Text(
                          '🧠 AI가 고퀄리티 영어 프롬프트로 변환',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.blue.shade100),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _optimizedPrompt!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _adDescriptionController.dispose();
    _textInImageController.dispose();
    _imagePromptController.dispose();
    super.dispose();
  }
}
