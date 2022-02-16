import 'package:flutter/services.dart';

import 'globals.dart';

final MethodChannel channel = new MethodChannel('app.zips.ai/channel');

/// android Service를 시작하는 함수
Future<void> startService() async {
  try {
    await channel.invokeMethod('service', {
      "macid": macid,
      "version": g__version,
      "ip": g__servIp,
      "port": g__tcpPort,
      "interval": g__interval
    });
  } catch (e) {
    print("err : $e");
  }
}
