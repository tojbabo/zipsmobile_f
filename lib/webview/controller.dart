import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:zipsmobile_f/globals.dart';

int height = 0;
void controllerSetHandler(InAppWebViewController controller) {
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
        exit(0);
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

        cookieManager.setCookie(
            url: Uri.parse(g__servHttpsAdr),
            name: 'autologin',
            value: msg,
            domain: '.zips.ai',
            isSecure: true);

        // if(msg.length<1) 쿠키에 fail 저장
        // else 쿠키에 msg 저장
      });

  //logout[구현]
  controller.addJavaScriptHandler(
      handlerName: "logout",
      callback: (arg) {
        cookieManager.deleteCookie(
          url: Uri.parse(g__servHttpsAdr),
          name: 'autologin',
          domain: '.zips.ai',
        );
        //쿠키에 페일 저장
      });

  //getlastinfo: info 리턴
  controller.addJavaScriptHandler(
      handlerName: "getlastinfo",
      callback: (arg) {
        // return vals.getinfo()
      });

  //getlastloc: 최종 위치 전달
  controller.addJavaScriptHandler(
      handlerName: "getlastloc",
      callback: (arg) {
        //서비스에서 라스트 위치를 얻어옴
        // 얻어온 위치 리턴
      });

//getdeviceid: 기기 id 전달
  controller.addJavaScriptHandler(
      handlerName: "getdeviceid",
      callback: (arg) {
        return 999;
      });
}
