package com.softzen.hansungai;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.core.app.ActivityCompat;

import java.util.List;

public class _taskLoc extends AsyncTask<Void,Void,Boolean> {
    List<String> queue;
    Context _context;
    Vals val = Vals.get_instance();
    LocationManager locationManager;
    LocationListener locationListener;
    public _taskLoc(List<String> queue, Context context) {
        this.queue = queue;
        this._context = context;
        locationManager = null;
    }

    @Override
    protected Boolean doInBackground(Void... voids) {
        locationManager = (LocationManager) _context.getSystemService(Context.LOCATION_SERVICE);

        Handler mHandler = new Handler(Looper.getMainLooper());
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                if (ActivityCompat.checkSelfPermission(_context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED &&
                        ActivityCompat.checkSelfPermission(_context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                    locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, val.interval, val.loc_MinDistance, getListener("NETWORK"));
                    locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, val.interval, val.loc_MinDistance, getListener("GPS"));
                }
            }
        }, 3000);

        while (!this.isCancelled()) {
            try {
                Thread.sleep(val.interval);
            } catch (InterruptedException e) {
                //e.printStackTrace();
            }
        }

        locationManager.removeUpdates(locationListener);
        return true;
    }

    @Override
    protected void onCancelled() {

        Log.d("loc", "onCancelled: ");
        super.onCancelled();
    }

    private LocationListener getListener(final String tag) {
        return new LocationListener() {
            @Override
            public void onLocationChanged(Location location) {
                if (location.getAccuracy() > val.loc_MinAccuracy) return;
                if(queue.size() >10) queue.remove(queue.size());
                if(location.getLatitude() <32.8 || location.getLatitude() > 38.8) return;
                if(location.getLongitude() <125.5 || location.getLongitude() > 131.9) return;

                @SuppressLint("DefaultLocale")
                String msg = String.format("{location,id:%s,tag:%s,lat:%f,lng:%f,spd:%f,acc:%.2f,alt:%.2f}",
                        val.macid, tag, location.getLatitude(), location.getLongitude(),
                        location.getSpeed(), location.getAccuracy(), location.getAltitude());
                queue.add(msg);
            }

            @Override
            public void onStatusChanged(String s, int i, Bundle bundle) {

            }

            @Override
            public void onProviderEnabled(String s) {

            }

            @Override
            public void onProviderDisabled(String s) {

            }
        };
    }

    public String getLocationNow() {
        if(locationManager == null) return "";
        @SuppressLint("MissingPermission") Location GPSLoc = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
        @SuppressLint("MissingPermission") Location NetLoc = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);

        Location location;
        String tag ="all";

        if(GPSLoc == null || GPSLoc.getAccuracy() ==0 )tag = "NETWORK";
        if(NetLoc == null || NetLoc.getAccuracy() == 0 )tag = (tag == "NETWORK")?"":"GPS";

        if(tag == "all") {
            if (GPSLoc.getAccuracy() != 0 && NetLoc.getAccuracy() != 0)
                tag = (GPSLoc.getAccuracy() <= NetLoc.getAccuracy()) ? "GPS" : "NETWORK";
        }
        if(tag =="NETWORK") location = NetLoc;
        else if(tag == "GPS") location = GPSLoc;
        else return "";

        String result =  String.format("location,id:%s,tag:%s,lat:%f,lng:%f,spd:%f,acc:%.2f,alt:%.2f",
                val.macid, tag, location.getLatitude(), location.getLongitude(),
                location.getSpeed(), location.getAccuracy(), location.getAltitude());


        return result;
    }
}
