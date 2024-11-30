import 'dart:math';
import 'package:flutter/material.dart';

class Randomfield {
  final TextEditingController leftController;
  final TextEditingController rightController;
  int wordsToRemovePercentage;

  Randomfield({
    required this.leftController,
    required this.rightController,
    this.wordsToRemovePercentage = 0, // 기본값을 0으로 설정
  });

  // 비율을 설정하는 메서드 추가
  void setPercentage(int percentage) {
    wordsToRemovePercentage = percentage;
  }

  // 비율에 맞게 빈칸을 만들어주는 함수
  void reloadRandomText(BuildContext context) {
    String originalText = leftController.text; // 왼쪽 텍스트 필드의 텍스트 가져오기
    List<String> words = originalText.split(RegExp(r'\s+')); // 단어 단위로 분리 (공백 기준)

    int wordsToRemove = (words.length * (wordsToRemovePercentage / 100)).round(); // 제거할 단어 수 계산

    // 제거할 단어 수가 0인 경우 종료
    if (wordsToRemove == 0) {
      rightController.text = originalText; // 원본 텍스트를 그대로 표시
      return;
    }

    Random random = Random();
    Set<int> indicesToRemove = {};
    // 랜덤하게 단어의 인덱스를 선택하여 빈칸으로 변경
    while (indicesToRemove.length < wordsToRemove && indicesToRemove.length < words.length) {
      indicesToRemove.add(random.nextInt(words.length));
    }

    // 텍스트 필드 위젯을 동적으로 생성하기 위해 List<TextField>를 만듬
    List<Widget> widgets = [];
    for (int i = 0; i < words.length; i++) {
      if (indicesToRemove.contains(i)) {
        widgets.add(
          Container(
            width: 60, // 텍스트 필드 크기 조정
            child: TextField(
              decoration: InputDecoration(
                hintText: '____',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(words[i]),
          ),
        );
      }
    }

    // 텍스트 필드와 일반 텍스트를 합쳐서 새로운 위젯 리스트로 만든 후 화면에 표시
    rightController.text = ""; // 실제 텍스트필드는 컨트롤러에 직접 표시할 수 없으므로 빈 텍스트로 초기화
    showDialogWithTextFields(context, widgets); // 텍스트 필드를 보여주는 dialog 등을 만들 수 있습니다.
  }

  // 텍스트 필드를 보여주는 Dialog를 생성하는 예시
  void showDialogWithTextFields(BuildContext context, List<Widget> widgets) {
    showDialog(
      context: context, // 이제 context를 매개변수로 전달받습니다.
      builder: (context) {
        return AlertDialog(
          title: Text('Fill the Blanks'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
