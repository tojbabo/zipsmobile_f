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
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import org.json.JSONObject
import java.io.*
import java.lang.Exception
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import java.security.KeyStore
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManagerFactory

class tempLoc private constructor() {
    companion object {
        private var instance: tempLoc? = null
        fun getInstance(): tempLoc =
            instance ?: synchronized(this) {
                instance ?: tempLoc().also {
                    instance = it
                }
            }
    }

    private lateinit var context: Context
    private lateinit var gpsListener: LocationListener
    private lateinit var networkListener: LocationListener
    private val TAG = "Kotlin location"
    private lateinit var nowLocation: Location
    private lateinit var manager:LocationManager

    private var v = _Val.getInstance()
    // tete
    private var https = "https://dev.zips.ai"
    private var http = "http://dev.zips.ai"
    private var port = "10000"
    private lateinit var sslContext: SSLContext
    private lateinit var urls :String
    private var flag = false


    fun initialize(context: Context) {
        this.context = context
        gpsListener = getListener("GPS")
        networkListener = getListener("NETWORK")
        manager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager


        this.sslContext = sslSet()
        this.port = v.port
        this.urls = https + ":${this.port}"

    }

    // location 수집 관련 함수
    @SuppressLint("MissingPermission")
    fun doLocation() {
        manager.requestLocationUpdates(
            LocationManager.GPS_PROVIDER,
            0,
            0f,
            gpsListener)

        manager.requestLocationUpdates(
            LocationManager.NETWORK_PROVIDER,
            0,
            0f,
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
    fun initSetting(): Boolean {
        var flag = false
        var url = URL("${urls}/data/location/setting")
        var job1 = GlobalScope.launch {
            val tempConn = url.openConnection() as HttpsURLConnection
            tempConn.sslSocketFactory = sslContext.socketFactory
            tempConn.connectTimeout = 1000
            tempConn.readTimeout = 1000
            tempConn.requestMethod = "GET"

            try {
                val res = tempConn.responseCode
                //Log.d(TAG, "res: $res")

                if (res == HttpURLConnection.HTTP_OK) {
                    val text: String =
                        tempConn.inputStream.bufferedReader().use(BufferedReader::readText)
                    android.util.Log.d(TAG, "$text")
                    var setvalue = JSONObject(text)
                    var distance: Float = setvalue.getString("distance").toFloat()
                    var accuracy: Int = setvalue.getInt("accuracy")
                    var interval: Long = setvalue.getLong("interval")

                    v.interval = interval
                    v.minAccuracy = accuracy
                    v.minDistance = distance
                    flag = true


                }


            } catch (e: Exception) {
                android.util.Log.d(TAG, "init time out")
            }
            //android.util.Log.d(TAG, "setting done")
        }
        runBlocking {
            job1.join()
        }
        return flag
    }


    private fun getListener(tag: String): LocationListener {
        return object : LocationListener {
            override fun onLocationChanged(location: Location) {
                if(flag) {
                    Log.d(TAG, "onLocationChanged: it is true")
                    return
                    
                }
//                val latitude = location.latitude
//                val longitude = location.longitude
//                Log.d(TAG, "$tag, Latitude: $latitude" +
//                        ", Longitude: $longitude")
                nowLocation = location
                //if (location.accuracy > v.minAccuracy) return
//               if(location.latitude < 32.8 || location.latitude > 38.8 ) return;
//               if(location.longitude < 125.5 || location.longitude > 131.9) return;


                val j = JSONObject()

                j.put("lat", location.latitude)
                j.put("lng", location.longitude)
                j.put("spd", location.speed)
                j.put("acc", String.format("%.2f", location.accuracy))
                j.put("alt", String.format("%.2f", location.altitude))
                j.put("tag", tag)
                j.put("id", v.id)


                GlobalScope.launch {
                    try {
                        flag = true

                        var url = URL("${urls}/data/location/save")
                        var conn = url.openConnection() as HttpsURLConnection
                        conn.sslSocketFactory = sslContext.socketFactory
                        conn.requestMethod = "POST"
                        conn.connectTimeout = 1000
                        conn.readTimeout = 1000
                        conn.doOutput = true

                        val os = conn.outputStream
                        val writer = BufferedWriter(OutputStreamWriter(os, "UTF-8"))
                        writer.write(encodeParams(j))
                        writer.flush()
                        writer.close()

                        val res = conn.responseCode
                        if (res == HttpURLConnection.HTTP_OK) {
                            var text: String =
                                conn.inputStream.bufferedReader().use(BufferedReader::readText)
                        }
                    } catch (e: Exception) {
                        android.util.Log.d(TAG, "time out")
                        android.util.Log.d(TAG, "${e.toString()}")
                    }
                    flag = false
                }
            }
        }
    }
    private fun encodeParams(params: JSONObject): String? {
        val result = StringBuilder()
        var first = true
        val itr = params.keys()
        while (itr.hasNext()) {
            val key = itr.next()
            val value = params[key]
            if (first) first = false else result.append("&")
            result.append(URLEncoder.encode(key, "UTF-8"))
            result.append("=")
            result.append(URLEncoder.encode(value.toString(), "UTF-8"))
        }
        return result.toString()
    }
    private fun sslSet(): SSLContext {
        val cf: CertificateFactory = CertificateFactory.getInstance("X.509")
        val fiStream = context.resources.openRawResource(R.raw.ca)
        val caInput: InputStream = BufferedInputStream(fiStream)
        val ca: X509Certificate = caInput.use {
            cf.generateCertificate(it) as X509Certificate
        }

        val keyStoreType = KeyStore.getDefaultType()
        val keyStore = KeyStore.getInstance(keyStoreType).apply {
            load(null, null)
            setCertificateEntry("ca", ca)
        }

        val tmfAlgorithm: String = TrustManagerFactory.getDefaultAlgorithm()
        val tmf: TrustManagerFactory = TrustManagerFactory.getInstance(tmfAlgorithm).apply {
            init(keyStore)
        }

        val sslcontext: SSLContext = SSLContext.getInstance("TLS").apply {
            init(null, tmf.trustManagers, null)
        }
        return sslcontext
    }

}