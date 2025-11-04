package com.example.kitmedia

import android.app.Activity
import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.content.IntentSender
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.io.File

class VideoOperationsPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private lateinit var contentResolver: ContentResolver
    private lateinit var context: Context
    private var activity: Activity? = null
    private var pendingResult: Result? = null
    private var pendingDeleteUris: List<Uri>? = null

    companion object {
        private const val DELETE_REQUEST_CODE = 1001
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.kitmedia/video_operations")
        channel.setMethodCallHandler(this)
        contentResolver = flutterPluginBinding.applicationContext.contentResolver
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "deleteVideo" -> {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    deleteVideo(filePath, result)
                } else {
                    result.error("INVALID_ARGUMENT", "File path is required", null)
                }
            }
            "fileExists" -> {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    checkFileExists(filePath, result)
                } else {
                    result.error("INVALID_ARGUMENT", "File path is required", null)
                }
            }
            "getVideoInfo" -> {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    getVideoInfo(filePath, result)
                } else {
                    result.error("INVALID_ARGUMENT", "File path is required", null)
                }
            }
            "needsDeletePermission" -> {
                result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun deleteVideo(filePath: String, result: Result) {
        try {
            // First try to find the video in MediaStore
            val uri = getVideoUri(filePath)
            
            if (uri != null) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    // Android 11+ requires user permission for deleting media files
                    if (activity != null) {
                        try {
                            val uris = listOf(uri)
                            val deleteRequest = MediaStore.createDeleteRequest(contentResolver, uris)
                            
                            // Store the pending result and URIs for the callback
                            pendingResult = result
                            pendingDeleteUris = uris
                            
                            // Launch the system delete dialog
                            activity!!.startIntentSenderForResult(
                                deleteRequest.intentSender,
                                DELETE_REQUEST_CODE,
                                null,
                                0,
                                0,
                                0
                            )
                            return
                        } catch (e: IntentSender.SendIntentException) {
                            result.error("DELETE_ERROR", "Failed to show delete dialog: ${e.message}", null)
                            return
                        }
                    } else {
                        result.error("DELETE_ERROR", "Activity not available for delete request", null)
                        return
                    }
                } else {
                    // Android 10 and below - direct deletion
                    try {
                        val deletedRows = contentResolver.delete(uri, null, null)
                        if (deletedRows > 0) {
                            result.success(true)
                            return
                        }
                    } catch (e: SecurityException) {
                        // Permission denied, try file deletion
                    }
                }
            }
            
            // Fallback to direct file deletion
            val file = File(filePath)
            if (file.exists()) {
                val deleted = file.delete()
                result.success(deleted)
            } else {
                result.success(false)
            }
            
        } catch (e: Exception) {
            result.error("DELETE_ERROR", "Failed to delete video: ${e.message}", null)
        }
    }

    private fun checkFileExists(filePath: String, result: Result) {
        try {
            // Check in MediaStore first
            val uri = getVideoUri(filePath)
            if (uri != null) {
                result.success(true)
                return
            }
            
            // Fallback to file system check
            val file = File(filePath)
            result.success(file.exists())
            
        } catch (e: Exception) {
            result.error("CHECK_ERROR", "Failed to check file: ${e.message}", null)
        }
    }

    private fun getVideoInfo(filePath: String, result: Result) {
        try {
            val projection = arrayOf(
                MediaStore.Video.Media._ID,
                MediaStore.Video.Media.DISPLAY_NAME,
                MediaStore.Video.Media.SIZE,
                MediaStore.Video.Media.DATE_MODIFIED,
                MediaStore.Video.Media.DURATION
            )

            val selection = "${MediaStore.Video.Media.DATA} = ?"
            val selectionArgs = arrayOf(filePath)

            val cursor: Cursor? = contentResolver.query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                selectionArgs,
                null
            )

            cursor?.use {
                if (it.moveToFirst()) {
                    val info = mutableMapOf<String, Any>()
                    info["id"] = it.getLong(it.getColumnIndexOrThrow(MediaStore.Video.Media._ID))
                    info["name"] = it.getString(it.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME)) ?: ""
                    info["size"] = it.getLong(it.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE))
                    info["dateModified"] = it.getLong(it.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_MODIFIED))
                    info["duration"] = it.getLong(it.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION))
                    info["exists"] = true
                    
                    result.success(info)
                    return
                }
            }
            
            // File not found in MediaStore
            result.success(mapOf("exists" to false))
            
        } catch (e: Exception) {
            result.error("INFO_ERROR", "Failed to get video info: ${e.message}", null)
        }
    }

    private fun getVideoUri(filePath: String): Uri? {
        val projection = arrayOf(MediaStore.Video.Media._ID)
        val selection = "${MediaStore.Video.Media.DATA} = ?"
        val selectionArgs = arrayOf(filePath)

        val cursor: Cursor? = contentResolver.query(
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            null
        )

        cursor?.use {
            if (it.moveToFirst()) {
                val id = it.getLong(it.getColumnIndexOrThrow(MediaStore.Video.Media._ID))
                return ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id)
            }
        }

        return null
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: android.content.Intent?): Boolean {
        if (requestCode == DELETE_REQUEST_CODE) {
            val result = pendingResult
            pendingResult = null
            pendingDeleteUris = null

            if (result != null) {
                if (resultCode == Activity.RESULT_OK) {
                    // User granted permission, files should be deleted
                    result.success(true)
                } else {
                    // User denied permission
                    result.success(false)
                }
            }
            return true
        }
        return false
    }
}