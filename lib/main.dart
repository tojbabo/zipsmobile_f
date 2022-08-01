import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:zipsai_mobile/screen/load.dart';
import 'package:zipsai_mobile/service/receiver.dart';

import 'ROM.dart';

void main() async {
  log(version);
  //runApp(MyApp());

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'load',

    /// 화면 구성 모듈 호출
    home: LoadAPP(),
  ));
}
