import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zipsmobile_f/service.dart';

class Request extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Expanded(
                    child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    getBasicText(text: "Privacy Policy", fontsize: 20),
                    Divider(
                      color: Colors.black,
                    ),
                    getBasicText(text: "백그라운드 위치 정보 수집", fontsize: 18),
                    getBasicText(
                        text:
                            "ZIPSAI는 사용자의 이동패턴을 예측하여 자동화된 서비스를 제공하기 위해 위치데이터를 수집합니다."),
                    getBasicText(
                        text:
                            "1. 앱이 실행 중이거나 실행 중이지 않을 때, 종료되었을 때에도 위치 데이터를 수집하여 서버 DB에 저장합니다.\n" +
                                "2. 수집된 위치 데이터를 활용하여 AI가 사용자의 이동 패턴을 학습합니다.\n" +
                                "3. 학습된 AI는 사용자의 위치 정보를 토대로 사용자의 위치 데이터를 통해" +
                                "집으로 귀가/ 직장으로 출근 등의 패턴을 예측하여 실내 난방을 자동으로 제어합니다.",
                        fontsize: 13),
                    getBasicText(
                        text:
                            "위치 정보를 활용한 이동패턴 분석 기능은 필수적이지 않으며 동의하지 않음으로 서비스를 제공받지 않을 수 있습니다."),
                  ],
                )),
                getBasicButton(context),
              ],
            )));
  }
}

Widget getBasicButton(context) {
  return Container(
      height: 60,
      color: Colors.grey,
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: Row(
          children: <Widget>[
            Expanded(
                child: SizedBox(
                    height: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        _requestPermission();
                        Navigator.pop(context);
                      },
                      child:
                          getBasicText(text: "확인", textAlign: TextAlign.center),
                    ))),
            Expanded(
                child: SizedBox(
                    height: double.infinity,
                    child: TextButton(
                        onPressed: () => {
                              Navigator.pop(context),
                            },
                        child: getBasicText(
                            text: "취소", textAlign: TextAlign.center)))),
          ],
        ),
      ));
}

Widget getBasicText(
    {required String text,
    double fontsize = 15,
    TextAlign textAlign = TextAlign.left}) {
  return SizedBox(
      width: double.infinity,
      child: Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Text(text,
              textAlign: textAlign,
              style: TextStyle(
                fontSize: fontsize,
                decoration: TextDecoration.none,
                foreground: Paint()
                  ..strokeWidth = 5
                  ..color = Colors.black,
              ))));
}

void _requestPermission() async {
  await openAppSettings().then((value) {
    Future.delayed(Duration(seconds: 10)).then((value) => startService());
  });
  // var status = await Permission.location.status;
  // if (status.isDenied) {
  //   if (await Permission.location.request().isGranted) {
  //   } else {
  //     openAppSettings();
  //   }
  // }
}

Future<bool> locPermissionCheck() async {
  if (await Permission.locationAlways.isGranted)
    return true;
  else
    return false;
}
