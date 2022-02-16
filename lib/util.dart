import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

var _filename = "val";

/// 앱 저장소 위치 가져오는 함수
///
/// return: 저장소 위치
Future<String> get _localPath async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

/// 애플리케이션 macid.txt 파일을 가져오는 함수
///
/// 앱 저장소에 존재하는 _filename 파일 가져옴
Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/$_filename');
}

/// 앱 저장소에 존재하는 파일에 데이터 저장
///
/// num: macid
///
/// return: 작업이 완료된 파일
Future<File> writedata(int num) async {
  final file = await _localFile;
  return file.writeAsString('$num');
}

/// 앱 저장소에 존재하는 파일 읽어옴
///
/// return: macid
Future<int> readdata() async {
  try {
    final file = await _localFile;
    String contents = await file.readAsString();
    return int.parse(contents);
  } catch (e) {
    return 0;
  }
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

Future<void> insertData(key, value) async {
  var origindata = await f_read_data();
  print(origindata);
  var list = origindata.split(',');

  f_input_data(list, key, value);

  await f_write_data(list);
}

void f_f() async {
  await insertData('macid', '9999');
  var d = await readData('macid');
  print('resutls $d');
}

Future<String> readData(key) async {
  var list = await f_read_data();
  var data = list.split(',');
  var index = f_find_key(data, key);
  if (index == -1) return '';
  return data[index].substring(1, data[index].length - 1);
}

/// 리스트에서 해당 키에 맞는 데이터 인덱스를 찾는 함수
///
/// return: index/ -1: 해당 데이터 없음
int f_find_key(data, key) {
  for (var i = 0; i < data.length; i++) {
    var element = data[i].split(':');
    var head = element[0];

    if (key != head) continue;
    return i;
  }
  return -1;
}

/// 리스트에 데이터 삽입하는 함수,
/// 리스트에 해당 키와 일치하는 데이터 있으면 그냥 입력
///
/// return: 바꾼 데이터/ 없으면 새로 삽입된 경우
String f_input_data(data, key, value) {
  var idx = f_find_key(data, key);
  if (idx == -1) {
    data.add('$key:{$value}');
    return '';
  }
  var datas = data[idx].split(':');

  data[idx] = '$key:{$value}';
  return datas[1].substring(1, datas[1].length - 1);
}

Future<String> f_read_data() async {
  try {
    final file = await _localFile;
    var lines = file.readAsString();
    return lines;
  } catch (e) {
    return '';
  }
}

Future<void> f_write_data(data) async {
  final file = await _localFile;
  String text = '';
  for (var i = 0; i < data.length; i++) {
    text += '${data[i]},';
  }
  if (text[text.length - 1] == ',') text = text.substring(0, text.length - 1);
  file.writeAsString(text);
}
