import 'dart:developer';

import 'package:flutter/services.dart';
import '../RAM.dart';
import '../ROM.dart';
import '../util/etc.dart';

const MethodChannel channel = MethodChannel('zipsai');

/// android Service를 시작하는 함수
Future<bool> StartService() async {
  if (await LocPermissionCheck() == false) return false;
  try {
    channel.invokeMethod(
        'servStart', {"macid": "$gMacId", "port": gHttpsPort}).then((value) {
      gServOn = 1;
      print('start service: $value');
    });

    return true;
  } catch (e) {
    print("err : $e");
  }
  gServOn = 0;
  return false;
}

Future<String> GetNowLocation() async {
  //print('call now location()');
  try {
    var value = await channel.invokeMethod('getLoca');
    //print("get now is : $value");
    return value;
  } catch (e) {
    print("err : $e");
    return "";
  }
}

Future<void> SettingService() async {
  try {
    channel.invokeMethod(
        'servSet', {}).then((value) => print('serv setting change: $value'));
  } catch (e) {
    print("err : $e");
  }
}

Future<void> StopService() async {
  try {
    channel.invokeMethod('servStop', {}).then((value) => print('service stop'));
  } catch (e) {
    print("err : $e");
  }
}

Future<bool> IsRunService() async {
  try {
    var value = await channel.invokeMethod('isrun');
    gServOn = (value) ? 1 : 0;
    return value;
  } catch (e) {
    print("err : $e");
  }
  gServOn = 0;
  return false;
}
