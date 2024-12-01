import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:examblanker/widget/blanktext_container.dart';
import 'package:examblanker/widget/textinput_container.dart';

class ExamBlankerScreen extends StatefulWidget {
  final String initialText; // 초기 텍스트를 받을 필드

  const ExamBlankerScreen({super.key, required this.initialText});

  @override
  State<ExamBlankerScreen> createState() => _ExamBlankerScreenState();
}

class _ExamBlankerScreenState extends State<ExamBlankerScreen> {
  late TextEditingController _textController;
  List<Map<String, dynamic>> _blankedTextWidgets = [];
  int _blankCount = 2;
  bool _isTextVisible = true; // 텍스트 필드의 가시성 제어
  String _savedText = ""; // 숨겨진 상태의 텍스트 저장
  final String _etriApiKey = " f341f63a-d303-469b-ba56-191d3904b428";

  @override
  void initState() {
    super.initState();
    // 초기 텍스트를 TextEditingController에 설정
    _textController = TextEditingController(text: widget.initialText);
  }

  Future<List<String>> _analyzeTextWithEtri(String text) async {
    final url = Uri.parse("http://aiopen.etri.re.kr:8000/WiseNLU");
    final headers = {
      "Content-Type": "application/json; charset=UTF-8",
      "Authorization": _etriApiKey,
    };
    final body = jsonEncode({
      "request_id": "reserved field",
      "argument": {
        "analysis_code": "morp",
        "text": text,
      },
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sentences = data['return_object']['sentence'] as List;
        final words = <String>[];
        for (var sentence in sentences) {
          final morpList = sentence['morp'] as List;
          words.addAll(morpList.map((morp) => morp['lemma'].toString()));
        }
        return words;
      } else {
        throw Exception("ETRI API 요청 실패: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ETRI API 호출 중 오류: $e')),
      );
      return [];
    }
  }

  void _generateBlanks() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('텍스트를 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _savedText = _textController.text; // 텍스트 저장
      _textController.clear(); // 텍스트 필드 비우기
      _isTextVisible = false; // 텍스트 필드 숨기기
    });

    List<String> words = await _analyzeTextWithEtri(_savedText);
    if (words.isEmpty) return;

    if (_blankCount > words.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('빈칸 수는 단어 수보다 적어야 합니다. (최대 ${words.length}개)')),
      );
      return;
    }

    Random random = Random();
    Set<int> blankIndices = {};

    while (blankIndices.length < _blankCount) {
      blankIndices.add(random.nextInt(words.length));
    }

    List<Map<String, dynamic>> widgets = words.asMap().entries.map((entry) {
      int index = entry.key;
      String word = entry.value;
      if (blankIndices.contains(index)) {
        return {'isBlank': true, 'word': word, 'userAnswer': ''};
      }
      return {'isBlank': false, 'word': word};
    }).toList();

    setState(() {
      _blankedTextWidgets = widgets;
    });
  }

  void _toggleTextVisibility() {
    setState(() {
      if (_isTextVisible) {
        _savedText = _textController.text; // 현재 텍스트 저장
        _textController.clear();
      } else {
        _textController.text = _savedText; // 저장된 텍스트 복원
      }
      _isTextVisible = !_isTextVisible;
    });
  }

  void _showBlankCountDialog() {
    TextEditingController blankCountController =
        TextEditingController(text: _blankCount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('빈칸 개수 설정'),
          content: TextField(
            controller: blankCountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '빈칸 개수를 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                int? newBlankCount =
                    int.tryParse(blankCountController.text.trim());
                if (newBlankCount != null && newBlankCount >= 0) {
                  setState(() {
                    _blankCount = newBlankCount;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('올바른 숫자를 입력하세요.')),
                  );
                }
              },
              child: const Text('확인'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blank Generator"),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _checkAnswers,
            tooltip: '정답 확인',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showBlankCountDialog,
            tooltip: '빈칸 개수 설정',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (_isTextVisible)
              Expanded(
                child: TextInputContainer(
                  controller: _textController,
                  label: '원본 텍스트',
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: BlankedTextContainer(blankedTextWidgets: _blankedTextWidgets),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _generateBlanks,
            child: const Icon(Icons.shuffle),
            backgroundColor: Colors.blueGrey,
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _toggleTextVisibility,
            child: Icon(_isTextVisible ? Icons.visibility_off : Icons.visibility),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }

  void _checkAnswers() {
    int totalBlanks = _blankedTextWidgets.where((item) => item['isBlank']).length;
    int correctAnswers = _blankedTextWidgets
        .where((item) => item['isBlank'] && item['userAnswer'] == item['word'])
        .length;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('결과 확인'),
          content: Text('총 $totalBlanks 개 중 $correctAnswers 개 정답입니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
