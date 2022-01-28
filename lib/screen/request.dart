import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
                    getBasicText(
                        text: "백그라운드 위치 정보 수집",
                        fontsize: 18,
                        fontWeight: FontWeight.bold),
                    getBasicText(
                        text:
                            "ZIPSAI는 앱이 종료되었거나 사용 중이 아닐 때도 위치 데이터를 수집하여 사용자의 이동패턴 예측 기능을 지원합니다.",
                        fontWeight: FontWeight.w700),
                    getBasicText(
                        text: "1. 앱이 실행 중이거나 실행 중이지 않을 때, 종료되었을 때에도 위치 데이터를 수집하여 서버 DB에 저장합니다.\n" +
                            "2. 수집하는 위치 데이터는 사용자의 위도, 경도, 속도, 수평 정확도 입니다.\n" +
                            "3. 수집된 위치 데이터를 활용하여 AI가 사용자의 이동 패턴을 학습합니다.\n" +
                            "4. 학습된 AI는 사용자의 위치 정보를 토대로 사용자의 위치 데이터를 통해" +
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
      height: 55,
      color: Colors.grey,
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: Row(
          children: <Widget>[
            Expanded(
                child: SizedBox(
                    height: double.infinity,
                    child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.lightBlue),
                        child: TextButton(
                          onPressed: () {
                            _requestPermission();
                            Navigator.pop(context);
                          },
                          child: getBasicText(
                              text: "수락", textAlign: TextAlign.center),
                        )))),
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
    TextAlign textAlign = TextAlign.left,
    FontWeight fontWeight = FontWeight.normal}) {
  return SizedBox(
      width: double.infinity,
      child: Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
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

void _requestPermission() async {
  // await openAppSettings().then((value) {
  //   Future.delayed(Duration(seconds: 10)).then((value) => startService());
  // });

  if (await Permission.location.request().isGranted) {
    if (await Permission.locationAlways.isGranted == false) {
      //Geolocator.openLocationSettings();
      await Permission.locationAlways.request();
    }
  }
}

Future<bool> locPermissionCheck() async {
  if (await Permission.locationAlways.isGranted)
    return true;
  else
    return false;
}
