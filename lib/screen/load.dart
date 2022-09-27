import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zipsai_mobile/screen/paring.dart';
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
      theme: ThemeData(),
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
        //if (false) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ParingApp()));
        gParingMode = 1;
        return;
      }

      // 위치 권한 체크
      LocPermissionCheck();
      IsRunService();

      // 파일 에서 셋팅 값 읽어옴
      await FileInit();

      var readMacid = GetData(MACID);
      if (readMacid == '') {
        gMacId = MakeId();
        SetData(MACID, gMacId.toString());
      } else {
        gMacId = int.parse(readMacid);
      }

      var idpwtemp = GetData(LOGININFO);
      if (idpwtemp != '') {
        var token = idpwtemp.split(',,');
        gId = token[0];
        gPw = token[1];
      }

      var sentemp = GetData(SENIOR);
      if (sentemp == "") {
        SetData(SENIOR, "0");
      } else {
        gSeniorMode = int.parse(sentemp);
      }

      var autotemp = GetData(AUTORUNSERV);
      if (autotemp == "") {
        SetData(AUTORUNSERV, "1");
        gServAuto = 1;
      } else {
        gServAuto = int.parse(autotemp);
      }

      // 최초 실행 여부 판단
      // 위치 권한 요청 화면 출력
      if (GetData(FIRSTLAUNCH) == '') {
        SetData(FIRSTLAUNCH, 'good');

        //log(GetData(FIRSTLAUNCH));

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Request(true)));
      } else {
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
