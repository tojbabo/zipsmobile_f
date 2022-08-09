import 'dart:developer';

import 'package:flutter/material.dart';
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
  late List<wifi> ssid_list;
  late TextEditingController ssid_text;

  @override
  void initState() {
    super.initState();
    ssid_list = [];
    ssid_text = TextEditingController(text: "sss");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _WifiScan();
      setState(() {});
      log("called");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onTap: () => {FocusScope.of(context).unfocus()},
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                children: <Widget>[
                  Container(
                      height: 70,
                      decoration: const BoxDecoration(color: Colors.grey),
                      child: Center(
                        child: ElevatedButton(
                            child: Text("click me"),
                            onPressed: () => {
                                  setState(() {
                                    ssid_list.add(wifi("test", 44));
                                  }),
                                }),
                      )),
                  Expanded(
                      child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                                top: BorderSide(color: Colors.white, width: 2),
                                bottom:
                                    BorderSide(color: Colors.white, width: 2)),
                          ),
                          child: MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              child: ListView.builder(
                                itemCount: ssid_list.length,
                                itemBuilder: (BuildContext context, int idx) {
                                  return Container(
                                      alignment: Alignment.centerLeft,
                                      height: 50,
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey,
                                                  width: 2))),
                                      child: GestureDetector(
                                          onTap: () {
                                            log("good $idx");
                                            ssid_text.text =
                                                ssid_list[idx].ssid;
                                          },
                                          child: Row(children: [
                                            Expanded(
                                                child: Text(
                                              ssid_list[idx].ssid,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            )),
                                            Text("${ssid_list[idx].power}")
                                          ])));
                                },
                              )))),
                  Container(
                      height: 50,
                      child: FractionallySizedBox(
                        widthFactor: 1,
                        child: Row(children: [
                          const Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text("SSID")),
                          Expanded(
                              child: TextField(
                            controller: ssid_text,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "SSID"),
                          )),
                          const Padding(
                              padding: EdgeInsets.only(left: 20, right: 10),
                              child: Text("Passwd")),
                          const Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Password"),
                          )),
                          const SizedBox(
                            width: 20,
                          )
                        ]),
                      ))
                ],
              ),
            )));
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
            ssid_list.clear();
            var templist = accesspoint.map((e) => e).toList();

            templist.sort(((a, b) => a.level.compareTo(b.level)));
            templist.reversed.forEach((element) {
              //ssids.add("${element.ssid}[${element.level}]");
              ssid_list.add(wifi(element.ssid, element.level));
            });
          }
        }
      }
    } else {
      log("no its disable");
    }
  }
}

class wifi {
  String ssid;
  int power;
  wifi(this.ssid, this.power);
}