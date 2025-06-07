import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Thư viện để kết nối và truy xuất dữ liệu từ Supabase
import 'package:youtube_player_iframe/youtube_player_iframe.dart'; // Thư viện để nhúng và điều khiển video YouTube

// Widget chính
class FinalVideoPage extends StatefulWidget {
  const FinalVideoPage({super.key});

  @override
  State<FinalVideoPage> createState() => _FinalVideoPageState();
}

class _FinalVideoPageState extends State<FinalVideoPage> {
  final supabase =
      Supabase.instance.client; // Lấy client Supabase để truy vấn dữ liệu
  String title = '';
  String description = '';
  String youtubeId = '';
  bool isLoading = true; // Trạng thái đang tải
  bool isError = false; // Trạng thái lỗi
  String errorMessage = '';
  YoutubePlayerController?
  _controller; // Controller để điều khiển video YouTube

  @override
  void initState() {
    super.initState();
    fetchVideo(); // Gọi hàm để lấy dữ liệu video từ Supabase khi khởi động
  }

  // Hàm lấy video từ Supabase
  Future<void> fetchVideo() async {
    try {
      final response =
          await supabase
              .from('video') // Truy vấn bảng "video"
              .select(
                'title, description, video_id',
              ) // Lấy các trường cần thiết
              .eq(
                'title',
                'luật 2',
              ) // Điều kiện tìm video có tiêu đề là "luật 2"
              .maybeSingle(); // Trả về một bản ghi duy nhất (hoặc null)

      if (response == null) throw Exception('Không tìm thấy video.');

      setState(() {
        title = response['title'] ?? '';
        description = response['description'] ?? '';
        youtubeId = response['video_id'] ?? '';

        // Nếu có ID video thì tạo controller để phát video
        if (youtubeId.isNotEmpty) {
          _controller = YoutubePlayerController.fromVideoId(
            videoId: youtubeId,
            params: const YoutubePlayerParams(
              showControls: true, // Hiện thanh điều khiển
              showFullscreenButton: true, // Hiện nút toàn màn hình
            ),
          );
        }
        isLoading = false; // Tắt trạng thái đang tải
      });
    } catch (e) {
      print('Lỗi khi truy vấn Supabase: $e');
      setState(() {
        errorMessage = e.toString();
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.close(); // Giải phóng tài nguyên khi đóng widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị vòng quay nếu đang tải
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Nếu xảy ra lỗi khi truy vấn
    if (isError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video hướng dẫn')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Không thể tải video tổng kết.'),
              Text('Lỗi: $errorMessage'), // Hiển thị thông báo lỗi chi tiết
            ],
          ),
        ),
      );
    }

    // Giao diện chính khi có dữ liệu
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thành tựu video'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước đó
          },
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.video_library),
            tooltip: 'Video',
            onPressed: () {
              // Gợi ý khi bấm vào icon video
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bạn đã bấm vào icon video!')),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF7BDFF2), // Đặt màu nền xanh nhạt
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            // Hiển thị thông tin tiêu đề bên cạnh avatar
            Row(
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                    'assets/avatar.png',
                  ), // Avatar đại diện
                ),
                SizedBox(width: 10),
                Text(
                  'Câu hỏi luật pháp',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Thẻ chứa video và mô tả
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trình phát YouTube
                  YoutubePlayerScaffold(
                    controller: _controller!,
                    aspectRatio: 16 / 9,
                    builder: (context, player) {
                      return player; // Trả về video player
                    },
                  ),
                  const SizedBox(height: 7),

                  // Phần mô tả video
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold, // TÔ ĐẬM phần mô tả
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
            ), // (placeholder nếu muốn bổ sung thêm)
          ],
        ),
      ),
    );
  }
}