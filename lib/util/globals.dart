const version = "1.3.5";

//const g__servIp = 'main.zips.ai';
const servIp = 'dev.zips.ai';
const httpPort = 12000;
const httpsPort = 12009;
//const tcpPort = 10000;

const interval = 30 * 1000;
const mindist = 10;
const minacc = 15;
const servHttpAdr = 'http://$servIp:$httpPort/';
const servHttpsAdr = 'https://$servIp:$httpsPort/';

const appinfo = "ip:$servIp"
    ",port:$httpsPort"
    ",interval:$interval"
    ",mindistance:$mindist"
    ",minaccuracy:$minacc"
    ",version:$version";

var macid = 999;
var id;
var pw;
var servEnable = 0;
var servAutoRun = 0;
var servOn = 0;

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
