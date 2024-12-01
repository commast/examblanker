import 'package:flutter/material.dart';
import 'dart:math';
import 'textinput_container.dart';
import 'blanktext_container.dart';

class ExamBlankerScreen extends StatefulWidget {
  const ExamBlankerScreen({super.key});

  @override
  State<ExamBlankerScreen> createState() => _ExamBlankerScreenState();
}

class _ExamBlankerScreenState extends State<ExamBlankerScreen> {
  final TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> _blankedTextWidgets = [];
  int _percentage = 30;

  void _generateBlanks() {
    String inputText = _textController.text.trim();
    if (inputText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('텍스트를 입력해주세요.')),
      );
      return;
    }

    List<String> words = inputText.split(' ');
    Random random = Random();
    int blanksCount = (words.length * (_percentage / 100)).round();
    Set<int> blankIndices = {};

    while (blankIndices.length < blanksCount) {
      blankIndices.add(random.nextInt(words.length));
    }

    List<Map<String, dynamic>> widgets = words.map((word) {
      int index = words.indexOf(word);
      if (blankIndices.contains(index)) {
        return {'isBlank': true, 'word': word, 'userAnswer': ''};
      }
      return {'isBlank': false, 'word': word};
    }).toList();

    setState(() {
      _blankedTextWidgets = widgets;
    });
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

  void _showPercentageDialog() {
    TextEditingController percentageController =
        TextEditingController(text: _percentage.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('랜덤 빈칸 비율 설정'),
          content: TextField(
            controller: percentageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '0 ~ 100 사이의 값을 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                int? newPercentage =
                    int.tryParse(percentageController.text.trim());
                if (newPercentage != null && newPercentage >= 0 && newPercentage <= 100) {
                  setState(() {
                    _percentage = newPercentage;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('0에서 100 사이의 값을 입력하세요.')),
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
            onPressed: _showPercentageDialog,
            tooltip: '랜덤 빈칸 비율 설정',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
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
      floatingActionButton: FloatingActionButton(
        onPressed: _generateBlanks,
        child: const Icon(Icons.shuffle),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }
}
