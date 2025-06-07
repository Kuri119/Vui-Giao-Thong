import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:testing/views/pages/home_page.dart';

class SignpostPage extends StatefulWidget {
  const SignpostPage({super.key});

  @override
  State<SignpostPage> createState() => _SignpostPageState();
}

class _SignpostPageState extends State<SignpostPage> {
  int selectedIndex = 0;
  List<String> detectedClasses = []; // Để lưu các kết quả nhận diện từ API
  List<dynamic> fetchedBienBaos = []; // Để lưu các biển báo lấy từ CSDL

  final List<String> categoryKeys = [
    '', // Tất cả
    'P', // Biển báo cấm
    'W', // Biển báo nguy hiểm và cảnh báo
    'R', // Biển báo hiệu lệnh
  ];
  Future<List<dynamic>> fetchBienBao(String loai) async {
    final query = Supabase.instance.client.from('Bienbao').select('url, mota');

    if (loai.isNotEmpty) {
      final response = await query.eq('loai', loai);
      return response;
    } else {
      final response = await query;
      return response;
    }
  }

  // Hàm để lấy biển báo từ CSDL dựa trên danh sách detectedClasses
  Future<void> fetchBienBaosByDetectedClasses(
    List<String> detectedClasses,
  ) async {
    final query = Supabase.instance.client
        .from('Bienbao')
        .select('url, mota, ten');

    String orCondition = detectedClasses
        .map((className) {
          return 'ten.eq.${className}'; // Điều kiện ten = 'className'
        })
        .join(',');

    final response = await query.or(orCondition);

    setState(() {
      fetchedBienBaos = response;
    });
  }

  // Hàm upload và nhận diện ảnh
  Future<void> uploadAndDetect() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      setState(() {
        detectedClasses = ['Bạn chưa chọn ảnh!'];
      });
      return;
    }

    final url = Uri.parse(
      'https://detect.roboflow.com/vietnam-traffic-sign-detection-2i2j8/5?api_key=LsjoTmwGMowMuvqjtMgG',
    );
    var request = http.MultipartRequest('POST', url);

    request.files.add(
      await http.MultipartFile.fromPath('file', pickedFile.path),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = json.decode(respStr);

      if (data['predictions'] != null && data['predictions'].length > 0) {
        List<String> classes = [];
        for (var item in data['predictions']) {
          classes.add(item['class']);
        }
        setState(() {
          detectedClasses = classes;
        });
        // Gọi hàm để fetch biển báo theo các kết quả nhận diện
        fetchBienBaosByDetectedClasses(classes);
      } else {
        setState(() {
          detectedClasses = ['Không nhận diện được biển báo nào.'];
        });
      }
    } else {
      setState(() {
        detectedClasses = ['Lỗi: ${response.statusCode}'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 127, 202, 242),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
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
          title: Text(
            'Biển báo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                uploadAndDetect(); // Gọi hàm upload và nhận diện khi nhấn nút tìm kiếm
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              CategorySelector(
                selectedIndex: selectedIndex,
                onCategorySelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
              // Hiển thị danh sách các biển báo đã nhận diện và tìm kiếm được
              if (fetchedBienBaos.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: fetchedBienBaos.length,
                    itemBuilder: (context, index) {
                      final bienBao = fetchedBienBaos[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 127, 202, 242),
                            border: Border.all(
                              color: Color.fromARGB(255, 127, 202, 242),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  bienBao['url'] ?? '',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey,
                                        child: Icon(Icons.image, size: 50),
                                      ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  bienBao['mota'] ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: fetchBienBao(categoryKeys[selectedIndex]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Lỗi: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Không có dữ liệu'));
                      }

                      final bienBaos = snapshot.data!;
                      return SingleChildScrollView(
                        child: Column(
                          children: List.generate(bienBaos.length, (index) {
                            final bienBao = bienBaos[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 127, 202, 242),
                                  border: Border.all(
                                    color: Color.fromARGB(255, 127, 202, 242),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        bienBao['url'] ?? '',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  color: Colors.grey,
                                                  child: Icon(
                                                    Icons.image,
                                                    size: 50,
                                                  ),
                                                ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        bienBao['mota'] ?? '',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategorySelector extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onCategorySelected;

  CategorySelector({
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final List<String> categories = [
    'Tất cả',
    'Biển báo cấm',
    'Biển báo nguy hiểm và cảnh báo',
    'Biển báo hiệu lệnh',
  ];

  final Color activeColor = Color(0xFF7FC8F2);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (index) {
          final bool isSelected = widget.selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: activeColor, width: 2),
                backgroundColor: isSelected ? activeColor : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () {
                widget.onCategorySelected(index);
              },
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : activeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}