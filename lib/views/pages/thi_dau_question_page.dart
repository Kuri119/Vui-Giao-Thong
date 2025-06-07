import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testing/auth/auth_services.dart';
import 'package:testing/views/pages/thi_dau_finish_page.dart';

class ThiDauQuestionPage extends StatefulWidget {
  const ThiDauQuestionPage({super.key});

  @override
  State<ThiDauQuestionPage> createState() => _ThiDauQuestionPageState();
}

class _ThiDauQuestionPageState extends State<ThiDauQuestionPage> {
  // Biến kết quả
  int soCauDung = 0;
  
  // Biến sử dụng cho bộ đếm
  int totalSecond = 1140; //19 phút = 1140 s
  Timer? timer;

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
    startTimer();
  }

  Future<void> fetchQuestions() async {
    final supabase = Supabase.instance.client;
    List<int> idTaken = [];

    while (idTaken.length < 25) {
      var randomId = Random().nextInt(90) + 1;
      if (!idTaken.contains(randomId)) {
        final data = await supabase
            .from('tbl_cau_hoi')
            .select('*')
            .eq('id', randomId);

        if (!idTaken.contains(randomId)) {
          questionsList.add(data[0]);
          idTaken.add(randomId);
        }
      }
    }
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

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        if(totalSecond == 0)
        {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ThiDauFinishPage();
              }
            ),
          );
        }
        else {
          totalSecond--;
        }
      });
    });
  }

  //Hiển thị tổng số giây sang dạng mm:ss
  String _formatTime(int totalSecond) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits((totalSecond % 3600)  ~/ 60);
    String seconds = twoDigits(totalSecond % 60);
    return "$minutes:$seconds";
  }

  //Tính số giây còn lại sau khi hoàn thành
  int _remainingSeconds(int totalSecond) {
    int result = 1140 - totalSecond;
    return result;
  }

  //Hàm hoàn thành thi đấu thực hiện ghi lên bảng xếp hạng
  Future <void> finish(int index) async {
    if (index == 25) {
      final supabase = Supabase.instance.client;
      var idUser = AuthServices().getCurrentUserId();
      final data = await supabase.from('tbl_bang_xep_hang').select('*').eq('id_user', idUser!).maybeSingle();
      if(data != null)
      {
        await supabase.from('tbl_bang_xep_hang').update({
          'so_cau_dung':soCauDung,
          'thoi_gian': _remainingSeconds(totalSecond),
        }).eq('id_user',idUser);
      }
      else
      {
        try {
        final response = await supabase.from('tbl_bang_xep_hang').insert({
          'id_user': idUser,
          'so_cau_dung': soCauDung,
          'thoi_gian': _remainingSeconds(totalSecond),
        });
        print('Insert thành công: $response');
      }
      catch (e) {
        print('Lỗi khi insert: $e');
      }
      }
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Câu: $index",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                          width: 100.0,
                          child: Row(
                            children: [
                              Image.asset("assets/images/timer_img.png"),
                              Text(
                                _formatTime(totalSecond),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                            if (index < 25) {
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
                                    return ThiDauFinishPage();
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
                            if (index < 25) {
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
                                    return ThiDauFinishPage();
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
                            if (index < 25) {
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
                                    return ThiDauFinishPage();
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
                            if (index < 25) {
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
                                    return ThiDauFinishPage();
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