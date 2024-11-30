import 'package:examblanker/screens/examBlankerScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts 추가

class MyStartPage extends StatelessWidget {
  const MyStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
        children: [
          Container(
            child: Text(
              "ExamBlanker",
              style: GoogleFonts.roboto( // 모던한 폰트 적용
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0, // 글자 간격 추가
              ),
            ),
          ),
          SizedBox(height: 80),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Icon(
                  Icons.file_copy,
                  size: 60,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[700],
                  borderRadius: BorderRadius.circular(15), // 더 둥근 모서리
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5), // 그림자 위치
                    )
                  ],
                ),
              ),
              SizedBox(width: 50),
              Container(
                padding: EdgeInsets.all(20),
                child: IconButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExamBlankerScreen(),
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
