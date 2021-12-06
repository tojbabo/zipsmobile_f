package com.softzen.hansungai;

public class Vals {
    public static String version ="1.1.0";

    public static String ip = "dev.zips.ai";
//    public static String webport = "12000";
//    public static String tcpport = "12050";
    public static String webport = "10009";
    public static String tcpport = "10050";
    public static int interval = 30*1000;

    public static int loc_MinDistance = 10;
    public static int loc_MinAccuracy = 15;

    public static int AUTO = 1;
    public static int MANUAL = 0;

    public static final int STATE_UNREQ = 10;
    public static final int STATE_REQ = 11;
    public static final int STATE_DENY = 12;
    public static final int STATE_ACPT = 13;

    public static int STATE_DISCONN = 1;
    public  static int STATE_CONN = 2;

    public static String getInfo(){
        return "ip:"+ip+"" +
                ",port:"+webport+"/"+tcpport+"" +
                ",interval:"+interval+"" +
                ",mindistance:"+loc_MinDistance+"" +
                ",minaccuracy:"+loc_MinAccuracy+"" +
                ",version:"+version+"" +
                "";

    }
}
