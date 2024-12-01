import 'package:flutter/material.dart';
import 'dart:math';

class BlankedTextContainer extends StatelessWidget {
  final List<Map<String, dynamic>> blankedTextWidgets;

  const BlankedTextContainer({
    required this.blankedTextWidgets,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: blankedTextWidgets.isEmpty
          ? const Center(child: Text('랜덤 빈칸을 생성하세요!'))
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
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: '',
                          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        ),
                        onChanged: (value) {
                          item['userAnswer'] = value.trim();
                        },
                      ),
                    );
                  } else {
                    return Text(
                      item['word'],
                      style: const TextStyle(fontSize: 16),
                    );
                  }
                }).toList(),
              ),
            ),
    );
  }
}
