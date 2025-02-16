import 'dart:io';
import 'package:flutter/material.dart';

class ArtTellerScreen extends StatelessWidget {
  final String imageUrl; // 이미지 URL
  final int predictedClass;
  const ArtTellerScreen({Key? key, required this.imageUrl, required this.predictedClass}) : super(key: key);

  void _showInterpretationDialog(BuildContext context) {
    double difficulty = 0.0; // 0: 쉬움, 1: 중간, 2: 어려움
    double gender = 0.0; // 0: 남자, 1: 여자

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: 350,
                height: 400, // 팝업 크기 확대
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 닫기 버튼 (오른쪽 위)
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(height: 20),

                    // 난이도 선택 슬라이더
                    _buildCustomSlider(
                      labels: ["쉬움", "어려움"],
                      value: difficulty,
                      divisions: 2,
                      onChanged: (newValue) => setState(() => difficulty = newValue),
                    ),

                    SizedBox(height: 50),

                    // 성별 선택 슬라이더
                    _buildCustomSlider(
                      labels: ["남자", "여자"],
                      value: gender,
                      divisions: 1,
                      onChanged: (newValue) => setState(() => gender = newValue),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 커스텀 슬라이더 위젯 (원 추가)
  Widget _buildCustomSlider({
    required List<String> labels,
    required double value,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(labels.length, (index) {
            return Text(
              labels[index],
              style: TextStyle(
                color: Colors.white,
                fontSize: 22, // 글씨 크기 확대
                fontWeight: FontWeight.bold,
              ),
            );
          }),
        ),
        SizedBox(height: 10),

        // 슬라이더와 원을 함께 배치하는 Stack
        Stack(
          alignment: Alignment.center,
          children: [
            // 기본 슬라이더
            SliderTheme(
              data: SliderThemeData(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0), // 기본 썸 제거
                trackHeight: 2, // 슬라이더 두께
              ),
              child: Slider(
                value: value,
                min: 0,
                max: divisions.toDouble(),
                divisions: divisions,
                activeColor: Colors.transparent, // 기본 색상 없앰
                inactiveColor: Colors.white,
                onChanged: onChanged,
              ),
            ),

            // 원 추가 (슬라이더 위에 배치)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(divisions + 1, (index) {
                  bool isSelected = (value == index.toDouble());
                  return Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange, width: 2),
                      color: isSelected ? Colors.orange : Colors.black,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // 배경 투명
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9, // 가로 90%
            height: 400, // 높이 증가
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _languageButton("🇰🇷", "한국어"),
                        _languageButton("🇯🇵", "일본어"),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _languageButton("🇨🇳", "중국어"),
                        _languageButton("🇺🇸", "영어"),
                      ],
                    ),
                  ],
                ),
                // 닫기 버튼 (오른쪽 상단)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 언어 선택 버튼 생성 함수 (국기와 버튼 크기 확대)
  Widget _languageButton(String flag, String language) {
    return Column(
      children: [
        Text(flag, style: TextStyle(fontSize: 50)), // 국기 크기 증가
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            print("$language 선택됨");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 13), // 버튼 크기 확대
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(language, style: TextStyle(fontSize: 25, color: Colors.black)), // 글자 크기 증가
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 40.0, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기 (카메라 화면으로)
          },
        ),
        title: Text('Art Teller', style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Colors.orange)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_border, size: 40.0, color: Colors.orange),
            onPressed: () {
              print("저장되었습니다.");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단 해설 선택 & 언어 선택 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _showInterpretationDialog(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("해설 선택", style: TextStyle(fontSize: 20, color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: () => _showLanguageSelectionDialog(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("언어 선택", style: TextStyle(fontSize: 20, color: Colors.black)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover), // S3 URL로 이미지 표시
          ),

          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.replay_5, size: 60.0, color: Colors.orange),
                onPressed: () {
                  print("5초 전으로 이동");
                },
              ),
              IconButton(
                icon: Icon(Icons.pause, size: 60.0, color: Colors.orange),
                onPressed: () {
                  print("정지");
                },
              ),
              IconButton(
                icon: Icon(Icons.forward_5, size: 60.0, color: Colors.orange),
                onPressed: () {
                  print("5초 후로 이동");
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              print("음성 인식 시작!");
              // 여기에 음성 인식 기능 추가 가능
            },
            child: Icon(
              Icons.mic,
              color: Colors.orange,
              size: 60,
            ),
          ),
        ],
      ),
    );
  }
}
