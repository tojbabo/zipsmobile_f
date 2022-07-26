package com.hansung.zipsai

const val AUTO = 1
const val MANUAL = 0
const val STATE_UNREQ = 10
const val STATE_REQ = 11
const val STATE_DENY = 12
const val STATE_ACPT = 13

const val STATE_DISCONN = 1
const val STATE_CONN = 2

class _Val private constructor(){
    companion object{
        private var instance: _Val? = null
        fun getInstance(): _Val=
                instance?: synchronized(this){
                    instance?: _Val().also {
                        instance = it
                    }
                }
    }

    var id: String = "999"
    var ip: String = "dev.zips.ai"
    var port: String = "10000"
    var interval: Long = 30*1000
    var minDistance: Float = 5.0f
    var minAccuracy: Int = 20
}