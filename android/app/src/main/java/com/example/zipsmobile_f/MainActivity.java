package com.softzen.hansungai;
import android.Manifest;
import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "app.zips.ai/channel";
    String macid ;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                ((call, result) -> {
                    if(call.method.equals( "service")) {
                            macid = call.argument("macid") .toString();
                            // Toast.makeText(this, "macid: "+macid, Toast.LENGTH_SHORT).show();
                            dispatchTakePictureInterIntent();
                            // Toast.makeText(this, "false", Toast.LENGTH_SHORT).show();
                        

                    }
                }));
    }
    static final int REQUEST_IMAGE_CAPTURE = 1;
    private void dispatchTakePictureInterIntent(){
        Intent it = new Intent(this, _ServiceCore.class);
        if(!isServiceRun(_ServiceCore.class.getName())){
            it.putExtra("macID",macid);
            startService(it);
        }
    }
    private boolean isServiceRun(String serviceName){
            ActivityManager manager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);

            for(ActivityManager.RunningServiceInfo serviceInfo : manager.getRunningServices(Integer.MAX_VALUE)){
                if(serviceName.equals(serviceInfo.service.getClassName())){
                    return true;
                }
            }
        return  false;
    }
}
