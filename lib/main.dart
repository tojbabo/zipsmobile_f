import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:zipsai_mobile/screen/load.dart';

import 'ROM.dart';

void main() async {
  log(version);

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ZIPSAI Mobile APP',

    /// 화면 구성 모듈 호출
    home: LoadAPP(),
  ));
}
