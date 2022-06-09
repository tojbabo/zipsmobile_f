package com.hansung.zipsai

import android.content.Context
import io.flutter.Log
import kotlinx.coroutines.*
import org.json.JSONObject
import java.io.*
import java.lang.Exception
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import java.security.KeyStore
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate
import java.util.*
import javax.net.ssl.*

class _Tcp private constructor() {
    companion object {
        private var instance: _Tcp? = null
        fun getInstance(): _Tcp =
                instance ?: synchronized(this) {
                    instance ?: _Tcp().also {
                        instance = it
                    }
                }
    }
    private val TAG = "kotlin tcp"
    private var waittime: Long = 10000
    private val v = _Val.getInstance()
    private var https = "https://dev.zips.ai"
    private var http = "http://dev.zips.ai"
    private var port = "10000"
    private lateinit var url :String
    private lateinit var queue: Queue<JSONObject>
    private lateinit var context: Context
    private var job: Job? = null
    private lateinit var sslContext: SSLContext

    fun initialize(queue: LinkedList<JSONObject>, context: Context) {
        this.context = context
        this.queue = queue
        this.sslContext = sslSet()
        this.port = v.port
        this.url = https + ":${this.port}"
    }
    // Network 관련 함수
    fun doNetwork() {
        val url = URL("${this.url}/data/location/save")
        job = GlobalScope.launch {
            while (true) {
                var target = queue.poll()

                if (target == null) {

                    delay(waittime)
                    continue
                }

                try {


                    val conn = url.openConnection() as HttpsURLConnection
                    conn.sslSocketFactory = sslContext.socketFactory
                    conn.requestMethod = "POST"
                    conn.connectTimeout = 1000
                    conn.readTimeout = 1000
                    conn.doOutput = true

                    val os = conn.outputStream
                    val writer = BufferedWriter(OutputStreamWriter(os, "UTF-8"))
                    writer.write(encodeParams(target))
                    writer.flush()
                    writer.close()

                    val res = conn.responseCode
//                Log.d(TAG, "res: $res")

                    if (res == HttpURLConnection.HTTP_OK) {
//                    Log.d(TAG,"result good")
                        var text: String =
                            conn.inputStream.bufferedReader().use(BufferedReader::readText)
                    }
                }catch (e:Exception){
                    android.util.Log.d(TAG, "time out")
                }
            }
        }
    }
    fun initSetting(): Boolean {
        var flag = false
        val url = URL("${this.url}/data/location/setting")
        var job1 = GlobalScope.launch {
            val conn = url.openConnection() as HttpsURLConnection
            conn.sslSocketFactory = sslContext.socketFactory
            conn.connectTimeout = 1000
            conn.readTimeout = 1000
            conn.requestMethod = "GET"

            try {
                val res = conn.responseCode
                //Log.d(TAG, "res: $res")

                if (res == HttpURLConnection.HTTP_OK) {
                    val text: String =
                        conn.inputStream.bufferedReader().use(BufferedReader::readText)
                    android.util.Log.d(TAG, "$text")
                    var setvalue = JSONObject(text)
                    var distance: Float = setvalue.getString("distance").toFloat()
                    var accuracy: Int = setvalue.getInt("accuracy")
                    var interval: Long = setvalue.getLong("interval")

                    v.interval = interval
                    v.minAccuracy = accuracy
                    v.minDistance = distance
                    waittime = (interval * 0.8).toLong()
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
    fun jobdoen(){
        job?.cancel()
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