/// 최초 로딩 화면.
/// 앱 최초 실행 및 네트워크 연결 여부에 따라서
/// 출력할 화면 선택

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zipsai_mobile/screen/wifi/enter.dart';
import 'package:zipsai_mobile/screen/request.dart';
import 'package:zipsai_mobile/util/file.dart';

import '../RAM.dart';
import '../ROM.dart';
import '../service/service.dart';
import '../util/etc.dart';
import 'main.dart';

class LoadAPP extends StatelessWidget {
  const LoadAPP({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 풀스크린 모드
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // 일반 모드 (상단 상태바만 없애기)
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: LoadPage(),
    );
  }
}

class LoadPage extends StatefulWidget {
  const LoadPage({Key? key}) : super(key: key);

  @override
  _LoadPage createState() => _LoadPage();
}

class _LoadPage extends State<LoadPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // 인터넷 연결 체크
      // 연결 안되어 있으면 페어링 모드로 전환
      if (!await internetcheck()) {
        // if (true) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => EnterWiFi()));
        gParingMode = 1;
        return;
      }

      // 위치 권한 체크
      LocPermissionCheck();

      // 서비스 실행 중인지 체크
      IsRunService();

      //FuckUTest();

      // 파일 에서 셋팅 값 읽어옴
      await FileInit();

      // macid 체크, 없으면 생성
      var readMacid = GetData(MACID);
      if (readMacid == '') {
        gMacId = MakeId();
        SetData(MACID, gMacId.toString());
      } else {
        gMacId = int.parse(readMacid);
      }

      // 서비스 자동 실행여부
      var autotemp = GetData(AUTORUNSERV);
      if (autotemp == "") {
        SetData(AUTORUNSERV, "1");
        gServAuto = 1;
      } else {
        gServAuto = int.parse(autotemp);
      }

      // 최초 실행 여부 판단
      // 최초 실행시 위치 권한 요청 화면 출력
      if (GetData(FIRSTLAUNCH) == '') {
        SetData(FIRSTLAUNCH, 'good');

        //log(GetData(FIRSTLAUNCH));

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Request(true)));
      }
      // 아닌 경우 webview를 통한 정상접근
      else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainApp()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Container(alignment: Alignment.center);
  }
}
