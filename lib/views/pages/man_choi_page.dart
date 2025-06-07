import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testing/auth/auth_services.dart';
import 'package:testing/views/pages/man_choi_question_page.dart';

class ManChoiPage extends StatefulWidget {
  const ManChoiPage({super.key});

  @override
  State<ManChoiPage> createState() => _ManChoiPageState();
}

class _ManChoiPageState extends State<ManChoiPage> {

  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await loadManChoiRecord();
    setState(() {
      _isLoading = false;
    });
  }

  List<Map<String,dynamic>> manChoiRecord = [];

  Future<List<Map<String,dynamic>>> fetchManChoi() async {
    final supabase = Supabase.instance. client;
    String? currentUserId = AuthServices().getCurrentUserId();

    final data = await supabase.from('tbl_man_choi').select('*').eq('id_user',currentUserId!);

    data.sort((m1,m2) {
      return m1['id_man_choi'].compareTo(m2['id_man_choi']);
    });

    return data;
  }

  Future<void> loadManChoiRecord() async {
    final tempManChoiRecord = await fetchManChoi();
    final supabase = Supabase.instance.client;
    String? currentUserId = AuthServices().getCurrentUserId();

    print(tempManChoiRecord);

    if(tempManChoiRecord.isEmpty)
    {
      for(int i = 1; i<=9; i++) {
        tempManChoiRecord.add({
          'id_user': currentUserId,
          'id_man_choi': i,
          'so_cau_dung': 0,
        });

        await supabase.from('tbl_man_choi').insert({
          'id_user': currentUserId,
          'id_man_choi': i,
          'so_cau_dung': 0,
        });
      }
    }

    setState(() {
      manChoiRecord = tempManChoiRecord;
    });
  }

  Widget finished(int index, Map<String,dynamic> record) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ManChoiQuestionPage(man: index);
            },
          ),
        );
      },
      child: Column(
        children: [
          Container(
            height: 30.0,
            width: 30.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Color(0xFF00FF75),
            ),
          ),
          SizedBox(height: 10.0),
          Row(
            children: [
              Text(
                '${record['so_cau_dung']}/10',
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10.0),
              SizedBox(
                height: 10.0,
                width: 10.0,
                child: Image.asset('assets/images/star-fill.png')
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/Man_choi.png',
                fit: BoxFit.cover,
              ),
            ),
      
            //Thành tích màn chơi
            Positioned(
              bottom: 54.0,
              left: 70.0,
              child: finished(1, manChoiRecord[0]),
            ),

            Positioned(
              bottom: 110.0,
              right: 67.0,
              child: finished(2, manChoiRecord[1]),
            ),

            Positioned(
              bottom: 175.0,
              left: 110.0,
              child: finished(3, manChoiRecord[2]),
            ),

            Positioned(
              bottom: 210.0,
              right: 67.0,
              child: finished(4, manChoiRecord[3]),
            ),

            Positioned(
              bottom: 329.0,
              left: 33.0,
              child: finished(5, manChoiRecord[4]),
            ),

            Positioned(
              top: 400.0,
              left: 170.0,
              child: finished(6, manChoiRecord[5]),
            ),

            Positioned(
              top: 255.0,
              left: 95.0,
              child: finished(7, manChoiRecord[6]),
            ),

            Positioned(
              top: 310.0,
              right: 90.0,
              child: finished(8, manChoiRecord[7]),
            ),

            Positioned(
              top: 140.0,
              right: 50.0,
              child: finished(9, manChoiRecord[8]),
            ),
          ],
        ),
    );
  }
}