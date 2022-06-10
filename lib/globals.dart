const g__version = "1.2.5";

//const g__servIp = 'main.zips.ai';
const g__servIp = 'dev.zips.ai';
const g__httpPort = 10000;
const g__httpsPort = 10009;
const g__tcpPort = 12050;

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
var macid = 999;
