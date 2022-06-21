import 'package:flutter/services.dart';

import 'package:zipsai_mobile/util/globals.dart';

final MethodChannel channel = new MethodChannel('app.zips.ai/channel');

/// android Service를 시작하는 함수
Future<void> startService() async {
  try {
    await channel.invokeMethod('service', {
      "macid": macid,
      "version": version,
      "ip": servIp,
      "port": 9999,
      "interval": interval
    });
  } catch (e) {
    print("err : $e");
  }
}
