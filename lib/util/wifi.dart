import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import 'package:wifi_hunter/wifi_hunter.dart';

import 'package:zipsai_mobile/util/etc.dart';
import 'package:zipsai_mobile/util/security.dart';
import 'package:udp/udp.dart';

class Wifi {
  String ssid;
  int power;
  Wifi(this.ssid, this.power);
}

class Connector {
  static final Connector instance = Connector._internal();
  final int _PORT_UDP = 61001;
  final int _PORT_TCP = 61002;
  int rssi = 0;
  bool is_udp_run = false;
  bool is_connect_tcp = false;
  late int _time;

  String netid = '';

  UDP? udp_receiver;
  Socket? sock_tcp;
  Security security = Security();
  factory Connector() {
    return instance;
  }
  Connector._internal() {
    log('[connector]init');
  }

  /// udp 수신자 생성 - 네트워크 내 UDP 패킷을 지속적으로 수신
  void Listener_UDP(Function Connect_Callback) async {
    if (udp_receiver != null) return;
    udp_receiver = await UDP.bind(Endpoint.any(port: Port(_PORT_UDP)));
    _time = 3;
    Timer timer_udp = Timer.periodic(Duration(seconds: 1), (timer) {
      // _time--;
      if (_time == 0) {
        log('[UDP timer] timeout');
        udp_receiver?.close();
        timer.cancel();
        Connect_Callback('');
      }
    });

    udp_receiver?.asStream().listen((datagram) async {
      // 수신한 데이터가 존재하는 경우
      if (datagram != null) {
        var str = String.fromCharCodes(datagram.data);
        // log("${datagram.address} / ${datagram.port}");
        // 데이터가 udp 브로드 캐스트인 경우
        if (str.length == 1024) {
          var payload = security.Get_UDP_Data(str);
          // log(payload);
          json j = json(payload);

          // 메인 조절기가 보내는 연결 신호인 경우
          if (j.get('bcast') == '1') {
            _time = 10;
            var ctrlIp = await Decode_IP(j.get('ip')!);
            var ctrlDongho = j.get('netid');
            if (ctrlDongho != null) {
              netid = ctrlDongho;

              // 동-호수 분할. 연결하려는 조절기가 맞는지 확인
              if (ctrlDongho.length > 5) {
                var ctrlDong = int.parse(ctrlDongho.substring(0, 4));
                var ctrlHo = int.parse(ctrlDongho.substring(4));
              }
            } else {
              ctrlDongho = '-';
            }

            // 새로 연결 - 연결이 성공한 경우 자동 ECHO
            if (is_connect_tcp == false) {
              Connect_TCP(ctrlIp).then((value) {
                // 연결이 안된 경우
                if (!value) {
                } else {
                  Connect_Callback(ctrlDongho);
                }
              });
            }
            // 연결된 상태 - ECHO
            else {
              Connect_Callback(ctrlDongho);
              TCP_Echoing();
            }
          }
        }
        // 데이터가 일반 데이터인 경우 - 단순 출력
        else {
          log("recv data[${str.length}] : ${str}[${str.length}]");
          security.Test_Decrypt(str);
        }
      }
      // 수신데이터 X  -> 에러?
      else {
        log("it is null");
      }
    },
        // listen 종료 이벤트
        onDone: () {
      udp_receiver = null;
    });
  }

  /// TCP, UDP 통신 관련 객체들 전부 해제
  bool Disconnect_TCPUDP() {
    sock_tcp?.close();
    udp_receiver?.close();

    return true;
  }

  /// 해당 IP 주소로 TCP 연결 시도
  Future<bool> Connect_TCP(String ip) async {
    try {
      // sock_tcp = await Socket.connect("127.0.0.1", _PORT_TCP,
      sock_tcp = await Socket.connect(ip, _PORT_TCP,
          timeout: new Duration(seconds: 5));
      is_connect_tcp = true;

      sock_tcp?.listen((event) {
        log("recv msg is: ${String.fromCharCodes(event)}");
      }, onDone: () {
        log('disconnected');
        is_connect_tcp = false;
        sock_tcp = null;
      }, onError: (e) {
        log('err is:${e.toString()}');
        is_connect_tcp = false;
      });
      log('[Connect_TCP]success tcp conn');
      TCP_Echoing();
    } catch (e) {
      // 타임아웃 된 경우
      is_connect_tcp = false;
    }
    return is_connect_tcp;
  }

  /// TCP 통신으로 에코잉 메시지를 보냄
  Future<bool> TCP_Echoing() async {
    if (sock_tcp == null) return false;

    var msg = Packet_Echo((await Get_My_Ip())!);
    sock_tcp?.add(msg);

    return true;
  }

