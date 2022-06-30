package com.hansung.zipsai

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private  val CHANNEL = "zipsai"
    private  val  TAG = "kotlin mainAcitivy"

    @RequiresApi(Build.VERSION_CODES.R)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val v = _Val.getInstance()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler{
            call,result->
            when (call.method) {
                "servStart" -> {
                    if (isServiceRun(MainService::class.java.name)) {
                        result.success("service aleady run")
                    } else {
                        val macid = call.argument<String>("macid")
                        val port = call.argument<Int>("port")
                        v.id = macid!!
                        v.port = "$port"

                        val intent = Intent(this, MainService::class.java)
                        startService(intent)

                        result.success("started")
                    }
                }
                "servStop" -> {
                    if (isServiceRun(MainService::class.java.name)) {
                        val it = Intent(context,MainService::class.java)
                        context?.stopService(it)
                    } else result.success("not service run")
                }
                "isrun" -> {
                    if (isServiceRun(MainService::class.java.name)) result.success(true)
                    else result.success(false)
                }
                "servSet" -> {
                    if (isServiceRun(MainService::class.java.name)) {
                        var net = _Tcp.getInstance()
                        var loc = _Location.getInstance()
                        var res = net.initSetting()

                        loc.restart()
                    } else result.success("not service run")
                }
                "getLoca" -> {
                    if (isServiceRun(MainService::class.java.name)) {
                        var loc = _Location.getInstance()
                        var now = loc.getNowLocation()

                        //Log.d(TAG, "${now.toString()}")

                        result.success(now.toString())
                    } else result.success("not service run")
                }
            }
        }

    }
    private fun isServiceRun(serviceName: String): Boolean{
        var manager :ActivityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        for(service in manager.getRunningServices(Integer.MAX_VALUE)){
             if(serviceName.equals(service.service.className)) return true
        }
        return false
    }

}
