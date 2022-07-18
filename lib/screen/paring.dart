import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wifi_scan/wifi_scan.dart';

class ParingApp extends StatelessWidget {
  const ParingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: const ParingPage(),
    );
  }
}

class ParingPage extends StatefulWidget {
  const ParingPage({Key? key}) : super(key: key);

  @override
  _ParingPage createState() => _ParingPage();
}

class _ParingPage extends State<ParingPage> {
  late List<String> ssids = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      log("after load");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: ssids.length,
            itemBuilder: (BuildContext context, int idx) {
              return Container(
                height: 50,
                color: Colors.red,
                child: Center(
                    child: Text(
                  ssids[idx],
                  style: TextStyle(fontSize: 15),
                )),
              );
            },
          )),
          Container(
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded(
                    child: SizedBox(
                  height: double.infinity,
                  child: ElevatedButton(
                    child: Text("A"),
                    onPressed: () async {
                      await _WifiScan();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                  ),
                )),
                Expanded(
                    child: SizedBox(
                  height: double.infinity,
                  child: ElevatedButton(
                    child: Text("B"),
                    onPressed: () => {log("fuck")},
                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                  ),
                )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _WifiScan() async {
    if (await WiFiScan.instance.hasCapability()) {
      log("scan enable");
      var err = await WiFiScan.instance.startScan();
      if (err != null) {
        log(err.toString());
      } else {
        var result = await WiFiScan.instance.getScannedResults();
        if (result.hasError) {
          log(err.toString());
        } else {
          var accesspoint = result.value;
          if (accesspoint != null) {
            ssids.clear();
            var templist = accesspoint.map((e) => e).toList();

            templist.sort(((a, b) => a.level.compareTo(b.level)));
            templist.reversed.forEach((element) {
              ssids.add("${element.ssid}[${element.level}]");
            });
          }
        }
      }
    } else {
      log("no its disable");
    }
  }
}