  /// TCP 통신으로 와이파이 정보를 보냄
  Future<String> TCP_WiFi_Data_Send(String ssid, String pw) async {
    if (sock_tcp == null) {
      return '';
    } else if (netid == '') {
      return '';
    }

    var msg = Packet_Wifi(netid, ssid, pw);
    log("msg si: ${String.fromCharCodes(msg)}");
    sock_tcp?.add(msg);

    _time = 4;

    return String.fromCharCodes(msg);
  }

  /// 와이파이의 수신 신호 세기를 구함
  Future<void> Get_RSSI() async {
    var info = NetworkInfo();
    var nowSsid = await info.getWifiName();
    try {
      WiFiHunterResult wiFiHunterResult = WiFiHunterResult();
      wiFiHunterResult = (await WiFiHunter.huntWiFiNetworks)!;
      for (var i = 0; i < wiFiHunterResult.results.length; i++) {
        if ('"${wiFiHunterResult.results[i].SSID}"' == nowSsid) {
          rssi = wiFiHunterResult.results[i].level;
          return;
        }
      }
    } catch (e) {
      log("something wrong ${e.toString()}");
    }
    rssi = 0;
  }

  /// ipnumber를 ip로 해석하는 함수
  /// ipnumber: 32비트 ip를 숫자로 치환한 값.
  Future<String> Decode_IP(String ipnumber) async {
    var bin = int.parse(ipnumber).toRadixString(2);
    bin = bin.padLeft(32, '0');
    var ip = "${int.parse(bin.substring(24, 32), radix: 2)}."
        "${int.parse(bin.substring(16, 24), radix: 2)}."
        "${int.parse(bin.substring(8, 16), radix: 2)}."
        "${int.parse(bin.substring(0, 8), radix: 2)}";

    return ip;
  }

  /// 에코잉에 사용되는 패킷을 만드는 함수
  List<int> Packet_Echo(String myip) {
    //'{"pairing":{"type":1,"ip":32,"serial":"0000000069","id":1,"hwaddr":"b00247a70859","rssi":-48}}';
    var ips = myip.split('.');

    var payload =
        '{"pairing":{"type":99,"ip":${ips[3]},"serial":"1234567890","id":88,"hwaddr":"111111111111","rssi":${rssi}}}'
            .replaceAll(" ", "");

    List<int> bin = [];

    var payloadBin = payload.codeUnits;
    var payloadType = 0xFF01;
    var payloadLength = payload.length;

    bin.add((payloadLength / 256).toInt());
    bin.add((payloadLength) % 256);
    bin.add((payloadType / 256).toInt());
    bin.add((payloadType) % 256);

    for (var i = 0; i < payloadBin.length; i++) {
      bin.add(payloadBin[i]);
    }
    return bin;
  }

  /// 전송할 와이파이 정보 패킷을 만드는 함수
  List<int> Packet_Wifi(String netid, String ssid, String passwd) {
    //{"pairing":{"netid": 1080401, "type": 99, "serial": "1234567890", "ssid": "01080401", "pwd": "sc01080401" }}
    var payload =
        '{"pairing":{"netid": $netid, "type": 99, "serial": "1234567890", "ssid": "$ssid", "pwd": "$passwd" }}'
            .replaceAll(" ", "");

    List<int> bin = [];

    var payloadBin = payload.codeUnits;
    var payloadType = 0xFF01;
    var payloadLength = payload.length;

    bin.add((payloadLength / 256).toInt());
    bin.add((payloadLength) % 256);
    bin.add((payloadType / 256).toInt());
    bin.add((payloadType) % 256);

    for (var i = 0; i < payloadBin.length; i++) {
      bin.add(payloadBin[i]);
    }
    return bin;
  }

  /// 내 디바이스의 IP 주소를 얻는 함수
  Future<String?> Get_My_Ip() async {
    var info = NetworkInfo();
    var ip = await info.getWifiIP();
    return ip;
  }

  /*테스트 함수 */
  /*  자기자신한테 udp 패킷 전송 */
  void test_UDP_sender() async {
    var sender = await UDP.bind(Endpoint.any(port: const Port(61000)));

    // 유니캐스트, 일반적인 데이터 전송
    // var dataLength = await sender.send(security.Test_Encrypt('sexiguy').codeUnits,
    //     Endpoint.unicast(InternetAddress("127.0.0.1"), port: Port(_PORT_UDP)));

    // 브로드 캐스트
    var dataLength = await sender.send(
        security.Test_Encrypt('sexiguy').codeUnits,
        Endpoint.broadcast(port: Port(_PORT_UDP)));
    // log("$dataLength bytes sent.");
    sender.close();
  }

  /* 테스트 tcp listen server */
  void test_tcp_server() async {
    log('test server on');
    ServerSocket serverSocket =
        await ServerSocket.bind(InternetAddress.anyIPv4, _PORT_TCP);
    serverSocket.listen((event) {
      event.listen((event) {
        log("listen data is: ${utf8.decode(event)}");
      });
    });
  }
}
