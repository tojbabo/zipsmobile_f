import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import '../RAM.dart';
import 'package:permission_handler/permission_handler.dart';

/// 위치 권한이 확인 함수
///
/// return: T/F
Future<bool> LocPermissionCheck() async {
  if (await Permission.locationAlways.isGranted) {
    log('[LocPermissionCheck] true');
    gServEnable = 1;
    return true;
  } else {
    log('[LocPermissionCheck] false');

    gServEnable = 0;
    return false;
  }
}

/// macid를 만드는 함수,
/// 0~9999 사이의 수에 임의의 소수를 곱하는 방식
int MakeId() {
  var random = math.Random();
  var core = random.nextInt(9999);
  var idx = random.nextInt(9) + 3;

  var target = 1;
  int j;

  for (var i = 1; i <= idx;) {
    target++;
    for (j = 2; j <= target; j++) {
      if (target % j == 0) break;
    }
    if (j == target) i++;
  }

  return core * target;
}

/// 인터넷 연결 여부 확인
Future<bool> internetcheck() async {
  try {
    var result = await InternetAddress.lookup("google.com");
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      log("[internetcheck] good");
      return true;
    }
  } on SocketException catch (_) {
    log("[internetcheck] bad");
  }
  return false;
}

class json {
  late List<Map<String, String>> list;

  /// Json Stirng -> Json,, list에 key:value 쌍으로 저장
  json(String data) {
    list = [];
    int startidx = data.indexOf("{");
    int endidx = data.lastIndexOf("}");
    String realdata = data.substring(startidx + 1, endidx);

    var datas = realdata.split(',');
    for (var i = 0; i < datas.length; i++) {
      var kv = datas[i].split(":");
      list.add({kv[0].replaceAll('"', ''): kv[1].replaceAll('"', '')});
    }
  }

  /// list 내 key 값으로 value 찾음.ㄴ
  String? get(String key) {
    for (var i = 0; i < list.length; i++) {
      if (list[i].keys.first == key) return list[i].values.first;
    }
    return null;
  }
}
