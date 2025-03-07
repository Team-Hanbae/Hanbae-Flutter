import 'package:flutter/material.dart';

class CustomJangdanListScreen extends StatelessWidget {
  CustomJangdanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),

      appBar: AppBar(
        //home에서 Navigator.push(); 넣으면 자동으로 뒤로가기 버튼 생김
        title: Text('내가 저장한 장단', style: TextStyle(fontSize: 17)),
        centerTitle: true,
        backgroundColor: Color(0xFF1F1F1F),
        actions: [
          IconButton(
            icon: Icon(Icons.add), // 검색 아이콘 추가
            onPressed: () {
              print('검색 버튼 클릭됨');
            },
          ),
          TextButton(
            onPressed: () {
              print('TextButton 클릭됨!');
            },
            child: Text('편집'),
          )
        ]
      ),
    );
  }
}
