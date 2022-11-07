import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../util/wifi.dart';

GlobalKey<_ParingPage> paringKey = GlobalKey();

class ParingApp extends StatelessWidget {
  const ParingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ParingPage(key: paringKey);
}

class ParingPage extends StatefulWidget {
  const ParingPage({Key? key}) : super(key: key);

  @override
  _ParingPage createState() => _ParingPage();
}

class _ParingPage extends State<ParingPage> {
  late List<Wifi> ssid_list;
  late TextEditingController TE_ssid;
  late TextEditingController TE_password;
  late String TE_sn;
  Connector connector = Connector();

  @override
  void initState() {
    super.initState();
    ssid_list = [];
    TE_ssid = TextEditingController();
    TE_password = TextEditingController();
    TE_sn = '';

    // 새로 연결
    //connector.Listener_UDP(Callback_Connect);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        _WifiScan();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onTap: () => {FocusScope.of(context).unfocus()},
            child: Container(
              color: Color.fromARGB(255, 54, 54, 54),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                children: <Widget>[
                  // 뒤로가기 ,시리얼번호
                  Expanded(
                      flex: 0,
                      child: SizedBox(
                          height: 50.0,
                          child: Container(
                              margin: EdgeInsets.only(
                                  left: 10.0, right: 10.0, bottom: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Row(children: <Widget>[
                                IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      connector.Disconnect_TCPUDP();
                                      Navigator.pop(context);
                                    }),
                                const Text("SN:   "),
                                Text(TE_sn)
                              ])))),
                  // 와이파이 목록 리스트
                  Expanded(
                      child: Container(
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0)),
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
                                                  width: 1))),
                                      child: GestureDetector(
                                        onTap: () =>
                                            TE_ssid.text = ssid_list[idx].ssid,
                                        child: SizedBox(
                                            child: Container(
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
                                              ]),
                                              padding: EdgeInsets.only(
                                                  left: 15.0, right: 20.0),
                                            ),
                                            height: double.infinity),
                                      ));
                                },
                              )))),
                  // ssid, passwd 입력 칸, 데이터 전송 버튼
                  Expanded(
                    flex: 0,
                    child: SizedBox(
                        height: 130.0,
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 5.0),
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 5.0, top: 10.0, bottom: 30.0),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10)),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                        child: Padding(
                                      child: TextField(
                                        controller: TE_ssid,
                                        decoration: const InputDecoration(
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                            labelText: "SSID"),
                                      ),
                                      padding:
                                          const EdgeInsets.only(bottom: 2.5),
                                    )),
                                    Expanded(
                                        child: Padding(
                                      child: TextField(
                                        controller: TE_password,
                                        decoration: const InputDecoration(
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                            labelText: "Password"),
                                      ),
                                      padding: const EdgeInsets.only(top: 2.5),
                                    ))
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5.0, right: 10.0),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.black,
                                          minimumSize: const Size.fromWidth(
                                              double.infinity)),
                                      child: const Text("페어링"),
                                      onPressed: () {
                                        connector.TCP_WiFi_Data_Send(
                                                TE_ssid.text, TE_password.text)
                                            .then((value) {
                                          if (value == '') {
                                            value =
                                                "data is : ${TE_ssid.text}-${TE_password.text}";
                                          }
                                          Fluttertoast.showToast(
                                              msg: "페어링을 완료했습니다.");
                                        });
                                      }),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                ],
              ),
            )));
  }

  Future<void> _WifiScan() async {
    if (await WiFiScan.instance.hasCapability()) {
      log("do enable");
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
            setState(() {
              templist.reversed.forEach((element) {
                //ssids.add("${element.ssid}[${element.level}]");
                ssid_list.add(Wifi(element.ssid, element.level));
              });
            });
          }
        }
      }
    } else {
      log("no its disable");
    }

    for (var i = 0; i < 5; i++) {
      ssid_list.add(Wifi("fuck u ${i}", i));
    }
  }

  void Callback_Connect(String sn) {
    setState(() {
      TE_sn = sn;
    });
  }

  void SetSN(String sn) {
    setState(() {
      TE_sn = sn;
    });
  }
}
