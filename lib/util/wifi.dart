import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:zipsai_mobile/util/etc.dart';
import 'package:zipsai_mobile/util/security.dart';
import 'package:udp/udp.dart';

class Wifi {
  String ssid;
  int power;
  Wifi(this.ssid, this.power);
}

class Connector {
  int _PORT_UDP = 61001;
  int _PORT_TCP = 61002;
  bool is_connect_tcp = false;
  security s = security();
  Connector();
  /** 테스트용
   * 자기자신한테 udp 패킷 전송
   */
  void sender() async {
    var sender = await UDP.bind(Endpoint.any(port: const Port(61000)));

    var dataLength = await sender.send(s.Test_Encrypt('sexiguy').codeUnits,
        Endpoint.unicast(InternetAddress("127.0.0.1"), port: Port(_PORT_UDP)));
    //Endpoint.broadcast(port: const Port(61001)));

    log("$dataLength bytes sent.");
    sender.close();
  }

  /** udp 수신자 생성
   * 
   */
  void Start_Listener() async {
    var receiver = await UDP.bind(Endpoint.any(port: Port(_PORT_UDP)));
    receiver.asStream().listen((datagram) async {
      if (datagram != null) {
        var str = String.fromCharCodes(datagram.data);
        // log("${datagram.address} / ${datagram.port}");

        // 실제 데이터인 경우
        if (str.length == 1024) {
          var real_data = s.Get_UDP_Data(str);
          // log('real data[${str.length}] : ${real_data}');
          json j = json(real_data);

          if (j.get('bcast') == '1') {
            var ctrl_ip = await DecodeIp(j.get('ip')!);
            var dh_temp = j.get('netid')!;

            if (dh_temp.length > 5) {
              var ctrl_dong = int.parse(dh_temp.substring(0, 4));
              var ctrl_ho = int.parse(dh_temp.substring(4));
            }

            if (is_connect_tcp == false) Start_TCP(ctrl_ip);

            /**
             * 조절기로 tcp 연결.
             * 2byte, 2byte, payload
             * payload_size, payload_type(app: 0xff04), payload(json)
             * payload
             */

          }
        }
        // 테스트 데이터인 경우
        else {
          // log("recv data[${str.length}] : ${str}[${str.length}]");
        }
      }
    }, onDone: () {
      receiver.close();
      log('recv done');
    });
    log("go listen");
  }

  /** tcp 연결 시도 
   * ip: 연결 대상
  */
  void Start_TCP(String ip) async {
    is_connect_tcp = true;
    // log('start connect');
    try {
      Socket s =
          await Socket.connect(ip, _PORT_TCP, timeout: Duration(seconds: 5));
      s.listen((event) {
        log(utf8.decode(event));
      });

      var first_msg = makepacket((await Get_My_Ip())!);
      // log('first msg is : ${first_msg}');
      s.add(utf8.encode(first_msg));

      await Future.delayed(Duration(seconds: 5));
      s.close();
    } catch (e) {
      // log("maybe timeout : ${e}");
    }
    is_connect_tcp = false;
  }
}

/** ipnumber를 ip로 해석하는 함수
 * ipnumber: 32비트 ip를 숫자로 치환한 값. 
 */
Future<String> DecodeIp(String ipnumber) async {
  var bin = int.parse(ipnumber).toRadixString(2);
  bin = bin.padLeft(32, '0');
  var ip = "${int.parse(bin.substring(24, 32), radix: 2)}."
      "${int.parse(bin.substring(16, 24), radix: 2)}."
      "${int.parse(bin.substring(8, 16), radix: 2)}."
      "${int.parse(bin.substring(0, 8), radix: 2)}";

  return ip;
}

String makepacket(String myip) {
  //'{"pairing":{"type":1,"ip":32,"serial":"0000000069","id":1,"hwaddr":"b00247a70859","rssi":-48}}';
  var ips = myip.split('.');

  var payload =
      '{"pairing":{"type":1,"ip":${ips[3]},"serial":"0000000069","id":1,"hwaddr":"b00247a70859","rssi":-48}}';

  List<int> bin = [];

  var payload_bin = payload.codeUnits;
  var payload_type = 0xFF04;
  var payload_length = payload.length;

  bin.add((payload_length / 256).toInt());
  bin.add((payload_length) % 256);
  bin.add((payload_type / 256).toInt());
  bin.add((payload_type) % 256);

  for (var num in payload_bin) {
    bin.add(num);
  }

  return String.fromCharCodes(bin);
}

Future<String?> Get_My_Ip() async {
  var info = NetworkInfo();
  var ip = await info.getWifiIP();
  return ip;
}
