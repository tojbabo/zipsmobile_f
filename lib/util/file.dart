import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

var _filename = "val";
var _path = "";
late List<String> _fileData;

Future fileInit() async {
  await getApplicationDocumentsDirectory().then((res) {
    _path = res.path;
    _read();
  });
}

void DEBUG_file_showDatas() {
  _read();
  print(_fileData);
}

/// 정해진 파일 다 읽어옴
void _read() {
  var file = _localFile;
  try {
    _fileData = file.readAsLinesSync();
  } catch (e) {
    _fileData = <String>[];
  }
}

/// 현재 데이터를 저장함
void _write() {
  var file = _localFile;
  var target = '';
  for (var i = 0; i < _fileData.length; i++) {
    target += _fileData[i] + '\n';
  }
  file.writeAsStringSync(target);
}

/// 애플리케이션 macid.txt 파일을 가져오는 함수
///
/// 앱 저장소에 존재하는 _filename 파일 가져옴
File get _localFile {
  final path = _path;
  return File('$path/$_filename');
}

/// macid를 만드는 함수,
/// 0~9999 사이의 수에 임의의 소수를 곱하는 방식
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

/// 리스트에 데이터 입력
/// 기존에 존재하면 변환
/// 없으면 추가함
/// return - (t: 추가됨 / f: 변환됨)
bool inputData(String key, String value) {
  var writedata = '$key:{$value}';

  var append = true;
  for (var i = 0; i < _fileData.length; i++) {
    var token = _fileData[i].split(':');
    if (token[0] != key) continue;

    _fileData[i] = writedata;
    append = false;
  }
  if (append) _fileData.add(writedata);
  _write();
  return append;
}

/// 데이터에서 특정 키 읽어옴
/// 데이터 없으면 공백 반환
String getData(String key) {
  for (var i = 0; i < _fileData.length; i++) {
    var token = _fileData[i].split(':');
    if (token[0] == key) {
      return token[1].substring(1, token[1].length - 1);
    }
  }
  return '';
}

/// 데이터 리스트에서 해당 키 지움
/// return - (t: 삭제 / f: 해당 키 없음)
bool removeData(String key) {
  for (var i = 0; i < _fileData.length; i++) {
    var token = _fileData[i].split(':');
    if (token[0] != key) continue;
    _fileData.removeAt(i);
    _write();
    return true;
  }
  return false;
}
