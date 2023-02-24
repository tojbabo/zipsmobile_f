/// 폰 내 로그 기록을 남기기 위해 구현 중
/// print(), log() 등의 기록을 특정 로그 파일에 저장하고
/// 추후에 로그 파일 전송을 하면 해당 로그를 전송할 수 있도록 구현할 예정
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<Directory> _tempdir = getApplicationDocumentsDirectory();

Future<void> log1(String message) async {
  var file = await _Get_File();
  await file.writeAsString('{$message}\n', mode: FileMode.append);
}

Future<String?> read_log() async {
  try {
    var file = await _Get_File();
    String data = await file.readAsStringSync();
    log(data);
    return data;
  } catch (e) {
    return null;
  }
}

Future<Directory> _Get_Dir() async {
  var path = (await _tempdir).path + '/log';
  var dir = Directory('$path');

  if (!dir.existsSync()) {
    await dir.create(recursive: true);
  }

  return dir;
}

Future<File> _Get_File() async {
  var dir = await _Get_Dir();
  var file = dir.path + '/$log.log';
  return File(file);
}
