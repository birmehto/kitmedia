package com.kitmedia.player

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import android.widget.Toast
import androidx.annotation.NonNull
import com.example.kitmedia.VideoOperationsPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.kitmedia.player/android"
    private val INTENT_CHANNEL = "com.kitmedia.player/intent"
    private lateinit var androidPlatformHandler: AndroidPlatformHandler
    private var sharedVideoPath: String? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Handle incoming intent
        handleIntent(intent)
        
        // Register the video operations plugin
        flutterEngine.plugins.add(VideoOperationsPlugin())
        
        androidPlatformHandler = AndroidPlatformHandler(this)
        
        // Setup intent channel for receiving shared videos
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INTENT_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSharedVideo" -> {
                    result.success(sharedVideoPath)
                    sharedVideoPath = null // Clear after reading
                }
                else -> result.notImplemented()
            }
        }
        
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

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return

        when (intent.action) {
            Intent.ACTION_VIEW, Intent.ACTION_SEND -> {
                val uri = if (intent.action == Intent.ACTION_SEND) {
                    intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
                } else {
                    intent.data
                }

                uri?.let {
                    sharedVideoPath = getPathFromUri(it)
                    // Notify Flutter about the new video
                    flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                        MethodChannel(messenger, INTENT_CHANNEL).invokeMethod("onVideoReceived", sharedVideoPath)
                    }
                }
            }
        }
    }

    private fun getPathFromUri(uri: Uri): String? {
        return when (uri.scheme) {
            "file" -> uri.path
            "content" -> {
                try {
                    val cursor = contentResolver.query(uri, arrayOf(android.provider.MediaStore.Video.Media.DATA), null, null, null)
                    cursor?.use {
                        if (it.moveToFirst()) {
                            val columnIndex = it.getColumnIndexOrThrow(android.provider.MediaStore.Video.Media.DATA)
                            return it.getString(columnIndex)
                        }
                    }
                    // Fallback: return URI as string
                    uri.toString()
                } catch (e: Exception) {
                    uri.toString()
                }
            }
            else -> uri.toString()
        }
    }
}