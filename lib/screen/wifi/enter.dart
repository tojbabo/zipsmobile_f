/// WiFi 페어링을 위해
/// 네트워크 상에 조절기와 연결하는 위젯

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zipsai_mobile/screen/wifi/paring.dart';
import 'package:zipsai_mobile/util/wifi.dart';
import 'package:fluttertoast/fluttertoast.dart';

GlobalKey<_EnterPage> KEY_WiFiEnter = GlobalKey();

class EnterWiFi extends StatelessWidget {
  const EnterWiFi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 풀스크린 모드
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // 일반 모드 (상단 상태바만 없애기)
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 54, 54, 54)));
    return EnterPage(key: KEY_WiFiEnter);
  }
}

class EnterPage extends StatefulWidget {
  const EnterPage({Key? key}) : super(key: key);

  @override
  _EnterPage createState() => _EnterPage();
}

class _EnterPage extends State<EnterPage> {
  Connector connector = Connector();
  ParingApp? PA;

  IconData _network_icon = Icons.wifi_rounded;
  int _animate_state = 2;
  Timer? _animate_timer;
  Timer? _test;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 54, 54, 54),
        body: Stack(
          children: [
            Container(
                margin: const EdgeInsets.all(10),
                decoration: (const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15)))),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: () {
                          // PA = ParingApp();
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) => PA!));
                          // fortest();
                          // return;

                          /// 일단 찾기 애니메이션 활성화
                          _FindDev_Animate();

                          /// 페이지 초기화
                          PA = null;

                          /// UDP 리스너 활성화.
                          /// 조절기 연동 리스너 연결
                          connector.Listener_UDP(Connected_Event);
                        },
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.only(top: 50.0),
                              child: Material(
                                  type: MaterialType
                                      .transparency, //Makes it usable on any background color, thanks @IanSmith
                                  child: Ink(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 25, 162, 244),
                                              width: 4.0),
                                          shape: BoxShape.circle),
                                      child: const Icon(
                                        Icons.link,
                                        color:
                                            Color.fromARGB(255, 25, 162, 244),
                                        size: 110,
                                      ))),
                            ),
                            const Text(
                              "조절기 찾기",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                  height: 2),
                            ),
                          ],
                        )),
                    GestureDetector(
                        onTap: () => Fluttertoast.showToast(msg: "coming soon"),
                        child: Container(
                            alignment: const Alignment(0, 0),
                            height: 60,
                            width: 200,
                            margin: const EdgeInsets.only(
                              top: 30.0,
                            ),
                            child: null
                            //     Stack(alignment: Alignment.center, children: <Widget>[
                            //   Container(
                            //     height: double.infinity,
                            //     width: double.infinity,
                            //   ),
                            //   Positioned(
                            //       child: Container(
                            //     width: 130.0,
                            //     padding: EdgeInsets.only(
                            //         left: 13.0, top: 4.0, bottom: 4.0),
                            //     decoration: BoxDecoration(
                            //         color: const Color.fromARGB(255, 104, 104, 104),
                            //         borderRadius: BorderRadius.circular(10)),
                            //     child: const Text(
                            //       "메인 화면",
                            //       style: TextStyle(
                            //           fontWeight: FontWeight.w700,
                            //           color: Colors.white),
                            //     ),
                            //   )),
                            //   Positioned(
                            //       right: 20,
                            //       child: Material(
                            //           type: MaterialType
                            //               .transparency, //Makes it usable on any background color, thanks @IanSmith
                            //           child: Ink(
                            //               decoration: BoxDecoration(
                            //                   border: Border.all(
                            //                       color: Colors.white, width: 1.5),
                            //                   color: const Color.fromARGB(
                            //                       255, 54, 54, 54),
                            //                   shape: BoxShape.circle),
                            //               child: const Icon(
                            //                 Icons.arrow_right_rounded,
                            //                 size: 45.0,
                            //                 color: Colors.white,
                            //               ))))
                            // ]),
                            ))
                  ],
                ))),
            Visibility(
                visible: (_animate_timer != null),
                child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration:
                        BoxDecoration(color: Color.fromARGB(225, 0, 0, 0)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            _network_icon,
                            size: 45.0,
                            color: Colors.white,
                          ),
                          const Text('조절기 연결 중',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )))
          ],
        ));
  }

  ///조절기 찾기 애니메이션,,
  void _FindDev_Animate() {
    _animate_timer = Timer.periodic(new Duration(milliseconds: 700), (timer) {
      setState(() {
        switch (_animate_state) {
          case 0:
            _network_icon = Icons.wifi_1_bar_rounded;
            _animate_state = 1;
            break;
          case 1:
            _network_icon = Icons.wifi_2_bar_rounded;
            _animate_state = 2;
            break;
          case 2:
            _network_icon = Icons.wifi_rounded;
            _animate_state = 0;
            break;
        }
      });
    });
  }

  // 테스팅용 해당 위젯 종료
  void tempfunc() async {
    await Future.delayed(Duration(seconds: 5));
    if (KEY_WiFiParing.currentContext != null) {
      Navigator.pop(KEY_WiFiParing.currentContext!);
    }
  }

  /// 조절기와 연결됐을때 리스너
  void Connected_Event(String res) {
    /// 애니메이션 종료
    _animate_timer?.cancel();
    setState(() {
      _animate_timer = null;
    });

    // 연결에 성공한 경우
    if (res != "") {
      /// 아직 페어링 위젯이 없는 경우, 페어링 위젯 생성 및 변경
      if (PA == null) {
        PA = ParingApp();
        Navigator.push(context, MaterialPageRoute(builder: (context) => PA!));
      }

      /// 페어링 위젯으로 동/호수 데이터 전달
      KEY_WiFiParing.currentState?.SetBuildHouse(res);
    }
    // 연결이 끊어진 경우
    else {
      if (PA == null) {
        Fluttertoast.showToast(msg: "네트워크에 조절기가 없습니다.");
      }

      if (KEY_WiFiParing.currentContext != null) {
        Navigator.pop(KEY_WiFiParing.currentContext!);
      }
      DisConnected_Dev();
    }
  }

  void DisConnected_Dev() {
    connector.Disconnect_TCPUDP();
    PA = null;
    _test?.cancel();
  }

  void fortest() async {
    var i = 0;
    _test = Timer.periodic(new Duration(seconds: 1), (timer) {
      i++;
      Connected_Event("$i");
      if (i >= 10) {
        Connected_Event("");
        DisConnected_Dev();
      }
      if (PA == null) timer.cancel();

      /// 페어링 위젯으로 동/호수 데이터 전달
    });
  }
}
