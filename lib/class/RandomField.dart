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

  void reloadRandomText() {
    String originalText = leftController.text; // 왼쪽 텍스트 필드의 텍스트 가져오기
    List<String> words = originalText.split(' '); // 단어 단위로 분리
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

    for (int i = 0; i < words.length; i++) {
      if (indicesToRemove.contains(i)) {
        words[i] = '____'; // 빈칸으로 변경
      }
    }

    String newText = words.join(' ');
    rightController.text = newText; // 변경된 텍스트를 오른쪽 텍스트 필드에 설정
  }
}
