import 'package:flutter/services.dart';
import 'package:zipsai_mobile/screen/request.dart';
import '../util/globals.dart';

const MethodChannel channel = MethodChannel('zipsai');

/// android Service를 시작하는 함수
Future<bool> StartService() async {
  if (await locPermissionCheck() == false) return false;
  try {
    channel
        .invokeMethod('servStart', {"macid": "$macid", "port": httpsPort}).then(
            (value) => print('start service: $value'));
    servOn = 1;
    return true;
  } catch (e) {
    print("err : $e");
    return false;
  }
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
    //print('service run check : $value');
    return value;
  } catch (e) {
    print("err : $e");
    return false;
  }
}
