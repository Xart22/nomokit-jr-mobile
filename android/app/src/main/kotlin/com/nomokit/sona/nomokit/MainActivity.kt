package com.sonasoft.nomokit

import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.engine.FlutterEngine
import android.provider.Settings
import android.hardware.usb.*
import android.content.Context
import android.content.Intent
import android.app.PendingIntent
class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.sonasoft.nomokit.USB_PERMISSION"

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
        val permissionIntent = PendingIntent.getBroadcast(this, 0, Intent(CHANNEL), 0)
        usbManager.requestPermission(device, permissionIntent)
        return false
    }
}
