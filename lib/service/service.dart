import 'package:flutter/services.dart';
import '../util/globals.dart';

const MethodChannel channel = MethodChannel('zipsai');

/// android Service를 시작하는 함수
Future<bool> startService() async {
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

Future<String> getNowLocation() async {
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

Future<void> settingService() async {
  try {
    channel.invokeMethod(
        'servSet', {}).then((value) => print('serv setting change: $value'));
  } catch (e) {
    print("err : $e");
  }
}

Future<void> stopService() async {
  try {
    channel.invokeMethod('servStop', {}).then((value) => print('service stop'));
  } catch (e) {
    print("err : $e");
  }
}

Future<bool> isrunService() async {
  try {
    var value = await channel.invokeMethod('isrun');
    //print('service run check : $value');
    return value;
  } catch (e) {
    print("err : $e");
    return false;
  }
}
