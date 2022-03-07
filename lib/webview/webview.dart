import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:zipsmobile_f/file.dart';
import 'package:zipsmobile_f/webview/controller.dart';

import '../globals.dart';
import 'options.dart';

InAppWebViewController? _webViewController;

Widget getwebview(BuildContext context) {
  var urlreq =
      URLRequest(url: Uri.parse(g__servHttpsAdr + '?ver=' + g__version));

  var tmp = getData('login');
  if (tmp != '') {
    var token = tmp.split(',,');
    var id = token[0];
    var pass = token[1];
    urlreq = URLRequest(
        url: Uri.parse(g__servHttpsAdr),
        method: 'POST',
        body:
            Uint8List.fromList(utf8.encode("id=$id&pw=$pass&ver=$g__version")));
  }

  return InAppWebView(
    initialUrlRequest: urlreq,
    initialOptions: getOptions(),
    onWebViewCreated: (InAppWebViewController controller) {
      controllerSetHandler(controller, context);
      _webViewController = controller;
    },
  );
}

void closepop() {
  //print('test here');
  // _webViewController?.goBack();
  _webViewController?.loadUrl(
      urlRequest: URLRequest(url: Uri.parse("javascript:goback()")));
}
