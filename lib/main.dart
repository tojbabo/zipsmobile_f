import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zipsai_mobile/util/globals.dart';
import 'package:zipsai_mobile/screen/load.dart';

void main() async {
  print(version);
  //runApp(MyApp());

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'load',

    /// 화면 구성 모듈 호출
    home: LoadAPP(),
  ));
}
