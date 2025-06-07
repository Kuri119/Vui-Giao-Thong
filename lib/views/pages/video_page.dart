import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testing/views/pages/home_page.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Thực Tế',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF7BDFF2),
      ),
      home: CategoryListPage(),
    );
  }
}
///////////////////////////////1 hiển thih danh sách danh mục
class CategoryListPage extends StatelessWidget {
  CategoryListPage({super.key});

  final supabase = Supabase.instance.client;// truy cập đối tượng supabase hiện tại

  Future<List<Map<String, dynamic>>> fetchCategories() async {// fetchCategories để truy vấn CSDL
    final response = await supabase
        .from('danh_muc_video')
        .select('*')
        .limit(25);
    return List<Map<String, dynamic>>.from(response);// chuyển dữ liệu thành list chứa các danh mục
  }
// start: hàm điều hướng đến trang video danh mục khi người dùng chọn
  void navigateToVideoList(BuildContext context, dynamic categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoListPage(categoryId: categoryId.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // strart: giao diện thanh tiêu đề với nút quay lại và icon sưu tập video
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 9, 5, 5),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return HomePage();
                }
              ),
            );
          },
        ),
        title: const Text(
          'Video thực tế',
          style: TextStyle(color: Color.fromARGB(255, 29, 10, 10)),
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 9, 5, 5)),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.video_collection,
              color: Color.fromARGB(255, 9, 5, 5),
              size: 28,
            ),
            onPressed: () {},
          ),
        ],
      ),//end
      body: Stack(
        children: [
          const WaveBackground(),
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [],
                  ),
                ),
              ),
              // start lấy dữ liệu từ supabase để hiển thị danh mục video
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF7BDFF2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchCategories(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Lỗi tải dữ liệu'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('Không có danh mục nào'),
                        );
                      } else {
                        final categories = snapshot.data!;
                        //start: giao diện dạng Gird hiển thị danh mục
                        return GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final colorHex = category['color'] ?? '#2196F3';
                            final color = Color(
                              int.parse('0xFF${colorHex.substring(1)}'),
                            );

                            return CategoryButton(
                              label: category['name'] ?? 'Danh mục',
                              color: color,
                              onTap:
                              //khi ấn chọn, gọi navigateToVideoList() điều hướng sang trang các video
                                  () => navigateToVideoList(
                                    context,
                                    category['id'],
                                  ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WaveBackground extends StatelessWidget {
  const WaveBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7BDFF2), Color(0xFF7BDFF2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: CustomPaint(painter: WavePainter()),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.7,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CategoryButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const CategoryButton({
    required this.label,
    required this.color,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
///////////////////////////// danh sách video
class VideoListPage extends StatelessWidget {
  final String categoryId;
  VideoListPage({required this.categoryId, super.key});

  final supabase = Supabase.instance.client;
// start: lấy video theo category_id
  Future<List<Map<String, dynamic>>> fetchVideosByCategory() async {
    final response = await supabase
        .from('videos')
        .select('*')
        .eq('category_id', categoryId)
        .limit(25);
    return List<Map<String, dynamic>>.from(response);
  }

  void navigateToVideoPlayer(BuildContext context, String videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoId: videoId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Video'),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_collection),
            onPressed: () {
              // TODO: Xử lý khi nhấn icon
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchVideosByCategory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Lỗi tải video'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có video nào'));
          } else {
            final videos = snapshot.data!;
            // danh sách video dạng listview
            return ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                final videoId = video['youtube_id'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.play_circle_fill,
                      size: 50,
                      color: Colors.blueAccent,
                    ),
                    title: Text(video['title'] ?? 'Không tiêu đề'),
                    onTap: () {
                      if (videoId.isNotEmpty) {
                        // gọi navigateToVideoPlayer => điều hướng sang trang xem video
                        navigateToVideoPlayer(context, videoId);
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
/////////////////////////////////////// 3 trang phát video
class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({super.key, required this.videoId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // khởi tạo trình phát youtube
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showVideoAnnotations: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xem Video')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // start: hiển thị màn hình phát video
          YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Video hướng dẫn an toàn giao thông thực tế || 2025 || ATGT',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Arial',
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 8,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Container cho nút Thích và Không Thích
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Nền màu xám nhẹ
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 4,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Nút Thích
                      IconButton(
                        icon: const Icon(Icons.thumb_up_alt_outlined),
                        onPressed: () {
                          // Xử lý nút Thích
                        },
                      ),
                      const VerticalDivider(
                        color: Colors.grey, // Đường phân cách
                        width: 15,
                        thickness: 3,
                      ),
                      // Nút Không Thích
                      IconButton(
                        icon: const Icon(Icons.thumb_down_alt_outlined),
                        onPressed: () {
                          // Xử lý nút Không Thích
                        },
                      ),
                    ],
                  ),
                ),

                // Nền xám riêng cho nút Dấu ba chấm
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Nền xám nhẹ
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Xử lý dấu ba chấm
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // mô tả thêm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 10,
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: const Text(
                'Trong “Chặng Đường Xanh” ngày hôm nay chúng ta sẽ cùng MC Sơn Lâm gặp gỡ, trò chuyện cùng chị Nguyễn Hoàng Thảo – Một trong 3 người phụ nữ Châu Á truyền cảm hứng về sống xanh được BBC vinh danh. Đồng thời, cũng là người sáng lập “Go Eco Hà Nội” - cửa hàng bán các sản phẩm “zero waste” đầu tiên ở Hà Nội cũng như nhiều dự án “xanh” có hàng ngàn lượt theo dõi..\n'
                'Bạn sẽ học được các kỹ năng lái xe an toàn. '
                'Cảm ơn bạn rất nhiều',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}