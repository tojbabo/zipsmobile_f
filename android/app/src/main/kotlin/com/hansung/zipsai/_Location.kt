package com.hansung.zipsai

import android.annotation.SuppressLint
import android.content.Context
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.util.*
import java.util.function.Consumer

class _Location private constructor() {
    companion object {
        private var instance: _Location? = null
        fun getInstance(): _Location =
                instance ?: synchronized(this) {
                    instance ?: _Location().also {
                        instance = it
                    }
                }
    }

    private lateinit var context: Context
    private lateinit var queue: Queue<JSONObject>
    private lateinit var gpsListener: LocationListener
    private lateinit var networkListener: LocationListener
    private val TAG = "Kotlin location"
    private lateinit var nowLocation: Location
    private lateinit var manager:LocationManager

    private var v = _Val.getInstance()
    fun initialize(context: Context, queue: LinkedList<JSONObject>) {
        this.context = context
        this.queue = queue
        gpsListener = getListener("GPS", queue)
        networkListener = getListener("NETWORK", queue)
        manager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

    }

    // location 수집 관련 함수
    @SuppressLint("MissingPermission")
    fun doLocation() {
//
        //Log.d(TAG, "interval: ${v.interval}")
        //Log.d(TAG, "mindis: ${v.minDistance}")
        //Log.d(TAG, "minacc: ${v.minAccuracy}")

//        manager.requestLocationUpdates(
//                LocationManager.GPS_PROVIDER,
//                0,
//                0f,
//                gpsListener)
//
//        manager.requestLocationUpdates(
//                LocationManager.NETWORK_PROVIDER,
//                0,
//                0f,
//                networkListener)

        manager.requestLocationUpdates(
            LocationManager.GPS_PROVIDER,
            v.interval,
            v.minDistance,
            gpsListener)

        manager.requestLocationUpdates(
            LocationManager.NETWORK_PROVIDER,
            v.interval,
            v.minDistance,
            networkListener)


    }
    @RequiresApi(Build.VERSION_CODES.R)
    @SuppressLint("MissingPermission")
    fun getNowLocation(): JSONObject {

        var j = JSONObject()
        var it = nowLocation

        j.put("macid",v.id)
        j.put("lat", it.latitude)
        j.put("lng", it.longitude)
        j.put("spd", it.speed)
        j.put("time",it.time)
        j.put("tag", "now")
        j.put("acc", String.format("%.2f", it.accuracy))
        j.put("alt", String.format("%.2f", it.altitude))

        return j
    }
    fun jobdoen(){
        manager.removeUpdates(gpsListener)
        manager.removeUpdates(networkListener)
    }
    @SuppressLint("MissingPermission")
    fun restart(){
        jobdoen()
        doLocation()

    }

    private fun getListener(tag: String, q: Queue<JSONObject>): LocationListener {
        return object : LocationListener {
            override fun onLocationChanged(location: Location) {
//                val latitude = location.latitude
//                val longitude = location.longitude
//                Log.d(TAG, "$tag, Latitude: $latitude" +
//                        ", Longitude: $longitude")
                nowLocation = location
                //if (location.accuracy > v.minAccuracy) return
                if (q.count() > 10) q.poll()
//                if(location.latitude < 32.8 || location.latitude > 38.8 ) return;
//                if(location.longitude < 125.5 || location.longitude > 131.9) return;


                val j = JSONObject()

                j.put("lat", location.latitude)
                j.put("lng", location.longitude)
                j.put("spd", location.speed)
                j.put("acc", String.format("%.2f", location.accuracy))
                j.put("alt", String.format("%.2f", location.altitude))
                j.put("tag", tag)
                j.put("id", v.id)

                q.add(j)
            }
        }
    }

}