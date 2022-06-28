import 'package:flutter/material.dart';
import 'package:zipsai_mobile/screen/request.dart';
import 'package:zipsai_mobile/util/file.dart';

import '../util/globals.dart';
import 'main.dart';

class LoadAPP extends StatelessWidget {
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoadPage(),
    );
  }
}

class LoadPage extends StatefulWidget {
  _LoadPage createState() => _LoadPage();
}

class _LoadPage extends State<LoadPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      locPermissionCheck().then((value) {
        if (value == true) {
          servEnable = 1;
          servAutoRun = 1;

          // if (getData(AUTORUNSERV) == '1') {
          // }
        }
      });

      /// 파일에서 앱 설정 값 읽어옴
      await fileInit();

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
  }

  @override
  Widget build(BuildContext context) {
    return Container(alignment: Alignment.center, color: Colors.white);
  }
}
