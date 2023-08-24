import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ImageGridDemo());
}

class ImageGridDemo extends StatefulWidget {
  const ImageGridDemo({super.key});

  @override
  State<ImageGridDemo> createState() => _ImageGridDemoState();
}

class _ImageGridDemoState extends State<ImageGridDemo> {
  String data = ''; // 공공데이터 값을 String으로 받아 주기 위한 전역 변수
  int maxNumOfRows = 1000; // 한 페이지 결과 수
  var apiKey =
      "tf63OH7QOoe8XPJMRodljGD8oGoydgD0Xhu6TtMNz18a%2B9wF7hwg3HMKfnXNIJYyZ1cgjB3VSz%2FozoZIMow1Fg%3D%3D"; // Encoding API 키(원래는 사용자 본인 ㅁ)

  List<Map<String, String>> parsedData = [];

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse(
        'https://apis.data.go.kr/B551011/PhotoGalleryService1/galleryList1?serviceKey=$apiKey&numOfRows=$maxNumOfRows&pageNo=1&MobileOS=ETC&MobileApp=AppTest&arrange=A&_type=json',
      ),
    ); // http request하여 데이터 response를 받아오기

    if (response.statusCode == 200) {
      // 200: server 연동 성공 시
      setState(() {
        data = utf8.decode(response
            .bodyBytes); // utf8.decode()는 json 데이터 값 중 한국어 문자 구현을 위해 (utf8)사용
      });

      final Map<String, dynamic> jsonResponse = jsonDecode(
          data); // String 형식으로 구현된 json 데이터 값을 Map 형식으로 변환, 변환 이유: totalCount, galTitle, galWebImageUrl 부분 데이터 값을 가져오기 위함.
      int totalCount = jsonResponse['response']['body']
          ['totalCount']; // 전체 데이터를 한번에 가져오기 위해 최대의 totalCount 값을 가져옴
      maxNumOfRows = totalCount; // 한 페이지 결과 수를 최대값으로 대입하기 위함

      final List<dynamic> items = jsonResponse['response']['body']['items'][
          'item']; // items는 jsonResponse의 Map 형식에서 List형식으로 변환하고 json 데이터 값 'response' 안에 'body' 안에 'items' 안에 'item'의 값을 가져오기 위함

      setState(() {
        parsedData = items.map((item) {
          return {
            'galTitle': item['galTitle'] as String,
            'galWebImageUrl': item['galWebImageUrl'] as String,
          };
        }).toList(); // parsedData는 위 items의 List 배열의 값에서 galTitle, galWebImageUrl 데이터 값만 String 형식으로 변환하여 가져오기 위함.
      });
    } else {
      setState(() {
        parsedData = [];
      });
    }
  }

  @override
  void initState() {
    //  Stateful Widget이 생성될 때 '한번'만 호출되는 함수
    fetchData(); // 처음 화면 구현시 이미지와 제목의 결과 값을 뽑아내기 위해 작성
    super.initState();
  }

  @override
  void dispose() {
    // widget을 종료할 때 사용
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Image_Grid_Demo_App'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2열의 그리드뷰를 생성합니다. 원하는 열의 수로 변경 가능합니다.
                    childAspectRatio: 3 / 4, // 각 아이템의 가로세로 비율, 필요에 따라 조정하세요.
                    crossAxisSpacing: 10, // 가로 간격
                    mainAxisSpacing: 10, // 세로 간격
                  ),
                  itemCount: parsedData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      // 카드 형태로 각 그리드 아이템을 표시합니다.
                      child: Column(
                        children: <Widget>[
                          Image.network(
                              parsedData[index]['galWebImageUrl']!), // Image 구현
                          Text(parsedData[index]['galTitle']!), // 이미지 제목 구현
                        ],
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
