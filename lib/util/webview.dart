import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:zipsai_mobile/service/service.dart';
import 'package:zipsai_mobile/util/file.dart';
import '../screen/request.dart';
import 'globals.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zipsai_mobile/screen/request.dart';
import 'package:zipsai_mobile/util/globals.dart';

InAppWebViewController? _webViewController;
InAppWebView? _inAppWebView;

void InitWebView(BuildContext context) {
  var body = getQueryBody();

  startService();

  var urlreq = URLRequest(
      url: Uri.parse(servHttpsAdr),
      method: 'POST',
      body: Uint8List.fromList(utf8.encode(body)));

  _inAppWebView = InAppWebView(
    initialUrlRequest: urlreq,
    initialOptions: getOptions(),
    onWebViewCreated: (InAppWebViewController controller) {
      controllerSetHandler(controller, context);
      _webViewController = controller;

      //print('$body');
      controller.postUrl(
          url: Uri.parse(servHttpsAdr),
          postData: Uint8List.fromList(utf8.encode(body)));
    },
  );
}

Widget? getwebview(BuildContext context) {
  return _inAppWebView;
}

void closepop() {
  //print('test here');
  // _webViewController?.goBack();
  _webViewController?.loadUrl(
      urlRequest: URLRequest(url: Uri.parse("javascript:goback()")));
}

String getQueryBody() {
  // 앱 버전
  var appver = "ver=$version";
  // 시니어 모드 확인

  var macidquery = "macid=$macid";

  var sentemp = getData(SENIOR);
  if (sentemp == "") sentemp = "0";

  var senior = "senior=${sentemp}";

  // 로그인 정보 확인 - 있으면 자동 로그인
  var login_idpw = getData(LOGININFO);
  var loginfo = "";
  if (login_idpw != '') {
    var token = login_idpw.split(',,');
    var id = token[0];
    var pass = token[1];
    //body += "&id=$id&pw=$pass";
    loginfo = "&id=$id&pw=$pass";
  }
  // 서비스가 실행 중인지 확인
  var servon = "&servon=$servEnable";
  // 서비스가 실행 가능한지 확인
  var servenable = "servenable=$servEnable";

  var result = "$appver&$macidquery&$senior&$servon&$servenable$loginfo";
  //var result = "$appver&$senior$loginfo";

  print(result);
  //print(result);

  return result;
}

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

/// WebView 설정 값 가져오는 함수
InAppWebViewGroupOptions getOptions() {
  return _options;
}

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
