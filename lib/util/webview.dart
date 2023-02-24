import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:zipsai_mobile/service/service.dart';
import 'package:zipsai_mobile/util/file.dart';
import '../ROM.dart';
import '../RAM.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
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
    onReceivedServerTrustAuthRequest: (ctrl, challenge) async {
      return ServerTrustAuthResponse(
          action: ServerTrustAuthResponseAction.PROCEED);
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

  // 서비스 권한 확인
  var servenable = "servenable=$gServEnable";

  // 서비스 실행 여부
  var servon = "servon=$gServOn";

  // 서비스 자동 실행
  var servautorun = "autoserv=$gServAuto";

  var result = "$appver" + "&$macidquery";
//      "&$servon" +
//      "&$servenable" +
//      "&$servautorun";

  return result;
}

/// webview 자바 스크립트 핸들러
void _ControllerSetHandler(
    InAppWebViewController controller, BuildContext context) {
  /// URL 전송 및 실행
  const _URL = "URL";
  controller.addJavaScriptHandler(
      handlerName: _URL,
      callback: (arg) {
        var msg = arg.cast<String>()[0];
        //print(msg);
        launch(msg);
      });

  /// toast 실행
  const _TOAST = "toast";
  controller.addJavaScriptHandler(
      handlerName: _TOAST,
      callback: (arg) {
        var msg = arg.cast<String>()[0];
        Fluttertoast.showToast(msg: msg);
      });

  /// 앱 종료 이벤트
  const _CLOSE = "appclose";
  controller.addJavaScriptHandler(
      handlerName: _CLOSE,
      callback: (arg) {
        CookieManager().deleteAllCookies();
        Navigator.of(context).pop(true);
        SystemNavigator.pop();
      });

  /// 앱 정보 전달
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

  /* 서비스 관련 */
  /// 서버로 서비스 관련 상태값 전달
  const _APPSTATE = "appstate";
  controller.addJavaScriptHandler(
      handlerName: _APPSTATE,
      callback: (arg) async {
        await IsRunService();

        var res = "$gServEnable"
            ",$gServAuto"
            ",$gServOn";

        log("[$_APPSTATE] called : ${res}");

        return res;
      });

  /// 서비스 실행 명령
  const _START_SERVICE = "startservice";
  controller.addJavaScriptHandler(
      handlerName: _START_SERVICE,
      callback: (arg) async {
        int flag = arg.cast<int>()[0];
        if (flag == 1 || (gServEnable == 1 && gServAuto == 1)) {
          return await StartService();
        }

        return 0;
      });

  /// getlastloc: 최종 위치 전달
  controller.addJavaScriptHandler(
      handlerName: "lastLocation",
      callback: (arg) async {
        var result = await GetNowLocation();
        return result;
      });

  /// isrunservice: 기기가 서비스 실행 중인지 확인
  controller.addJavaScriptHandler(
      handlerName: "isrunservice",
      callback: (arg) {
        var v = gServOn;
        return v;
      });

  /// stopservice: 서비스 종료 명령
  controller.addJavaScriptHandler(
      handlerName: "stopservice",
      callback: (arg) {
        StopService();
      });

  /// servreq: 기기가 서비스 관련 권한이 허용됐는지 확인
  controller.addJavaScriptHandler(
      handlerName: "servreq",
      callback: (arg) async {
        var flag = await LocPermissionCheck();
        return flag;
      });

  /// SwitchServAuto: 서비스 자동 실행 여부 스위칭 명령
  controller.addJavaScriptHandler(
      handlerName: "SwitchServAuto",
      callback: (arg) async {
        int param = int.parse(arg.cast<String>()[0]);
        gServAuto = param;

        SetData(AUTORUNSERV, '$gServAuto');
        return gServAuto;
      });
}
