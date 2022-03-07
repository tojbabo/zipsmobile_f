import 'package:flutter/material.dart';
import 'package:zipsmobile_f/globals.dart';
import 'package:zipsmobile_f/screen/load.dart';

void main() {
  print(g__version);
  //runApp(MyApp());
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'load',
    home: Load(),
  ));
}
