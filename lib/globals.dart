import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const g__version = "1.1.0";

const g__servIp = 'dev.zips.ai';
//const g__servIp = '112.216.50.210';
const g__httpPort = 12000;
const g__httpsPort = 12009;
const g__tcpPort = 12050;

const g__servHttpAdr = 'http://$g__servIp:$g__httpPort/';
const g__servHttpsAdr = 'https://$g__servIp:$g__httpsPort/';

var cookieManager = CookieManager();
var macid;
