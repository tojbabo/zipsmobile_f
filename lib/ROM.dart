const version = "1.3.7";

//const g__servIp = 'main.zips.ai';
const gServerIp = 'dev.zips.ai';
const gHttpPort = 12000;
const gHttpsPort = 12009;

const gInterval = 30 * 1000;
const gMinDist = 10;
const gMinAcc = 15;
const gServHttpAdr = 'http://$gServerIp:$gHttpPort/';
const gServHttpsAdr = 'https://$gServerIp:$gHttpsPort/';

const gAppInfo = "ip:$gServerIp"
    ",port:$gHttpsPort"
    ",interval:$gInterval"
    ",mindistance:$gMinDist"
    ",minaccuracy:$gMinAcc"
    ",version:$version";

// 기기 식별자 - 추후 변경될 예정
const MACID = 'macid';

// 로그인 정보 (아이디, 비밀번호), 있으면 자동로그인 없으면 수동
const LOGININFO = 'login';

// 실버 모드 정보 - 1:on / 0:off
const SENIOR = 'senior';

// 앱이 처음 시작됐는지 확인정보
const FIRSTLAUNCH = 'isfirst';

// 서비스 자동 실행 상태인지
const AUTORUNSERV = 'servautorun';
