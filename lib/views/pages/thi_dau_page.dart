import 'package:flutter/material.dart';
import 'package:testing/views/pages/thi_dau_question_page.dart';

class ThiDauPage extends StatelessWidget {
  const ThiDauPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Hình nền
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_img2.png',
              fit: BoxFit.cover,
            ),
          ),

          // Widget trước khi thi đấu
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 400.0,
                width: 300.0,
                color: Color(0xFFD9D9D9),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100.0,
                        child: Image.asset('assets/images/thidau_gong_img.png'),
                      ),
                      Text(
                        'Thời gian tối đa: 19 phút',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      Text(
                        'Tổng số câu: 25 câu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                  
                      SizedBox(height: 10.0),
                      
                      SizedBox(
                        height: 80.0,
                        width: 200.0,
                        child: Material(
                          borderRadius: BorderRadius.circular(30.0),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ThiDauQuestionPage();
                                    },
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  'Bắt đầu',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
