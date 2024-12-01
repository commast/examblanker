import 'package:flutter/material.dart';
import 'package:examblanker/screens/examBlankerScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert'; // UTF-8 처리

class MyStartPage extends StatelessWidget {
  const MyStartPage({super.key});

  Future<void> _pickFileAndNavigate(BuildContext context) async {
    try {
      // 파일 선택
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'], // 텍스트 파일만 허용
        withData: true, // 웹에서 바이트 데이터 가져오기 활성화
      );

      if (result != null) {
        String contents;

        try {
          // 바이트 데이터로부터 UTF-8 텍스트 변환
          List<int> bytes = result.files.single.bytes!;
          contents = utf8.decode(bytes);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('파일 읽기 오류: $e')),
          );
          return;
        }

        if (contents.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('파일이 비어 있습니다.')),
          );
          return;
        }

        // 다음 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExamBlankerScreen(initialText: contents),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('파일 선택이 취소되었습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 처리 중 오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "ExamBlanker",
            style: GoogleFonts.roboto(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 80),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 파일 선택 버튼
              Container(
                padding: EdgeInsets.all(20),
                child: IconButton(
                  onPressed: () => _pickFileAndNavigate(context), // 파일 선택 및 다음 화면 이동
                  icon: Icon(Icons.file_copy),
                  iconSize: 60,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[700],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
              ),
              SizedBox(width: 50),
              // 다음 페이지로 이동 버튼
              Container(
                padding: EdgeInsets.all(20),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExamBlankerScreen(initialText: ""),
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_forward_ios),
                  iconSize: 60,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[700],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
