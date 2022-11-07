import 'dart:developer';
import 'dart:math' as math;

import 'package:encrypt/encrypt.dart' as en;
import 'package:flutter/foundation.dart';

class Security {
  Security();

  String _KEY = '6531FEA2BB69586D892A87D50127C4D2';
  List<int> _KEY_ARY = [
    0x65,
    0x31,
    0xFE,
    0xA2,
    0xBB,
    0x69,
    0x58,
    0x6D,
    0x89,
    0x2A,
    0x87,
    0xD5,
    0x01,
    0x27,
    0xC4,
    0xD2
  ];

  /// app2조절기,
  /// 조절기가 브로드캐스트한 데이터에서 중요 부분을 추출하는 함수
  String Get_UDP_Data(String data) {
    var data_bin = data.codeUnits;
    //log("data_bin is: ${data_bin}");

    var payload = _Get_UDP_Payload(data_bin);

    var key = en.Key.fromBase16(_KEY);
    var iv = en.IV.fromBase16(_Get_UDP_IV(data_bin));

    var decrypter = en.Encrypter(en.AES(key, mode: en.AESMode.cbc));
    var result = decrypter.decrypt16(payload, iv: iv);

    return result;
  }

  String _Get_UDP_Payload(List<int> bindata) {
    var payload_length = bindata[3] +
        (bindata[2] * math.pow(2, 8)) +
        (bindata[1] * math.pow(2, 16)) +
        (bindata[0] * math.pow(2, 24));

    var payload_ary = bindata.sublist(20, payload_length.toInt() + 20);
    var payload = new String.fromCharCodes(payload_ary);

    var tempstr = "";
    for (var i = 0; i < payload_ary.length; i++) {
      tempstr += "${payload_ary[i].toRadixString(16).padLeft(2, '0')}";
    }

    return tempstr;
  }

  String _Get_UDP_IV(List<int> bindata) {
    var iv_ary = bindata.sublist(4, 20);
    var iv_str = "";
    for (var i = 0; i < iv_ary.length; i++) {
      iv_str += "${iv_ary[i].toRadixString(16).padLeft(2, '0')}";
    }

    return iv_str;
  }

  String Test_Encrypt(String testdata) {
    final key = en.Key.fromBase16(_KEY);
    final iv = en.IV.fromLength(16);
    final encrypter = en.Encrypter(en.AES(key, mode: en.AESMode.cbc));
    return encrypter.encrypt(testdata, iv: iv).base64;
  }

  void Test_Decrypt(String testdata) {
    final key = en.Key.fromBase16(_KEY);
    final iv = en.IV.fromLength(16);
    final decrypter = en.Encrypter(en.AES(key, mode: en.AESMode.cbc));

    final result = decrypter.decrypt64(testdata, iv: iv);
    log(result);
  }
}
