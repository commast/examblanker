import 'package:flutter/material.dart';
import 'dart:math';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: ExamBlankerScreen(),
    );
  }
}

class ExamBlankerScreen extends StatefulWidget {
  @override
  _ExamBlankerScreenState createState() => _ExamBlankerScreenState();
}

class _ExamBlankerScreenState extends State<ExamBlankerScreen> {
  TextEditingController leftController = TextEditingController();
  List<Map<String, dynamic>> blankedTextWidgets = [];
  int percentage = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blank Generator"),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _checkAnswers,
            tooltip: '정답 확인',
          ),
          IconButton(
            icon: Icon(Icons.settings),
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
              child: _buildTextFieldContainer(
                controller: leftController,
                label: '원본 텍스트',
                color: Colors.blueGrey[50],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildContainerBox(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateBlanks,
        child: Icon(Icons.shuffle),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  Widget _buildTextFieldContainer({
    required TextEditingController controller,
    required String label,
    required Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '텍스트를 입력하세요...',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerBox() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: blankedTextWidgets.isEmpty
          ? Center(child: Text('랜덤 빈칸을 생성하세요!'))
          : SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 8.0,
                runSpacing: 8.0,
                children: blankedTextWidgets.map((item) {
                  if (item['isBlank']) {
                    return SizedBox(
                      width: max(50, item['word'].length * 10.0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: '',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        ),
                        onChanged: (value) {
                          item['userAnswer'] = value.trim();
                        },
                      ),
                    );
                  } else {
                    return Text(
                      item['word'],
                      style: TextStyle(fontSize: 16),
                    );
                  }
                }).toList(),
              ),
            ),
    );
  }

  void _generateBlanks() {
    String inputText = leftController.text.trim();
    if (inputText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('텍스트를 입력해주세요.')),
      );
      return;
    }

    List<String> words = inputText.split(' ');
    Random random = Random();
    int blanksCount = (words.length * (percentage / 100)).round();
    Set<int> blankIndices = {};

    while (blankIndices.length < blanksCount) {
      blankIndices.add(random.nextInt(words.length));
    }

    List<Map<String, dynamic>> widgets = [];
    for (int i = 0; i < words.length; i++) {
      if (blankIndices.contains(i)) {
        widgets.add({
          'isBlank': true,
          'word': words[i],
          'userAnswer': '',
        });
      } else {
        widgets.add({
          'isBlank': false,
          'word': words[i],
        });
      }
    }

    setState(() {
      blankedTextWidgets = widgets;
    });
  }

  void _checkAnswers() {
    if (blankedTextWidgets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('랜덤 빈칸을 생성하세요!')),
      );
      return;
    }

    int totalBlanks = blankedTextWidgets.where((item) => item['isBlank']).length;
    int correctAnswers = blankedTextWidgets
        .where((item) => item['isBlank'] && item['userAnswer'] == item['word'])
        .length;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('결과 확인'),
          content: Text('총 $totalBlanks 개 중 $correctAnswers 개 정답입니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showPercentageDialog() {
    TextEditingController percentageController =
        TextEditingController(text: percentage.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('랜덤 빈칸 비율 설정'),
          content: TextField(
            controller: percentageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: '0 ~ 100 사이의 값을 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                int? newPercentage =
                    int.tryParse(percentageController.text.trim());
                if (newPercentage != null &&
                    newPercentage >= 0 &&
                    newPercentage <= 100) {
                  setState(() {
                    percentage = newPercentage;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('0에서 100 사이의 값을 입력하세요.')),
                  );
                }
              },
              child: Text('확인'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }
}
