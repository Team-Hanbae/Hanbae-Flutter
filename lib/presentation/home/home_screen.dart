import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hanbae/data/sound_manager.dart';
import 'package:hanbae/data/custom_jangdan_data.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final _soundManager = SoundManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Image.asset("assets/images/AppLogo.png"),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "내가 저장한 장단",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(minimumSize: Size(0, 40)),
                        child: Text("더보기", style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  SizedBox(
                    height: 84,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: customJangdanList.length,
                      itemBuilder: (context, index) {
                        final item = customJangdanList[index];
                        return Container(
                          width: 156,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text(item.title), Text(item.janganType)],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32),

              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "바로 연습하기",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: 20,
                    itemBuilder: (content, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 64,
                                height: 64,
                                child: Center(
                                  child: SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: SvgPicture.asset(
                                      "assets/images/logos/Jinyang.svg",
                                    ),
                                  ),
                                ),
                              ),
                              Column(children: [Text("진양"), Text("24박 3소박")]),
                            ],
                          ),
                          Icon(Icons.chevron_right_rounded),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
