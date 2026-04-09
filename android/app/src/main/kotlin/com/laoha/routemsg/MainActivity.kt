package com.laoha.routemsg

import android.net.wifi.WifiManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.laoha.routemsg/multicast_lock"
    private var multicastLock: WifiManager.MulticastLock? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "acquireLock" -> {
                    acquireMulticastLock()
                    result.success(true)
                }
                "releaseLock" -> {
                    releaseMulticastLock()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun acquireMulticastLock() {
        val wifiManager = applicationContext.getSystemService(WIFI_SERVICE) as WifiManager
        // 标签用于日志调试
        multicastLock = wifiManager.createMulticastLock("DiscoveryMulticastLock")
        multicastLock?.setReferenceCounted(true)
        try {
            multicastLock?.acquire()
            println("[UDP] MulticastLock acquired successfully")
        } catch (e: Exception) {
            println("[UDP] Failed to acquire lock: ${e.message}")
        }
    }

    private fun releaseMulticastLock() {
        if (multicastLock != null && multicastLock!!.isHeld) {
            multicastLock?.release()
            println("[UDP] MulticastLock released")
        }
        multicastLock = null
    }

    override fun onDestroy() {
        releaseMulticastLock()
        super.onDestroy()
    }
}
