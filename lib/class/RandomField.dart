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
    List<String> lines = originalText.split('\n'); // 줄 단위로 텍스트를 분리

    int totalWords = 0;
    List<List<String>> lineWords = [];
    
    // 각 줄에 있는 단어를 분리하고, 전체 단어의 개수도 계산
    for (var line in lines) {
      List<String> words = line.split(RegExp(r'\s+')); // 각 줄을 단어 단위로 분리
      totalWords += words.length;
      lineWords.add(words);
    }

    int wordsToRemove = (totalWords * (wordsToRemovePercentage / 100)).round(); // 제거할 단어 수 계산

    if (wordsToRemove == 0) {
      rightController.text = originalText; // 원본 텍스트를 그대로 표시
      return;
    }

    Random random = Random();
    Set<int> indicesToRemove = {};
    // 랜덤하게 단어의 인덱스를 선택하여 빈칸으로 변경
    while (indicesToRemove.length < wordsToRemove && indicesToRemove.length < totalWords) {
      indicesToRemove.add(random.nextInt(totalWords)); // 랜덤 인덱스 선택
    }

    List<Widget> modifiedWidgets = [];
    int wordIndex = 0; // 전체 단어의 인덱스를 추적

    // 각 줄에 대해 수정된 단어를 적용
    for (var line in lineWords) {
      List<Widget> modifiedLineWidgets = [];
      
      for (var word in line) {
        if (indicesToRemove.contains(wordIndex)) {
          // 빈칸으로 변경
          modifiedLineWidgets.add(
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '____', // 빈칸 표시
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          );
        } else {
          // 원본 텍스트 그대로 유지
          modifiedLineWidgets.add(
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Text(word),
            ),
          );
        }
        wordIndex++; // 단어 인덱스 증가
      }

      // 수정된 줄을 Text와 TextField로 추가, 줄바꿈을 유지하도록
      modifiedWidgets.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: modifiedLineWidgets,
      ));
      modifiedWidgets.add(SizedBox(height: 10)); // 각 줄 끝에 간격을 추가
    }

    // 텍스트 필드와 일반 텍스트를 합쳐서 새로운 위젯 리스트로 만든 후 화면에 표시
    showDialogWithTextFields(context, modifiedWidgets); // 텍스트 필드를 보여주는 dialog 등을 만들 수 있습니다.
  }

  // 텍스트 필드를 보여주는 Dialog를 생성하는 예시
  void showDialogWithTextFields(BuildContext context, List<Widget> widgets) {
    showDialog(
      context: context,
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
