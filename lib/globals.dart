import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const g__version = "1.2.4";

const g__servIp = '222.112.169.110';
//const g__servIp = 'dev.zips.ai';
//const g__servIp = '192.168.0.7';
//const g__servIp = '112.216.50.210';
const g__httpPort = 10000;
const g__httpsPort = 10009;
const g__tcpPort = 10050;

const g__interval = 30 * 1000;
const g__mindist = 10;
const g__minacc = 15;

const g__servHttpAdr = 'http://$g__servIp:$g__httpPort/';
const g__servHttpsAdr = 'https://$g__servIp:$g__httpsPort/';

const g__appinfo = "ip:$g__servIp" +
    ",port:$g__httpsPort/$g__tcpPort" +
    ",interval:$g__interval" +
    ",mindistance:$g__mindist" +
    ",minaccuracy:$g__minacc" +
    ",version:$g__version";

var cookieManager = CookieManager();
var macid;
