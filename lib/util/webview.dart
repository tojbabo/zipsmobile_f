import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:zipsai_mobile/service/service.dart';
import 'package:zipsai_mobile/util/file.dart';
import '../ROM.dart';
import '../screen/request.dart';
import '../RAM.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zipsai_mobile/screen/request.dart';
import 'package:zipsai_mobile/RAM.dart';

import 'etc.dart';

InAppWebViewController? _webViewController;
InAppWebView? _inAppWebView;

/// WebView 설정 값
InAppWebViewGroupOptions _options = InAppWebViewGroupOptions(
  crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      supportZoom: false),
  android: AndroidInAppWebViewOptions(
    useHybridComposition: true,
  ),
  ios: IOSInAppWebViewOptions(
    allowsInlineMediaPlayback: true,
  ),
);

// webview 생성. 초기화
void InitWebView(BuildContext context) {
  var body = _GetQueryBody();
  //StartService();

  var urlreq = URLRequest(
      url: Uri.parse(gServHttpsAdr),
      method: 'POST',
      body: Uint8List.fromList(utf8.encode(body)));

  _inAppWebView = InAppWebView(
    initialUrlRequest: urlreq,
    initialOptions: _options,
    onConsoleMessage: (controller, msg) {
      log('[console] $msg');
    },
    onWebViewCreated: (InAppWebViewController controller) {
      _ControllerSetHandler(controller, context);
      _webViewController = controller;

      controller.postUrl(
          url: Uri.parse(gServHttpsAdr),
          postData: Uint8List.fromList(utf8.encode(body)));
    },
  );
}

// 생성된. webview 반환
Widget? Getwebview(BuildContext context) {
  return _inAppWebView;
}

// [안드로이드] 뒤로가기 시 발생 이벤트
void ClosePop() {
  _webViewController?.loadUrl(
      urlRequest: URLRequest(url: Uri.parse("javascript:goback()")));
}

// webview 생성 시 post 바디 생성
String _GetQueryBody() {
  // 앱 버전
  var appver = "ver=$version";

  // macid
  var macidquery = "macid=$gMacId";

  // 시니어모드
  var senior = "senior=$gSeniorMode";

  // 로그인 정보 확인 - 있으면 자동 로그인
  var loginfo = "";
  if (gId != '' && gPw != '') {
    loginfo = "&id=$gId&pw=$gPw";
  }

  // 서비스 권한 확인
  var servenable = "servenable=$gServEnable";

  // 서비스 실행 여부
  var servon = "servon=$gServOn";

  // 서비스 자동 실행
  var servautorun = "autoserv=$gServAuto";

  var result = "$appver" +
      "&$macidquery" +
      "&$senior" +
//      "&$servon" +
//      "&$servenable" +
//      "&$servautorun" +
      "$loginfo";
  //var result = "$appver&$senior$loginfo";

  log(result);
  //print(result);

  return result;
}

// webview 자바 스크립트 핸들러
void _ControllerSetHandler(
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

  //URL: 업데이트 URL전송
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
        log("call toast");
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

  // 자동로그인 설정
  const _AUTOLOGIN = "autologin";
  controller.addJavaScriptHandler(
      handlerName: _AUTOLOGIN,
      callback: (arg) async {
        bool flag = arg.cast<bool>()[0];
        log('[$_AUTOLOGIN] mode: $flag');
        if (flag) {
          SetData(LOGININFO, '$gId,,$gPw');
        } else {
          RemoveData(LOGININFO);
        }
      });

  //logininfo[적용 중]: 로그인 정보 가져옴
  controller.addJavaScriptHandler(
      handlerName: 'logininfo',
      callback: (arg) {
        String param = arg.cast<String>()[0];
        var datas = param.split(',');
        gId = datas[0];
        gPw = datas[1];
      });

  const _APPINFO = "getappinfo";
  controller.addJavaScriptHandler(
      handlerName: _APPINFO,
      callback: (arg) async {
        var data = await GetSettingData();
        var temp = gAppInfo;
        if (data == "no") {
          temp += ",interval: "
              ",mindistance: "
              ",minaccuracy: ";
        } else {
          var datas = data.split(',');
          temp += ",interval: ${datas[0]}"
              ",mindistance: ${datas[1]}"
              ",minaccuracy: ${datas[2]}";
        }
        log("[$_APPINFO] called: ${temp}");

        return temp;
      });

  //getdeviceid[구현]: 기기 id 전달
  controller.addJavaScriptHandler(
      handlerName: "getdeviceid",
      callback: (arg) {
        return gMacId;
      });

  // 노인모드 비/활성화
  const _SENIORMODE = "senior";
  controller.addJavaScriptHandler(
      handlerName: _SENIORMODE,
      callback: (arg) {
        int flag = arg.cast<int>()[0];
        SetData(SENIOR, '$flag');
        log('[$_SENIORMODE] mode: $flag');
      });

  ///서비스 관련부
  // 서버로 서비스 관련 상태값 전달
  const _APPSTATE = "appstate";
  controller.addJavaScriptHandler(
      handlerName: _APPSTATE,
      callback: (arg) async {
        await IsRunService();

        var num = 0;
        if (gId != '') num = 1;

        var res = "$gServEnable"
            ",$gServAuto"
            ",$gServOn"
            ",$gSeniorMode"
            ",$num";

        log("[$_APPSTATE] called : ${res}");

        return res;
      });

  //startservice: 서버에서 기기로 서비스 실행
  controller.addJavaScriptHandler(
      handlerName: "startservice",
      callback: (arg) async {
        int flag = arg.cast<int>()[0];
        if (flag == 1 || (gServEnable == 1 && gServAuto == 1)) {
          return await StartService();
        }

        return 0;
      });

  //getlastloc: 최종 위치 전달
  controller.addJavaScriptHandler(
      handlerName: "lastLocation",
      callback: (arg) async {
        var result = await GetNowLocation();
        return result;
        //print("receive data from server $location");
      });

  //isrunservice: 서버에서 기기로 서비스 실행중인지 파악
  controller.addJavaScriptHandler(
      handlerName: "isrunservice",
      callback: (arg) {
        var v = gServOn;
        return v;
      });

  //stopservice: 서버에서 기기로 서비스 종료`
  controller.addJavaScriptHandler(
      handlerName: "stopservice",
      callback: (arg) {
        StopService();
      });

  //servreq: 권한 확인. 권한이 확인된 경우 true return
  controller.addJavaScriptHandler(
      handlerName: "servreq",
      callback: (arg) async {
        var flag = await LocPermissionCheck();
        return flag;
      });

  //SwitchServAuto: 서버에서 기기로 서비스 실행
  controller.addJavaScriptHandler(
      handlerName: "SwitchServAuto",
      callback: (arg) async {
        int param = int.parse(arg.cast<String>()[0]);
        gServAuto = param;

        SetData(AUTORUNSERV, '$gServAuto');
        return gServAuto;
      });
}
