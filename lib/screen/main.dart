import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zipsai_mobile/util/webview.dart';

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xff141620)),
      home: MainPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    InitWebView(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Container(
                // margin: EdgeInsets.only(
                //     bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Getwebview(context)),
          ),
        ),
        onWillPop: () {
          setState(() {
            ClosePop();
          });
          return Future(() => false);
        });
  }
}
