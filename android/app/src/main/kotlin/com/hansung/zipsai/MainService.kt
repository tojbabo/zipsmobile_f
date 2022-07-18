package com.hansung.zipsai

import android.annotation.SuppressLint
import android.app.*
import android.content.Context
import android.content.Intent
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.IBinder
import android.widget.Toast
import androidx.annotation.RequiresApi
import io.flutter.Log
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.io.*
import java.util.*

class MainService : Service() {
    private val NOTIFICATION_ID = 1
    private val CHANNEL_NAME = "Zips Ai"
    private val CHANNEL_ID = "ZABS"
    private val TAG = "kotlin debug"

    private lateinit var tcp: _Tcp
    private lateinit var loc: _Location

    private  lateinit var temp: tempLoc

    private lateinit var queue: Queue<JSONObject>

    override fun onCreate() {
        super.onCreate()
        queue = LinkedList()

        tcp = _Tcp.getInstance()
        tcp.initialize(queue as LinkedList<JSONObject>,this)
        loc = _Location.getInstance()
        loc.initialize(this, queue as LinkedList<JSONObject>)

        temp = tempLoc.getInstance()
        temp.initialize(this)
    }

    override fun onBind(intent: Intent): IBinder {
        TODO("Return the communication channel to the service.")
    }

    override fun onDestroy() {
        Toast.makeText(this, "service done", Toast.LENGTH_SHORT).show()

        var manager = getSystemService(NOTIFICATION_SERVICE)  as NotificationManager
        manager.cancelAll()


        tcp.jobdoen()
        loc.jobdoen()

        temp.jobdoen()


        // 여러 작업들 종료 시키는 
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG,"Service Run")

        GlobalScope.launch {
        }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) setNotification()

            var flag = temp.initSetting()
            if (flag) {
                temp.doLocation()
                //tcp.doNetwork()
                //loc.doLocation()
            } else {
                stopSelf()
            }

        return super.onStartCommand(intent, flags, startId)
    }

    // 알림창 생성 함수
    @RequiresApi(Build.VERSION_CODES.O)
    private fun setNotification() {
        // 선택으로 메인 화면으로 이동하는 인텐트
        val pending2Main: PendingIntent =
                Intent(this,MainActivity::class.java).let { notificationIntent->
                    PendingIntent.getActivities(this,0, arrayOf(notificationIntent),PendingIntent.FLAG_IMMUTABLE)
                }

        // 끄기 버튼 선택시 리시버로e
        val pending2Out = Intent(this,_Receiver::class.java).apply {
            action = CHANNEL_ID
            putExtra(CHANNEL_ID,0)
        }

        // 리시버로 연결
        val broadcast  = PendingIntent.getBroadcast(this,0,pending2Out,PendingIntent.FLAG_IMMUTABLE)

        val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_DEFAULT
        )

        var manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)

        val notification = Notification.Builder(this,CHANNEL_ID)
                .setContentTitle("Zips Ai")
                .setContentText("위치 정보 전송 중")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pending2Main)
                .addAction(R.drawable.launch_background,"끄기",broadcast)
                .build()

        startForeground(NOTIFICATION_ID, notification)
    }
}
