package com.instareducation.nomokit

import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.engine.FlutterEngine
import android.hardware.usb.*
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
import android.os.Build
import android.provider.Settings
class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.instareducation.nomokit.USB_PERMISSION"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "askUsbPermission") {
                    result.success(askUsbPermission())
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun askUsbPermission(): Boolean {
        val usbManager = getSystemService(Context.USB_SERVICE) as UsbManager
        val deviceList = usbManager.deviceList
        if (deviceList.isEmpty()) {
            return false
        }
        val device = deviceList.values.iterator().next()
        if (usbManager.hasPermission(device)) {
            return true
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE
        } else {
            0
        }
        val permissionIntent = PendingIntent.getBroadcast(this, 0, Intent(CHANNEL), flags)
        usbManager.requestPermission(device, permissionIntent)
        return false
    }
}
