import 'package:flutter/material.dart';
import 'package:zipsai_mobile/screen/request.dart';
import 'package:zipsai_mobile/util/file.dart';

import '../util/globals.dart';
import 'main.dart';

class Load extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// 파일에서 앱 설정 값 읽어옴
    fileInit();

    /// ui를 먼저 그리고 난 후 실행하기 위한 목적으로 딜레이 1초
    Future.delayed(Duration(seconds: 1)).then((value) {
      /// macid값 읽은 후 값의 여부에 따라서
      /// macid 새로 생성 혹은 사용
      var read_macid = getData(MACID);
      if (read_macid == '') {
        macid = makeid();
        inputData(MACID, macid.toString());
      } else
        macid = int.parse(read_macid);

      /// 최초 실행 여부 판단
      var flag = false;
      if (getData(FIRSTLAUNCH) == '') {
        flag = true;
        inputData(FIRSTLAUNCH, 'good');
      }

      /// 최초 실행 여부에 따라서
      /// 위치 권한 요청 화면 출력
      if (flag) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Request(true)));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainApp()));
      }
    });

    // 풀스크린 모드
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // 일반 모드 (상단 상태바만 없애기)
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Container(
          alignment: Alignment.center,
          color: Colors.white,
          child: Text(
            "loading...",
            style: TextStyle(
              fontSize: 19,
              decoration: TextDecoration.none,
              foreground: Paint()
                ..strokeWidth = 5
                ..color = Colors.black,
            ),
          )),
    );
  }
}
