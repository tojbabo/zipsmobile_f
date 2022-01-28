package com.softzen.hansungai;

import android.util.Log;

public class Vals {
    private static Vals _instance = new Vals();
    public static Vals get_instance(){return _instance;}

    public String macid;
    public String version;
    public String ip;
    public String port;
    public int interval;
    public int loc_MinDistance;
    public int loc_MinAccuracy;

    private Vals (){
        macid ="999";
        version = "1.0.0";
        ip = "127.0.0.1";
        port = "12050";
        interval = 30*1000;
        loc_MinDistance = 10;
        loc_MinAccuracy = 15;
    }

    public void showvalue(){
        Log.d("value check", macid);
        Log.d("value check", version);
        Log.d("value check", ip);
        Log.d("value check", port);
        Log.d("value check", "" + interval);
    }


    public static int AUTO = 1;
    public static int MANUAL = 0;

    public static final int STATE_UNREQ = 10;
    public static final int STATE_REQ = 11;
    public static final int STATE_DENY = 12;
    public static final int STATE_ACPT = 13;

    public static int STATE_DISCONN = 1;
    public static int STATE_CONN = 2;
}
