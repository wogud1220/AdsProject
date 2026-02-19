import 'package:flutter/material.dart';
import 'user_service.dart';

class StoreCreatePage extends StatefulWidget {
  final StoreInfo? store; // 수정 모드일 때 기존 가게 정보

  const StoreCreatePage({super.key, this.store});

  @override
  State<StoreCreatePage> createState() => _StoreCreatePageState();
}

class _StoreCreatePageState extends State<StoreCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _brandNameController = TextEditingController();
  final _brandToneController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 수정 모드일 때 기존 값으로 초기화
    if (widget.store != null) {
      _brandNameController.text = widget.store!.brandName;
      _brandToneController.text = widget.store!.brandTone;
      _descriptionController.text = widget.store!.description ?? '';
    }
  }

  @override
  void dispose() {
    _brandNameController.dispose();
    _brandToneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success;

      if (widget.store != null) {
        // 수정 모드
        success = await UserService.updateStore(
          storeId: widget.store!.id,
          brandName: _brandNameController.text.trim(),
          brandTone: _brandToneController.text.trim(),
          description: _descriptionController.text.trim(),
        );
      } else {
        // 생성 모드
        success = await UserService.createStore(
          brandName: _brandNameController.text.trim(),
          brandTone: _brandToneController.text.trim(),
          description: _descriptionController.text.trim(),
        );
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.store != null ? '가게 정보가 수정되었습니다.' : '가게가 성공적으로 등록되었습니다.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('저장에 실패했습니다. 다시 시도해주세요.'),
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.store != null ? '가게 수정' : '가게 등록'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // 가게 이름 입력 필드
              TextFormField(
                controller: _brandNameController,
                decoration: const InputDecoration(
                  labelText: '가게 이름',
                  hintText: '예: 서울카페',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '가게 이름을 입력해주세요.';
                  }
                  if (value.trim().length < 2) {
                    return '가게 이름은 최소 2자 이상이어야 합니다.';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              // 브랜드 톤 입력 필드
              TextFormField(
                controller: _brandToneController,
                decoration: const InputDecoration(
                  labelText: '브랜드 톤',
                  hintText: '예: 친근한, 전문적인, 감성적인',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.palette),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '브랜드 톤을 입력해주세요.';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              // 가게 설명 입력 필드
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '가게 설명',
                  hintText: '가게에 대한 간단한 설명을 입력해주세요.',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '가게 설명을 입력해주세요.';
                  }
                  if (value.trim().length < 10) {
                    return '가게 설명은 최소 10자 이상이어야 합니다.';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 32),

              // 등록 버튼
              ElevatedButton(
                onPressed: _isLoading ? null : _saveStore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(widget.store != null ? '수정 중...' : '등록 중...'),
                        ],
                      )
                    : Text(
                        widget.store != null ? '수정하기' : '등록하기',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
