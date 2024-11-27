import 'package:examblanker/class/RandomField.dart';
import 'package:examblanker/widget/ExamField.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 
  TextEditingController leftcontroller = TextEditingController();
  TextEditingController rightcontroller = TextEditingController(); 
  int percentage = 3; // 빈칸 최대 개수
  late Randomfield randomtext;

  @override
  void initState() {
    super.initState();
    // 초기화 시 randomtext를 설정합니다.
    _initializeRandomField();
  }

  void _initializeRandomField() {
    randomtext = Randomfield(
      leftController: leftcontroller,
      rightController: rightcontroller,
      wordsToRemovePercentage: percentage,
    );
  }

   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("blank생성도우미"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: '단어 지우기 비율 설정',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            // 왼쪽 텍스트 필드
            Expanded(
              child: Column(
                children: [
                  Examfield(
                    controller: leftcontroller,
                    bgColor: Colors.amber[100],
                    text: '저장할 텍스트',
                    ),
                  SizedBox(height: 10), // 텍스트 필드와 버튼 사이의 간격
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _loadText,
                        child: Text('텍스트 불러오기'), // 버튼 텍스트 고정
                      ),
                      SizedBox( width: 500,),
                      ElevatedButton(
                    onPressed: _saveText,
                    child: Text('텍스트 저장하기'), // 버튼 텍스트 고정
                  ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            // 오른쪽 텍스트 필드
            Expanded(
              child: Column(
                children: [
                  Examfield(
                   text: '로드될 텍스트',
                   bgColor: Color.fromARGB(255, 158, 228, 244),
                   controller: rightcontroller),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed:() {
                          randomtext.reloadRandomText();
                        },
                        child: Text('랜덤 빈칸 텍스트 불러오기'),
                      ),
                      ElevatedButton(
                        onPressed: _saveRandomText, // 저장된 랜덤 텍스트를 저장하는 버튼
                        child: Text('랜덤 텍스트 저장하기'),
                      ),
                      ElevatedButton(
                        onPressed: _loadRandomText, // 저장된 랜덤 텍스트를 불러오는 버튼
                        child: Text('저장된 랜덤 텍스트 불러오기'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  void _saveText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedText', leftcontroller.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('저장 완료')),
    );
  }

  
  void _loadText() async   // 저장된 텍스트를 불러와 왼쪽 텍스트 필드에 표시하는 함수
  { 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedText = prefs.getString('savedText');
    if (savedText != null) {
      leftcontroller.text = savedText;
      rightcontroller.clear(); // 오른쪽 텍스트 필드는 지우기
      setState(() {});
    }
  }

  
  // 랜덤 텍스트를 저장하는 함수
  void _saveRandomText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('randomText', rightcontroller.text); // 오른쪽 텍스트 필드의 내용을 저장
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('랜덤 텍스트 저장 완료')),
    );
  }

  // 저장된 랜덤 텍스트를 불러오는 함수
  void _loadRandomText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedRandomText = prefs.getString('randomText');
    if (savedRandomText != null) {
      rightcontroller.text = savedRandomText; // 오른쪽 텍스트 필드에 저장된 랜덤 텍스트 표시
      setState(() {});
    }
  }

  // 단어 지우기 비율 설정 다이얼로그
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('단어 지우기 비율 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('0%에서 100% 사이의 값을 입력하세요:'),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: '비율 입력 (기본: 30)'),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    percentage = int.tryParse(value) ?? 0;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (percentage >= 0 && percentage <= 100) {
                  setState(() {
                      randomtext.setPercentage(percentage);
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


