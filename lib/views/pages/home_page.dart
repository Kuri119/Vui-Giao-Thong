import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testing/auth/auth_services.dart';
import 'package:testing/views/pages/bang_xep_hang_page.dart';
import 'package:testing/views/pages/man_choi_page.dart';
import 'package:testing/views/pages/notification_app.dart';
import 'package:testing/views/pages/profile_page.dart';
import 'package:testing/views/pages/thi_dau_page.dart';
import 'package:url_launcher/url_launcher.dart';

List<String> imagePaths = [];
bool isLoading = true;
List<String> imageNames = [];
List<String> imageLinks = [];
List<String> leaderImg = [];
List<Map<String,dynamic>> listUserRecord = [];

late List<Widget> _pages;

int _activePage = 0;

final PageController _pageController = PageController(initialPage: 0);

Timer? _timer; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //Lấy tiêu đề trong cơ sở dữ liệu
  Future<List<String>> fetchTinTucTieuDe() async {
    try {
      final supabase = Supabase.instance.client;

      final data = await supabase.from('tbl_tin_tuc').select('tieu_de');

      return data.map((row) => row['tieu_de'] as String).toList();
    }
    catch (e) {
      print('Lỗi này: $e');
      return [];
    }
  }

  //Chuyền list tiêu đề vào list imageNames
  Future<void> loadTintucTieuDe() async {
    final tieude = await fetchTinTucTieuDe();
    setState(() {
      imageNames = tieude;
    });
  }

  //Lấy ảnh Urls từ cơ sở dữ liệu
  Future<List<String>> fetchTinTucImageUrls() async {
    try {
      final supabase = Supabase.instance.client;

      final data = await supabase.from('tbl_tin_tuc').select('link_anh');

      return data.map((row) => row['link_anh'] as String).toList();
    } catch (e) {
      print('Lỗi này: $e');
      return [];
    }
  }

  //Đưa Urls ảnh đã lấy vào trong list imagePath
  Future<void> loadTinTucImages() async {
    final  urls = await fetchTinTucImageUrls();
    print('Kết quả truy vấn: $urls');
    setState(() {
      imagePaths = urls;
      _pages = List.generate(
        imagePaths.length,
        (index) => ImagePlaceholder(imagePath: imagePaths[index])
      );
    });
  }

  //Lấy link báo trong cơ sở dữ liệu
  Future<List<String>> fetchTinTucLink() async {
    try {
      final supabase = Supabase.instance.client;

      final data = await supabase.from('tbl_tin_tuc').select('link_bao');

      return data.map((row) => row['link_bao'] as String).toList();
    }
    catch (e) {
      print('Lỗi này: $e');
      return [];
    }
  }

  //Chuyền link báo vào list imageLinks
  Future<void> loadTintucLink() async {
    final links = await fetchTinTucLink();
    setState(() {
      imageLinks = links;
    });
  }

  void startTimer() {
    _timer = Timer.periodic(
      Duration(seconds: 3), (timer) {
        if(_pageController.page == imagePaths.length-1) //Checks if it's on the last image
        {
          _pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
        else
        {
          _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
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
    int index = 0;
    List<Map<String, dynamic>> tempUserRecord = [];
    List<String> tempAvatarUrl = [];

    for(int i=bangXepHang.length-1; i>=0; i--)
    {
      if(index == 3)
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
    print(tempAvatarUrl);
    print(tempUserRecord);

    setState(() {
      listUserRecord = tempUserRecord;
      leaderImg = tempAvatarUrl;
    });
  }

  String avatarCurrentUser = '';

  Future<void> loadCurrentUserAvatar() async {
    final avatarUrl = await fetchAvatarUrl();
    final currentIdUser = AuthServices().getCurrentUserId();

    for(Map<String,dynamic> user in avatarUrl) {
      if(user['id_user'] == currentIdUser)
      {
        avatarCurrentUser = user['img_url'];
      }
    }
  }

  Future<void> loadData() async {
    await loadBangXepHang();
    await loadTinTucImages();
    await loadCurrentUserAvatar();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    loadTintucTieuDe();
    loadTintucLink();
    startTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Vui giao thông",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
            color: Colors.lightBlueAccent,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return NotificationApp();
                  }
                ),
              );
            },
            icon: Icon(
              Icons.notifications,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ProfilePage();
                  },
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                width: 55.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: CachedNetworkImage(
                    imageUrl: avatarCurrentUser,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_img.png',
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [

                SizedBox(height: 20.0),

                Stack(
                  children: [
                    // Hiển thị ảnh của bảng tin
                    SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height/4,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: imagePaths.length,
                          onPageChanged: (value) {
                            setState(() {
                              _activePage = value;
                            });
                          },
                          itemBuilder: (context, index) {
                            return _pages[index];
                          },
                        ),
                    ),
                    //code for page indicator
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:List<Widget>.generate(
                            _pages.length, 
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: CircleAvatar(
                                radius: 4,
                                backgroundColor: _activePage == index? Colors.white: Colors.grey,
                              ),
                          ),),
                        ),
                      ),
                    ),
            
                    //Tiêu đề tin tức
                    Positioned(
                      bottom: 20.0,
                      left: 0.0,
                      right: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: () async {
                            final Uri url = Uri.parse(imageLinks[_activePage]);
                            launchUrl(url);
                          },
                          child: Text(
                            imageNames[_activePage],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          
                SizedBox(height: 20.0,),
          
                Row(
                  children: [
                    //Thi đấu button
                    Expanded (
                      child: Material(
                        borderRadius: BorderRadius.circular(30.0),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF0000), Color(0xFFFFCC00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ThiDauPage();
                                  },
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Image.asset('assets/images/Thi_dau_img.png'),
                                ),
                                Expanded(
                                  child: Text(
                                    'Thi Đấu',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 4.0,
                                          color: Colors.black45,
                                          offset: Offset(1.0, 1.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 10.0),
          
                    //Giải trí button
                    Expanded (
                      child: Material(
                        borderRadius: BorderRadius.circular(30.0),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF00FF1E), Color(0xFFEFF7F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ManChoiPage();
                                  },
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Image.asset('assets/images/Giai_tri_img.png'),
                                ),
                                Expanded(
                                  child: Text(
                                    'Giải trí',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 4.0,
                                          color: Colors.black45,
                                          offset: Offset(1.0, 1.0),
                                        ),
                                      ],
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
          
                SizedBox(height: 10.0),
          
                //Tình hình giao thông hiện tại button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30.0),
                    onTap: () {
                      // Đến tình hình giao thông page
                    },
                    child: Ink(
                      height: 80.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        image: DecorationImage(
                          image: AssetImage('assets/images/Giao_thong_btn.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Tình hình giao thông hiện tại',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black45,
                                offset: Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10.0,),
                //Bảng xếp hạng
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Text(
                        'Bảng ',
                        style: TextStyle(
                          color: Color(0XFFF2B5D4),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'xếp hạng',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10.0,),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return BangXepHangPage();
                              },
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: Image.asset('assets/images/leaderboard_button.png'),
                        ),
                      ),
                    ],
                  ),
                ),

                //Cột ở bảng xếp hạng
                Stack(
                  children: [
                    SizedBox(
                      width: 250.0,
                      height: 230.0,
                      child: Image.asset('assets/images/Leader_board_bar.png'),
                    ),
                    //Avatar người đứng nhất
                    if(listUserRecord.isNotEmpty)
                    Positioned(
                      right: 97.0,
                      top: 10.0,
                      child: SizedBox(
                        width: 55.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: CachedNetworkImage(
                            imageUrl: leaderImg[0],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    //Avatar người đứng hai
                    if(listUserRecord.length > 1)
                    Positioned(
                      left: 4.0,
                      top: 40.0,
                      child: SizedBox(
                        width: 55.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: CachedNetworkImage(
                            imageUrl: leaderImg[1],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    //Avatar người đứng ba
                    if(listUserRecord.length > 2)
                    Positioned(
                      right: 0.0,
                      top: 70.0,
                      child: SizedBox(
                        width: 55.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: CachedNetworkImage(
                            imageUrl: leaderImg[2],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImagePlaceholder extends StatelessWidget {
  final String? imagePath;
  const ImagePlaceholder({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: CachedNetworkImage(
        imageUrl: imagePath!,
        fit: BoxFit.cover,
      ),
    );
  }
}