import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zipsai_mobile/screen/wifi/paring.dart';
import 'package:zipsai_mobile/util/wifi.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    return const EnterPage();
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 54, 54, 54),
        body: Container(
            margin: const EdgeInsets.all(10),
            decoration: (const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)))),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 50.0),
                  child: Material(
                      type: MaterialType
                          .transparency, //Makes it usable on any background color, thanks @IanSmith
                      child: Ink(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 25, 162, 244),
                                  width: 6.0),
                              shape: BoxShape.circle),
                          child: IconButton(
                              iconSize: 100.0,
                              color: const Color.fromARGB(255, 25, 162, 244),
                              onPressed: () {
                                PA = null;
                                connector.Listener_UDP(Connected_Event);
                              },
                              icon: const Icon(
                                Icons.link,
                              )))),
                ),
                const Text(
                  "조절기 찾기",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 19, height: 2),
                ),
                GestureDetector(
                    onTap: () => Fluttertoast.showToast(msg: "coming soon"),
                    child: Container(
                      alignment: const Alignment(0, 0),
                      height: 60,
                      width: 200,
                      margin: const EdgeInsets.only(
                        top: 30.0,
                      ),
                      child:
                          Stack(alignment: Alignment.center, children: <Widget>[
                        Container(
                          height: double.infinity,
                          width: double.infinity,
                        ),
                        Positioned(
                            child: Container(
                          width: 130.0,
                          padding: EdgeInsets.only(
                              left: 13.0, top: 4.0, bottom: 4.0),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 104, 104, 104),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Text(
                            "메인 화면",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        )),
                        Positioned(
                            right: 20,
                            child: Material(
                                type: MaterialType
                                    .transparency, //Makes it usable on any background color, thanks @IanSmith
                                child: Ink(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.white, width: 1.5),
                                        color: const Color.fromARGB(
                                            255, 54, 54, 54),
                                        shape: BoxShape.circle),
                                    child: const Icon(
                                      Icons.arrow_right_rounded,
                                      size: 45.0,
                                      color: Colors.white,
                                    ))))
                      ]),
                    ))
              ],
            ))));
  }

// 꺼지는 거 잘 동작함
  void tempfunc() async {
    await Future.delayed(Duration(seconds: 5));
    if (paringKey.currentContext != null) {
      Navigator.pop(paringKey.currentContext!);
    }
  }

  void Connected_Event(String res) {
    // 연결에 성공한 경우
    if (res != "") {
      if (PA == null) {
        PA = ParingApp();
        Navigator.push(context, MaterialPageRoute(builder: (context) => PA!));
      }
      paringKey.currentState?.SetSN(res);
    }
    // 연결이 끊어진 경우
    else {
      if (PA == null) {
        Fluttertoast.showToast(msg: "네트워크에 조절기가 없습니다.");
      }

      if (paringKey.currentContext != null) {
        Navigator.pop(paringKey.currentContext!);
      }
      PA = null;
    }
  }
}
