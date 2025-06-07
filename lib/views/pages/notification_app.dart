import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class NotificationApp extends StatelessWidget {
  const NotificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thông báo Video App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/thong_bao',
      routes: {
        '/thong_bao': (context) => NotificationPage(),
        '/danh_sach_video': (context) => VideoListPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/video_player') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (context) => VideoPlayerPage(youtubeId: args['youtube_id']),
          );
        }
        return null;
      },
    );
  }
}

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool hasNewVideo = false;
  int currentVideoCount = 0;

  @override
  void initState() {
    super.initState();
    fetchVideoCount();
  }

  Future<void> fetchVideoCount() async {
    final response = await Supabase.instance.client.from('videos').select('id');

    if (response != null && response is List) {
      int fetchedCount = response.length;
      setState(() {
        hasNewVideo = fetchedCount > currentVideoCount;
        currentVideoCount = fetchedCount;
      });
    } else {
      print('Lỗi khi lấy dữ liệu hoặc không có phản hồi hợp lệ.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Thông báo'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              print("Thông báo icon được nhấn!");
            },
          ),
        ],
      ),
      body:
          hasNewVideo
              ? ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.video_collection),
                    title: Text('Có video mới!'),
                    onTap: () {
                      Navigator.pushNamed(context, '/danh_sach_video');
                    },
                  ),
                ],
              )
              : Center(child: Text('Không có thông báo mới.')),
    );
  }
}

class VideoListPage extends StatefulWidget {
  @override
  _VideoListPageState createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  List<Map<String, dynamic>> videos = [];

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    final response = await Supabase.instance.client
        .from('videos')
        .select('id, title, category_id, youtube_id')
        .order('id', ascending: false);

    if (response != null && response is List) {
      setState(() {
        videos = List<Map<String, dynamic>>.from(response);
      });
    } else {
      print('Lỗi khi lấy dữ liệu video.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Các video mới')),
      body:
          videos.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return ListTile(
                    leading: Icon(Icons.video_library),
                    title: Text(video['title']),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/video_player',
                        arguments: {'youtube_id': video['youtube_id']},
                      );
                    },
                  );
                },
              ),
    );
  }
}

// ✅ Trang phát video YouTube
class VideoPlayerPage extends StatefulWidget {
  final String youtubeId;

  VideoPlayerPage({required this.youtubeId});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.youtubeId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
        showVideoAnnotations: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close(); // Giải phóng tài nguyên
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(title: Text('Đang phát video')),
          body: Center(child: player),
        );
      },
    );
  }
}
