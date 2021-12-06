package com.softzen.hansungai;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;

public class _ServiceReceiver extends Service {
    public _ServiceReceiver() {
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Intent service = new Intent(this, _ServiceCore.class);
        stopService(service);



        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public IBinder onBind(Intent intent) {
        // TODO: Return the communication channel to the service.
        throw new UnsupportedOperationException("Not yet implemented");
    }
}