package com.kitmedia.player

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.kitmedia.player/android"
    private lateinit var androidPlatformHandler: AndroidPlatformHandler

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        androidPlatformHandler = AndroidPlatformHandler(this)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    androidPlatformHandler.initialize()
                    result.success(true)
                }
                "getExternalStorageDirectories" -> {
                    result.success(androidPlatformHandler.getExternalStorageDirectories())
                }
                "getAvailableStorageSpace" -> {
                    val path = call.argument<String>("path")
                    result.success(androidPlatformHandler.getAvailableStorageSpace(path))
                }
                "getTotalStorageSpace" -> {
                    val path = call.argument<String>("path")
                    result.success(androidPlatformHandler.getTotalStorageSpace(path))
                }
                "isExternalStorageAvailable" -> {
                    result.success(androidPlatformHandler.isExternalStorageAvailable())
                }
                "scanMediaFiles" -> {
                    val directories = call.argument<List<String>>("directories") ?: emptyList()
                    result.success(androidPlatformHandler.scanMediaFiles(directories))
                }
                "getVideoFilesFromMediaStore" -> {
                    result.success(androidPlatformHandler.getVideoFilesFromMediaStore())
                }
                "addToMediaStore" -> {
                    val filePath = call.argument<String>("filePath")
                    result.success(androidPlatformHandler.addToMediaStore(filePath))
                }
                "deleteFromMediaStore" -> {
                    val filePath = call.argument<String>("filePath")
                    result.success(androidPlatformHandler.deleteFromMediaStore(filePath))
                }
                "requestStoragePermissions" -> {
                    result.success(androidPlatformHandler.requestStoragePermissions())
                }
                "hasStoragePermissions" -> {
                    result.success(androidPlatformHandler.hasStoragePermissions())
                }
                "requestManageExternalStoragePermission" -> {
                    result.success(androidPlatformHandler.requestManageExternalStoragePermission())
                }
                "getAndroidVersion" -> {
                    result.success(Build.VERSION.SDK_INT)
                }
                "isDeviceRooted" -> {
                    result.success(androidPlatformHandler.isDeviceRooted())
                }
                "getDeviceManufacturer" -> {
                    result.success(Build.MANUFACTURER)
                }
                "getDeviceModel" -> {
                    result.success(Build.MODEL)
                }
                "setHighPerformanceMode" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    result.success(androidPlatformHandler.setHighPerformanceMode(enabled))
                }
                "getCpuUsage" -> {
                    result.success(androidPlatformHandler.getCpuUsage())
                }
                "getMemoryUsage" -> {
                    result.success(androidPlatformHandler.getMemoryUsage())
                }
                "showToast" -> {
                    val message = call.argument<String>("message") ?: ""
                    val duration = call.argument<Int>("duration") ?: Toast.LENGTH_SHORT
                    androidPlatformHandler.showToast(message, duration)
                    result.success(null)
                }
                "vibrate" -> {
                    val duration = call.argument<Int>("duration") ?: 100
                    androidPlatformHandler.vibrate(duration.toLong())
                    result.success(null)
                }
                "keepScreenOn" -> {
                    val keepOn = call.argument<Boolean>("keepOn") ?: false
                    androidPlatformHandler.keepScreenOn(keepOn)
                    result.success(null)
                }
                "setSystemUIVisibility" -> {
                    val fullscreen = call.argument<Boolean>("fullscreen") ?: false
                    androidPlatformHandler.setSystemUIVisibility(fullscreen)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}