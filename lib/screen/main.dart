import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zipsmobile_f/screen/request.dart';
import 'package:zipsmobile_f/util.dart';
import 'package:zipsmobile_f/webview/webview.dart';

import '../globals.dart';
import '../service.dart';

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();

    locPermissionCheck().then((value) => (value) ? startService() : {});
  }

  final MethodChannel channel = new MethodChannel('app.zips.ai/channel');
  Future<void> clcik() async {
    try {
      await channel.invokeMethod('service', {"macid": macid});
    } catch (e) {
      print("err : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    f_f();

    return WillPopScope(
        child: Container(child: getwebview()
            // Text('test mode'),
            // alignment: Alignment.center,
            ),
        onWillPop: () {
          setState(() {
            closepop();
          });
          return Future(() => false);
        });
  }
}
