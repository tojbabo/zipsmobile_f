import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/macid.txt');
}

Future<File> writedata(int num) async {
  final file = await _localFile;
  return file.writeAsString('$num');
}

Future<int> readdata() async {
  try {
    final file = await _localFile;
    String contents = await file.readAsString();
    return int.parse(contents);
  } catch (e) {
    return 0;
  }
}

int makeid() {
  var random = new Random();
  var core = random.nextInt(9999);
  var idx = random.nextInt(9) + 3;

  var target = 1;
  var j;

  for (var i = 1; i <= idx;) {
    target++;
    for (j = 2; j <= target; j++) {
      if (target % j == 0) break;
    }
    if (j == target) i++;
  }

  return core * target;
}
