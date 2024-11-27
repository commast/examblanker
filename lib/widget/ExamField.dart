import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Examfield extends StatefulWidget {
  
  const Examfield({required this.text,required this.bgColor,required this.controller,super.key});
  final controller;
  final bgColor;
  final text;
  @override
  State<Examfield> createState() => _ExamfieldState();
}

class _ExamfieldState extends State<Examfield> {
  TextEditingController leftcontroller = TextEditingController();
  TextEditingController rightcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) 
  {

     void _saveText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedText', leftcontroller.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('저장 완료')),
    );

    void _loadText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedText = prefs.getString('savedText');
    if (savedText != null) {
      leftcontroller.text = savedText;
      rightcontroller.clear(); // 오른쪽 텍스트 필드는 지우기
      setState(() {});
    }
  }
  }
    return  TextField(
                    controller: widget.controller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: widget.bgColor,
                      border: OutlineInputBorder(),
                      labelText: widget.text,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              widget.controller.clear(); // 텍스트 필드 내용 지우기
                            },
                          ),
                        ],
                      ),
                    ),
                    maxLines: 25,
                  );
  }
}


