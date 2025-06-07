import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testing/auth/auth_services.dart';

class BangXepHangPage extends StatefulWidget {
  const BangXepHangPage({super.key});

  @override
  State<BangXepHangPage> createState() => _BangXepHangPageState();
}

class _BangXepHangPageState extends State<BangXepHangPage> {

  Map<String,dynamic> curentUserRecord = {};
  List<Map<String,dynamic>> listUserRecord = [];
  List<String> listAvatarUrl = [];
  int vitriUser = 0;

  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await loadBangXepHang();
    setState(() {
      _isLoading = false;
    });
  }

  Future<List<Map<String,dynamic>>> fetchBangXepHang() async {
    final supabase = Supabase.instance.client;
    final record = await supabase.from('tbl_bang_xep_hang').select('*');

    record.sort((m1, m2) {
      var r = m1["so_cau_dung"].compareTo(m2["so_cau_dung"]);
      if (r != 0) return r;
      return m2["thoi_gian"].compareTo(m1["thoi_gian"]);
    });

    return record;
  }
  
  Future<List<Map<String,dynamic>>> fetchAvatarUrl() async {
    final supabase = Supabase.instance.client;
    final avatarUrl = await supabase.from('tbl_nguoi_dung').select('id_user,img_url');

    return avatarUrl;
  }

  Future<void> loadBangXepHang() async{
    final bangXepHang = await fetchBangXepHang();
    final avatarUrl = await fetchAvatarUrl();
    final currentIdUser = AuthServices().getCurrentUserId();
    int index = 0;
    int tempVitri = 0;
    List<Map<String, dynamic>> tempUserRecord = [];
    List<String> tempAvatarUrl = [];
    Map<String,dynamic> tempCurentUserRecord = {};

    for(int i=bangXepHang.length-1; i>=0; i--)
    {
      if(index == 5)
      {
        break;
      }
      tempUserRecord.add(bangXepHang[i]);
      for(Map<String,dynamic> url in avatarUrl) {
        if(url['id_user'] == bangXepHang[i]['id_user']) {
          tempAvatarUrl.add(url['img_url']);
        }
      }
      index++;
    }

    if(tempCurentUserRecord.isEmpty) {
      for(Map<String,dynamic> url in avatarUrl) {
        if(url['id_user'] == currentIdUser) {
          tempAvatarUrl.add(url['img_url']);
        }
      }
    }

    // Tìm vị trí user hiện tại
    for (Map<String, dynamic> userRecord in tempUserRecord) {
      if (userRecord['id_user'] == currentIdUser) {
        tempCurentUserRecord.addAll(userRecord);
        break;
      }
      tempVitri++;
    }

    print(tempCurentUserRecord);
    print(tempAvatarUrl);
    print(tempUserRecord);
    print(tempVitri);

    setState(() {
      vitriUser = tempVitri;
      listUserRecord = tempUserRecord;
      listAvatarUrl = tempAvatarUrl;
      curentUserRecord = tempCurentUserRecord;
      _isLoading = false;
    });
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
              'assets/images/bang_xep_hang.png',
              fit: BoxFit.cover,
            ),
          ),
      
          //Vị trí nhất bảng
          if(listUserRecord.isNotEmpty)
            Positioned(
              right: 170.0,
              top: 160.0,
              child: SizedBox(
                width: 55.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: CachedNetworkImage(
                    imageUrl: listAvatarUrl[0],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
      
          //Vị trí nhì bảng
          if(listUserRecord.length > 1)
            Positioned(
              right: 280.0,
              top: 300.0,
              child: SizedBox(
                width: 55.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: CachedNetworkImage(
                    imageUrl: listAvatarUrl[1],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
      
          //Vị trí ba bảng
          if(listUserRecord.length > 2)
            Positioned(
              right: 52.0,
              top: 300.0,
              child: SizedBox(
                width: 55.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: CachedNetworkImage(
                    imageUrl: listAvatarUrl[2],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
      
          //Danh sách chi tiết bảng xếp hạng (Thành tích bản thân)
          if(curentUserRecord.isNotEmpty)
          Positioned(
            top: 480.0,
            left: 50.0,
            child: SizedBox(
              height: 50.0,
              width: 300.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "# ${vitriUser + 1}",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(
                    width: 55.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: CachedNetworkImage(
                        imageUrl: listAvatarUrl[vitriUser],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    "${listUserRecord[vitriUser]['so_cau_dung']}/25",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
      
                  Text(
                    _formatTime(listUserRecord[vitriUser]['thoi_gian']),
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
      
          //Danh sách chi tiết bảng xếp hạng (Top 5)
          if(listUserRecord.isNotEmpty)
          Positioned(
            top: 580.0,
            left: 50.0,
            child: SizedBox(
              height: 50.0,
              width: 300.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "# 1",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(
                    width: 55.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: CachedNetworkImage(
                        imageUrl: listAvatarUrl[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    "${listUserRecord[0]['so_cau_dung']}/25",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
      
                  Text(
                    _formatTime(listUserRecord[0]['thoi_gian']),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
      
          if(listUserRecord.length > 1)
          Positioned(
            top: 650.0,
            left: 50.0,
            child: SizedBox(
              height: 50.0,
              width: 300.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "# 2",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(
                    width: 55.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: CachedNetworkImage(
                        imageUrl: listAvatarUrl[1],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    "${listUserRecord[1]['so_cau_dung']}/25",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
      
                  Text(
                    _formatTime(listUserRecord[1]['thoi_gian']),
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
      
          if(listUserRecord.length > 2)
          Positioned(
            top: 720.0,
            left: 50.0,
            child: SizedBox(
              height: 50.0,
              width: 300.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "# 3",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(
                    width: 55.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: CachedNetworkImage(
                        imageUrl: listAvatarUrl[2],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    "${listUserRecord[2]['so_cau_dung']}/25",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
      
                  Text(
                    _formatTime(listUserRecord[2]['thoi_gian']),
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
      
          if(listUserRecord.length > 3)
            Positioned(
              top: 790.0,
              left: 50.0,
              child: SizedBox(
                height: 50.0,
                width: 300.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "# 4",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(
                      width: 55.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: CachedNetworkImage(
                          imageUrl: listAvatarUrl[3],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text(
                      "${listUserRecord[3]['so_cau_dung']}/25",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
      
                    Text(
                      _formatTime(listUserRecord[3]['thoi_gian']),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}