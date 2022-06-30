package com.hansung.zipsai

import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.IBinder
import android.widget.Toast

class _Receiver : BroadcastReceiver(){
    override fun onReceive(context: Context?, intent: Intent?) {
        //Toast.makeText(context, "testoast", Toast.LENGTH_SHORT).show()

        val it = Intent(context,MainService::class.java)
        context?.stopService(it)
    }
}