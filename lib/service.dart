import 'package:flutter/services.dart';

import 'globals.dart';

final MethodChannel channel = new MethodChannel('app.zips.ai/channel');
Future<void> startService() async {
  try {
    await channel.invokeMethod('service', {"macid": macid});
  } catch (e) {
    print("err : $e");
  }
}
