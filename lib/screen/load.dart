import 'package:flutter/material.dart';
import 'package:zipsmobile_f/screen/request.dart';
import 'package:zipsmobile_f/file.dart';

import '../globals.dart';
import 'main.dart';

class Load extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ui를 먼저 그리고 난 후 실행하기 위한 목적으로 딜레이 1초
    fileInit();

    Future.delayed(Duration(seconds: 1)).then((value) {
      var tmp = getData('macid');
      if (tmp == '') {
        macid = makeid();
        inputData('macid', macid.toString());
      } else
        macid = int.parse(tmp);

      tmp = getData('isfirst');
      var flag = false;
      if (tmp == '') {
        flag = true;
        inputData('isfirst', 'good');
      }

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainApp()));
      if (flag) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Request()));
      }
    });

    // 풀스크린 모드
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // 일반 모드 (상단 상태바만 없애기)
    // SystemChrome.setEnabledSystemUIMode(
    //     SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);

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
