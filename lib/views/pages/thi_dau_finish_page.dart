import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testing/auth/auth_services.dart';
import 'package:testing/views/pages/bang_xep_hang_page.dart';

class ThiDauFinishPage extends StatefulWidget {
  const ThiDauFinishPage({super.key});

  @override
  State<ThiDauFinishPage> createState() => _ThiDauFinishPageState();
}

class _ThiDauFinishPageState extends State<ThiDauFinishPage> {

  int soCauDung = 0;
  int thoiGian = 0;
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await loadRecord();
    setState(() {
      _isLoading = false;
    });
  }

  //Load lại trang để update thông tin bảng xếp hạng người dùng
  Future<void> loadRecord() async {
    final record = await fetchRecord();
    setState(() {
      soCauDung = record?['so_cau_dung'];
      thoiGian = record?['thoi_gian'];
    });
  }


  //Lấy thông tin bảng xếp hạng của người dùng hiện tại
  Future<Map<String,dynamic>?> fetchRecord() async {
    final supabase = Supabase.instance.client;
    final idUser = AuthServices().getCurrentUserId();
    final data = await supabase.from('tbl_bang_xep_hang').select('*').eq('id_user', idUser!).maybeSingle();

    print(data);
    return data;
  }

  //Hiển thị tổng số giây sang dạng mm:ss
  String _formatTime(int totalSecond) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits((totalSecond % 3600)  ~/ 60);
    String seconds = twoDigits(totalSecond % 60);
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
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
                        child: Image.asset('assets/images/genrang_finish_page.png'),
                      ),
                      Text(
                        'Số câu đúng: $soCauDung/25 câu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      Text(
                        'Thời gian: ${_formatTime(thoiGian)}',
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
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return BangXepHangPage();
                                    },
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  'Tiếp tục',
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