import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:zipsai_mobile/service/service.dart';
import 'package:zipsai_mobile/util/file.dart';
import 'package:zipsai_mobile/webview/controller.dart';

import '../util/globals.dart';
import 'options.dart';

InAppWebViewController? _webViewController;

Widget getwebview(BuildContext context) {
  var body = getQueryBody();

  if (servEnable == 1) startService();

  var urlreq = URLRequest(
      url: Uri.parse(servHttpsAdr),
      method: 'POST',
      body: Uint8List.fromList(utf8.encode(body)));

  return InAppWebView(
    initialUrlRequest: urlreq,
    initialOptions: getOptions(),
    onWebViewCreated: (InAppWebViewController controller) {
      controllerSetHandler(controller, context);
      _webViewController = controller;

      //print('$body');
      controller.postUrl(
        url: Uri.parse(servHttpsAdr), 
        postData: Uint8List.fromList(utf8.encode(body))
        );
    },
  );
  
  // return 
  // InAppWebView(
  //   initialUrlRequest:
  //     URLRequest(url: Uri.parse("https://inappwebview.dev/")),
  //     initialOptions: getOptions(),
  //     onWebViewCreated: (controller) {
  //       _webViewController = controller;
  //     },
  //     onLoadStart: (controller, url) {
  //     },
  //     androidOnPermissionRequest: (controller, origin, resources) async {
  //     },
  //     shouldOverrideUrlLoading: (controller, navigationAction) async {
  //     },
  //     onLoadStop: (controller, url) async {
  //     },
  //     onLoadError: (controller, url, code, message) {
  //     },
  //     onProgressChanged: (controller, progress) {
  //     },
  //     onUpdateVisitedHistory: (controller, url, androidIsReload) {
  //     },
  //     onConsoleMessage: (controller, consoleMessage) {
  //     }
  //   );
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

  var sentemp = getData(SENIOR);
  if(sentemp == "") sentemp = "0";
 

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

  var result = "$appver&$senior&$servon&$servenable$loginfo";
  //var result = "$appver&$senior$loginfo";

  //print(result);

  return result;
}
