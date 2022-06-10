import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zipsai_mobile/screen/request.dart';
import 'package:zipsai_mobile/service/service.dart';
import 'package:zipsai_mobile/util/file.dart';
import 'package:zipsai_mobile/util/globals.dart';

int height = 0;
void controllerSetHandler(
    InAppWebViewController controller, BuildContext context) {
  //alert: 서버에서 앱으로 알람
  controller.addJavaScriptHandler(
      handlerName: "alerts",
      callback: (arg) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                content: const Text('애플리케이션 버전이 낮습니다.\n최신 버전으로 업데이트하세요'),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        launch(
                            'https://play.google.com/store/apps/details?id=com.hansung.zipsai');
                      },
                      child: const Text('업데이트')),
                ],
              );
            });
      });

  controller.addJavaScriptHandler(
      handlerName: "URL",
      callback: (arg) {
        var msg = arg.cast<String>()[0];
        //print(msg);
        launch(msg);
      });

  //toast: 서버 메시지 toast로 뿌림
  controller.addJavaScriptHandler(
      handlerName: "toast",
      callback: (arg) {
        var msg = arg.cast<String>()[0];
        Fluttertoast.showToast(msg: msg);
      });

  //appclose [구현]
  controller.addJavaScriptHandler(
      handlerName: "appclose",
      callback: (arg) {
        CookieManager().deleteAllCookies();
        //exit(0);
        Navigator.of(context).pop(true);
        SystemNavigator.pop();
        //exit(0);
      });

  //autologin[구현]: 자동로그인 설정
  controller.addJavaScriptHandler(
      handlerName: "autologin",
      callback: (arg) async {
        bool flag = arg.cast<bool>()[0];
        //print('flag is : $flag');
        if (flag) {
          inputData(LOGININFO, '$id,,$pw');
        } else {
          removeData(LOGININFO);
        }
      });

  //logininfo[적용 중]: 로그인 정보 가져옴
  controller.addJavaScriptHandler(
      handlerName: 'logininfo',
      callback: (arg) {
        String param = arg.cast<String>()[0];
        var datas = param.split(',');
        id = datas[0];
        pw = datas[1];
      });

  //getappinfo[구현]: info 리턴
  controller.addJavaScriptHandler(
      handlerName: "getappinfo",
      callback: (arg) {
        return appinfo;
      });

  //getdeviceid[구현]: 기기 id 전달
  controller.addJavaScriptHandler(
      handlerName: "getdeviceid",
      callback: (arg) {
        return macid;
      });

  //setsenior[구현]: 노인모드 비/활성화
  controller.addJavaScriptHandler(
      handlerName: "senior",
      callback: (arg) {
        int flag = arg.cast<int>()[0];
        inputData(SENIOR, '$flag');
        //print("save data is : $flag");
      });

  //webprint: 서버에서 출력되는내용 확인 디버깅용
  controller.addJavaScriptHandler(
      handlerName: "webprint",
      callback: (arg) {
        String msg = arg.cast<String>()[0];
        print('console.log: $msg');
      });

  ///
  ///서비스 관련부
  ///

  //servicestate: 서버로 서비스 관련 상태값 전달
  controller.addJavaScriptHandler(
      handlerName: "servicestate",
      callback: (arg) async {
        var res = "${(await isrunService()) ? 1 : 0}"
            ",$servEnable"
            ",$servAutoRun";
        return res;
      });

  //startservice: 서버에서 기기로 서비스 실행
  controller.addJavaScriptHandler(
      handlerName: "startservice",
      callback: (arg) async {
        return await startService();
      });

  //getlastloc: 최종 위치 전달
  controller.addJavaScriptHandler(
      handlerName: "lastLocation",
      callback: (arg) async {
        var result = await getNowLocation();
        return result;
        //print("receive data from server $location");
      });

  //isrunservice: 서버에서 기기로 서비스 실행중인지 파악
  controller.addJavaScriptHandler(
      handlerName: "isrunservice",
      callback: (arg) async {
        var v = await isrunService();
        return v;
      });

  //dolocationset: 기기에서 location setting 실행
  controller.addJavaScriptHandler(
      handlerName: "dolocationset",
      callback: (arg) {
        settingService();
      });

  //stopservice: 서버에서 기기로 서비스 종료`
  controller.addJavaScriptHandler(
      handlerName: "stopservice",
      callback: (arg) {
        stopService();
      });

  //servreq: 서버로 서비스 관련 상태값 전달
  controller.addJavaScriptHandler(
      handlerName: "servreq",
      callback: (arg) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Request(false)));
        //requestPermission();
        //print("herer run");
      });
}
