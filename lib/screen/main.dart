import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:zipsai_mobile/util/webview.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
    return WithForegroundTask(
        child: WillPopScope(
            child: Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Getwebview(context)),
            onWillPop: () {
              setState(() {
                ClosePop();
              });
              return Future(() => false);
            }));
  }
}
