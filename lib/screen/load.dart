import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zipsmobile_f/screen/request.dart';
import 'package:zipsmobile_f/util.dart';

import '../globals.dart';
import 'main.dart';

class Load extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1)).then((value) {
      readdata().then((value) {
        var flag = false;
        if (value == 0) {
          macid = makeid();
          writedata(macid);
          flag = true;
        } else {
          macid = value;
        }
        print(macid);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainApp()));
        if (flag) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Request()));
        }

        //   Navigator.pushReplacement(
        //       context, MaterialPageRoute(builder: (context) => Request()));
      });
    });

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Container(
          alignment: Alignment.center,
          color: Colors.white,
          child: Text(
            "loading...",
            style: TextStyle(
              fontSize: 19,
              decoration: TextDecoration.none,
              foreground: Paint()
                ..strokeWidth = 5
                ..color = Colors.black,
            ),
          )),
    );
  }
}
