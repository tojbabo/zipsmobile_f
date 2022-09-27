import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zipsai_mobile/RAM.dart';
import 'package:zipsai_mobile/util/etc.dart';

import 'main.dart';

class Request extends StatelessWidget {
  bool isReLoad;
  Request(this.isReLoad, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WillPopScope(
          child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: Column(
                    children: [
                      _GetBasicText(text: "Privacy Policy", fontsize: 20),
                      const Divider(
                        color: Colors.black,
                      ),
                      _GetBasicText(
                          text: "백그라운드 위치 정보 수집",
                          fontsize: 18,
                          fontWeight: FontWeight.bold),
                      _GetBasicText(
                          text:
                              "ZIPSAI는 앱이 종료되었거나 사용 중이 아닐 때도 위치 데이터를 수집하여 사용자의 이동패턴 예측 기능을 지원합니다.",
                          fontWeight: FontWeight.w700),
                      _GetBasicText(
                          text: "1. 앱이 실행 중이거나 실행 중이지 않을 때, 종료되었을 때에도 위치 데이터를 수집하여 서버 DB에 저장합니다.\n"
                                  "2. 수집하는 위치 데이터는 사용자의 위도, 경도, 속도, 수평 정확도 입니다.\n" +
                              "3. AI는 수집된 위치데이터를 활용하여 사용자의 실내 유무를 학습합니다.\n" +
                              "4. 학습된 AI는 사용자의 위치 정보를 토대로 사용자의 위치 데이터를 통해" +
                              "집으로 귀가/ 직장으로 출근 등의 패턴을 예측하여 실내 난방을 자동으로 제어합니다.",
                          fontsize: 13),
                      _GetBasicText(
                          text:
                              "위치 정보를 활용한 이동패턴 분석 기능은 필수적이지 않으며 동의하지 않음으로 서비스를 제공받지 않을 수 있습니다."),
                    ],
                  )),
                  _GetBasicButton(context, isReLoad),
                ],
              )),
          onWillPop: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MainApp()));
            return Future(() => false);
          }),
    );
  }

  /// 위치 권한 요청 함수
  ///
  /// 위치 권한 허용 시 항상 허용 요청 화면으로 넘어감
  Future _requestPermission() async {
    if (await Permission.location.request().isGranted) {
      if (await Permission.locationAlways.isGranted == false) {
        await Permission.locationAlways.request();
        //await openAppSettings();
      }
    }
  }

  /// 기본 텍스트 박스 위젯 가져오는 함수
  ///
  /// - 개인정보처리보호 방침 텍스트에 사용됨
  Widget _GetBasicText(
      {required String text,
      double fontsize = 15,
      TextAlign textAlign = TextAlign.left,
      FontWeight fontWeight = FontWeight.normal}) {
    return SizedBox(
        width: double.infinity,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Text(text,
                textAlign: textAlign,
                style: TextStyle(
                  fontSize: fontsize,
                  decoration: TextDecoration.none,
                  fontWeight: fontWeight,
                  foreground: Paint()
                    ..strokeWidth = 1
                    ..color = Colors.black,
                ))));
  }

  /// 기본 버튼 위젯 가져오는 함수
  ///
  /// - 개인정보처리보호 방침 확인 버튼에 사용됨
  Widget _GetBasicButton(context, isreload) {
    return Container(
        height: 55,
        color: Colors.grey,
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: Row(
            children: <Widget>[
              // 확인 버튼
              Expanded(
                  child: SizedBox(
                      height: double.infinity,
                      child: DecoratedBox(
                          decoration:
                              const BoxDecoration(color: Colors.lightBlue),
                          child: TextButton(
                            onPressed: () async {
                              await _requestPermission();
                              var res = await LocPermissionCheck();
                              log('result is: $res');
                              if (res == true) {
                                gServAuto = 1;
                              }
                              if (isreload) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainApp()));
                              } else {
                                Navigator.pop(context, true);
                              }
                            },
                            child: _GetBasicText(
                                text: "수락", textAlign: TextAlign.center),
                          )))),
              // 취소 버튼
              Expanded(
                  child: SizedBox(
                      height: double.infinity,
                      child: TextButton(
                          onPressed: () {
                            if (isreload) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainApp()));
                            } else {
                              Navigator.pop(context, false);
                            }
                          },
                          child: _GetBasicText(
                              text: "취소", textAlign: TextAlign.center)))),
            ],
          ),
        ));
  }
}
