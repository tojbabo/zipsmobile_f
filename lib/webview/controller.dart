import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zipsmobile_f/file.dart';
import 'package:zipsmobile_f/globals.dart';

int height = 0;
void controllerSetHandler(
    InAppWebViewController controller, BuildContext context) {
  //alert: 서버에서 앱으로 알람
  controller.addJavaScriptHandler(
      handlerName: "alert",
      callback: (arg) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text('애플리케이션 버전이 낮습니다.\n최신 버전으로 업데이트하세요'),
                actions: <Widget>[
                  new TextButton(
                      onPressed: () {
                        launch(
                            'https://play.google.com/store/apps/details?id=com.softzen.hansungai');
                      },
                      child: new Text('업데이트')),
                ],
              );
            });
      });

  //tempsucc
  controller.addJavaScriptHandler(
      handlerName: "tempsucc",
      callback: (arg) {
        var temp = arg.cast<String>()[0];
        if (temp == '0') {
          // Toast 설정을 완료했습니다.
        } else {
          // Toast 설정중 오류 발생
        }
      });

  //appclose [구현]
  controller.addJavaScriptHandler(
      handlerName: "appclose",
      callback: (arg) {
        CookieManager().deleteAllCookies();
        //exit(0);
        SystemNavigator.pop();
      });

  //webheight[구현]: 웹 기장 받아서 저장
  controller.addJavaScriptHandler(
      handlerName: "webheight",
      callback: (arg) {
        height = arg.cast<int>()[0];
      });

  //appheight[구현]: 저장한 웹 기장 반환
  controller.addJavaScriptHandler(
      handlerName: "appheight",
      callback: (arg) {
        return height;
      });

  //savelogin[구현]: 자동로그인 설정
  controller.addJavaScriptHandler(
      handlerName: "autologin",
      callback: (arg) {
        String msg = arg.cast<String>()[0];
        inputData('login', msg);
      });

  //logout[구현]
  controller.addJavaScriptHandler(
      handlerName: "logout",
      callback: (arg) {
        CookieManager().deleteAllCookies();
        removeData('login');
      });

  //getlastinfo[구현]: info 리턴
  controller.addJavaScriptHandler(
      handlerName: "getappinfo",
      callback: (arg) {
        return g__appinfo;
      });

  //getlastloc: 최종 위치 전달
  controller.addJavaScriptHandler(
      handlerName: "getlastloc",
      callback: (arg) {
        //서비스에서 라스트 위치를 얻어옴
        // 얻어온 위치 리턴
      });

  //getdeviceid[구현]: 기기 id 전달
  controller.addJavaScriptHandler(
      handlerName: "getdeviceid",
      callback: (arg) {
        return macid;
      });
}
