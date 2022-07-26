import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      Fluttertoast.showToast(msg: 'serv started: $value');
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

Future<void> StopService() async {
  try {
    channel.invokeMethod(
        'servStop', {}).then((value) => log('service stop - $value'));
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

Future<String> GetSettingData() async {
  //print('call now location()');
  try {
    var value = await channel.invokeMethod('getSetting');
    //log(value);
    return value;
    //print("get now is : $value");
  } catch (e) {
    print("err : $e");
    return "";
  }
}
