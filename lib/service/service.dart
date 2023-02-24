import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../RAM.dart';
import '../ROM.dart';
import '../util/etc.dart';

const MethodChannel channel = MethodChannel('zipsai');

/// android Service를 시작하는 함수
Future<int> StartService() async {
  if (Platform.isAndroid) {
    if (await LocPermissionCheck() == false) return 0;
  }

  try {
    if (gServOn == 1) return 1;
    var result = await channel
        .invokeMethod('servStart', {"macid": "$gMacId", "port": gHttpsPort});

    log('[StartService] good: ($result)');
    //Fluttertoast.showToast(msg: '서비스를 시작합니다');
    return 1;
  } catch (e) {
    log("[StartService] err : $e");
  }
  return 0;
}

/// 현재 위치를 가져오는 함수
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

/// 서비스 종료 함수
Future<void> StopService() async {
  try {
    channel.invokeMethod(
        'servStop', {}).then((value) => log('[StopService] good: ($value)'));

    //Fluttertoast.showToast(msg: '서비스를 종료합니다');
  } catch (e) {
    log("[StopService] err : $e");
  }
}

/// 서비스가 실행중인지 확인하는 함수
Future<void> IsRunService() async {
  try {
    var value = await channel.invokeMethod('isrun');
    log('[IsRunService] service state: $value');
    if (value) {
      gServOn = 1;
    } else {
      gServOn = 0;
    }
    return;
  } catch (e) {
    print("err : $e");
  }
  gServOn = 0;
}

/// 서비스 설정 데이터 ㄱ져오는 함수ㅜ
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

/* 디버깅용 */
/// 서비스와 통신 테스트 함수
Future<void> FuckUTest() async {
  channel.invokeMethod('test');
}
