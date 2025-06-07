import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testing/auth/auth_services.dart';
import 'package:testing/views/pages/man_choi_finish_page.dart';

class ManChoiQuestionPage extends StatefulWidget {

  const ManChoiQuestionPage({super.key, required this.man});

  final int man;

  @override
  State<ManChoiQuestionPage> createState() => _ManChoiQuestionPageState();
}

class _ManChoiQuestionPageState extends State<ManChoiQuestionPage> {

  // Biến kết quả
  int soCauDung = 0;

  // Biến hiển thị câu hỏi
  List<dynamic> questionsList = [];
  int index = 0;
  String deBai = "";
  String dapanA = "";
  String dapanB = "";
  String dapanC = "";
  String dapanD = "";
  String dapan = "";
  String linkAnh = "";
  int id = 0;

  @override
  void initState() {
    super.initState();
    fetchQuestions().then((_) {
      loadQuestion(index);
      index += 1;
    });
  }

  Future<void> fetchQuestions() async {
    final supabase = Supabase.instance.client;

    final data = await supabase.from('tbl_cau_hoi').select('*').eq('so_de',widget.man);
    questionsList.addAll(data);
    print(questionsList);
  }

  void loadQuestion(int index) {
    final question = questionsList[index];

    setState(() {
      deBai = question['de_bai'] ?? '';
      dapanA = question['dapan_A'] ?? '';
      dapanB = question['dapan_B'] ?? '';
      dapanC = question['dapan_C'] ?? '';
      dapanD = question['dapan_D'] ?? '';
      dapan = question['cau_tra_loi'] ?? '';
      linkAnh = question['link_anh'] ?? '';
      id = question['id'] ?? 0;
    });

    print('Câu $index - ID: $id');
  }

  //Hàm hoàn thành thi đấu thực hiện ghi lên bảng xếp hạng
  Future <void> finish(int index) async {
    if (index == 10) {
      final supabase = Supabase.instance.client;
      var idUser = AuthServices().getCurrentUserId();
      // final data = await supabase.from('tbl_man_choi').select('*').eq('id_user', idUser!).eq('id_man_choi', widget.index).maybeSingle();
      
      await supabase.from('tbl_man_choi').update(
        {
          'so_cau_dung':soCauDung,
        }).eq('id_user', idUser!).eq('id_man_choi',widget.man);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_img3.png',
              fit: BoxFit.cover,
            ),
          ),

          Column(
            children: [
              SizedBox(height: 70.0),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Câu: $index",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),

                    SizedBox(height: 10.0),

                    // Hiển thị ảnh
                    if (linkAnh != '')
                      ClipRRect (
                        borderRadius: BorderRadius.circular(25.0),
                        child: CachedNetworkImage(
                          imageUrl: linkAnh,
                          fit: BoxFit.cover,
                        ),
                      ),

                    SizedBox(height: 10.0),

                    // Hiện đề bài
                    Text(
                      deBai,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10.0),

                    // Câu hỏi
                    if (dapanA != '')
                    Material(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () async {
                            if (index < 10) {
                              if(dapan == 'A')
                              {
                                soCauDung++;
                              }
                              loadQuestion(index);
                              index += 1;
                            }
                            else {
                              await finish(index);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ManChoiFinishPage(man: widget.man);
                                  },
                                ),
                              );
                            }
                          },
                          child: Row(
                            children: [
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(20.0),
                                  margin: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40.0),
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    "A",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  dapanA,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 20,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.0),

                    if (dapanB != '')
                    Material(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () async {
                            if (index < 10) {
                              if(dapan == 'B')
                              {
                                soCauDung++;
                              }
                              loadQuestion(index);
                              index += 1;
                            }
                            else {
                              await finish(index);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ManChoiFinishPage(man: widget.man);
                                  },
                                ),
                              );
                            }
                          },
                          child: Row(
                            children: [
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(20.0),
                                  margin: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40.0),
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    "B",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  dapanB,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 20,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.0),

                    if (dapanC != '')
                    Material(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () async {
                            if (index < 10) {
                              if(dapan == 'C')
                              {
                                soCauDung++;
                              }
                              loadQuestion(index);
                              index += 1;
                            }
                            else {
                              await finish(index);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ManChoiFinishPage(man: widget.man);
                                  },
                                ),
                              );
                            }
                          },
                          child: Row(
                            children: [
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(20.0),
                                  margin: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40.0),
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    "C",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  dapanC,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 20,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.0),

                    if (dapanD != '')
                    Material(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () async {
                            if (index < 10) {
                              if(dapan == 'D')
                              {
                                soCauDung++;
                              }
                              loadQuestion(index);
                              index += 1;
                            }
                            else {
                              await finish(index);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ManChoiFinishPage(man: widget.man);
                                  },
                                ),
                              );
                            }
                          },
                          child: Row(
                            children: [
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(20.0),
                                  margin: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40.0),
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    "D",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  dapanD,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 20,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}