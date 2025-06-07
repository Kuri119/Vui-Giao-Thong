import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testing/auth/auth_services.dart';
import 'package:testing/views/pages/final_video_page.dart';

class ManChoiFinishPage extends StatefulWidget {

  const ManChoiFinishPage({super.key, required this.man});

  final int man;

  @override
  State<ManChoiFinishPage> createState() => _ManChoiFinishPageState();
}

class _ManChoiFinishPageState extends State<ManChoiFinishPage> {

  int soCauDung = 0;
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

  //Load lại trang để update thông tin thành tích màn chơi của người dùng
  Future<void> loadRecord() async {
    final record = await fetchRecord();
    setState(() {
      soCauDung = record?['so_cau_dung'];
    });
  }

  //Lấy thông tin thành tích màn chơi hiện tại của người dùng hiện tại
  Future<Map<String,dynamic>?> fetchRecord() async {
    final supabase = Supabase.instance.client;
    final idUser = AuthServices().getCurrentUserId();
    final data = await supabase.from('tbl_man_choi').select('*').eq('id_user', idUser!).eq('id_man_choi',widget.man).maybeSingle();

    print(data);
    return data;
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

          // Widget hoàn thành màn chơi
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
                        child: Image.asset('assets/images/man_choi_cuoi.png'),
                      ),
                      Text(
                        'Số câu đúng: $soCauDung/10 câu',
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
                                      return FinalVideoPage();
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