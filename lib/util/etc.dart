import 'dart:math';

import '../RAM.dart';
import 'package:permission_handler/permission_handler.dart';

/// 위치 권한이 확인 함수
///
/// return: T/F
Future<bool> LocPermissionCheck() async {
  if (await Permission.locationAlways.isGranted) {
    gServEnable = 1;
    return true;
  } else {
    return false;
  }
}

/// macid를 만드는 함수,
/// 0~9999 사이의 수에 임의의 소수를 곱하는 방식
int MakeId() {
  var random = Random();
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
