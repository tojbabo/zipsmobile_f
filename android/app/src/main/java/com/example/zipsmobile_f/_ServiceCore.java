package com.example.zipsmobile_f;

import android.Manifest;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.AsyncTask;
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;

import java.util.ArrayList;
import java.util.List;

public class _ServiceCore extends Service {
    private List<String> queue;
    public static final String CHANNEL_ID = "ForegroundServiceChannel";
    _taskLoc taskLoc;
    _taskTcp taskTcp;
    String macId;
    IBinder binder = new LocalBinder();

    @Override
    public void onCreate() {
        super.onCreate();
        queue = new ArrayList<String>();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        macId = intent.getStringExtra("macID");
        createNotificationChannel();

        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);

        Intent evtIntent = new Intent(this, _ServiceReceiver.class);
        PendingIntent evtPending = PendingIntent.getService(this,0,evtIntent,0);

        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Zips Ai")
                .setContentText("위치 정보 전송 중")
                //.setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pendingIntent)
                .addAction(R.drawable.launch_background,"끄기", evtPending)
                .build();

        startForeground(1, notification);

        taskTcp = new _taskTcp(macId,queue);
        taskLoc = new _taskLoc(macId, queue, this);

        taskTcp.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
        taskLoc.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);


        //Log.d("service", "command off");
        //return super.onStartCommand(intent, flags, startId);
        return START_STICKY;
    }


    @Override
    public void onDestroy() {
        super.onDestroy();

        taskLoc.cancel(false);
        taskTcp.cancel(false);

        stopForeground(true);
        stopSelf();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "Gps 위치 정보 서버 전송 중",
                    NotificationManager.IMPORTANCE_DEFAULT
            );

            NotificationManager manager = getSystemService(NotificationManager.class);
            assert manager != null;
            manager.createNotificationChannel(serviceChannel);
        }
    }

    public String getLastLoc() {
        if (taskLoc == null) return "";
        return taskLoc.getLocationNow();
    }

    public class LocalBinder extends Binder {
        public _ServiceCore getServiceInstance(){
            return _ServiceCore.this;
        }
    }
}