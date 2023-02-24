import 'package:flutter/foundation.dart';

const version = "1.5.2";

const gServerIp = (kDebugMode) ? 'dev.zips.ai' : 'home.zips.ai';
const gHttpsPort = (kDebugMode) ? 10009 : 12009;

const gServHttpsAdr = 'https://$gServerIp:$gHttpsPort/';

const gAppInfo = "ip:$gServerIp"
    ",port:$gHttpsPort"
    ",version:$version";

// 기기 식별자 - 추후 변경될 예정
const MACID = 'macid';

// 앱이 처음 시작됐는지 확인정보
const FIRSTLAUNCH = 'isfirst';

// 서비스 자동 실행 상태인지
const AUTORUNSERV = 'servautorun';
