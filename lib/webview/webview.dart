import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:zipsmobile_f/webView/controller.dart';
import 'package:zipsmobile_f/webview/options.dart';

import 'package:zipsmobile_f/globals.dart';

InAppWebViewController? _webViewController;

Widget getwebview() {
  return InAppWebView(
    initialUrlRequest: URLRequest(url: Uri.parse(g__servHttpAdr)),
    initialOptions: getOptions(),
    onWebViewCreated: (InAppWebViewController controller) {
      controllerSetHandler(controller);

      cookieManager
          .getCookie(url: Uri.parse(g__servHttpsAdr), name: 'autologin')
          .then((data) {
        if (data?.value != null) {
          var tmp = data?.value.split(',,');
          var id = tmp[0];
          var passwd = tmp[1];

          var postData = Uint8List.fromList(utf8.encode("id=$id&pw=$passwd"));
          controller.postUrl(
              url: Uri.parse(g__servHttpsAdr), postData: postData);
        } else {
          cookieManager.deleteAllCookies();
        }
      });

      _webViewController = controller;
    },
  );
}

void closepop() {
  // print('test here');
  // _webViewController?.goBack();
  _webViewController?.loadUrl(
      urlRequest: URLRequest(url: Uri.parse("javascript:goback()")));
}
