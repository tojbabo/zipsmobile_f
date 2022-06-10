import 'package:flutter/cupertino.dart';

class ROM {
  ROM._init();
  static final ROM _instance = ROM._init();

  factory ROM() {
    return _instance;
  }

  late BuildContext context;
}
