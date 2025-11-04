package com.kitmedia.player

import android.Manifest
import android.app.Activity
import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.os.VibrationEffect
import android.os.Vibrator
import android.provider.MediaStore
import android.provider.Settings
import android.view.View
import android.view.WindowManager
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import java.io.File
import java.io.RandomAccessFile

class AndroidPlatformHandler(private val activity: Activity) {
    private val context: Context = activity.applicationContext
    private val vibrator: Vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator

    fun initialize() {
        // Initialize any required services or configurations
    }

    // ==================== STORAGE MANAGEMENT ====================

    fun getExternalStorageDirectories(): List<String> {
        val directories = mutableListOf<String>()
        
        try {
            // Primary external storage
            val primaryExternal = Environment.getExternalStorageDirectory()
            if (primaryExternal != null && primaryExternal.exists()) {
                directories.add(primaryExternal.absolutePath)
            }

            // Secondary external storage
            val externalFilesDirs = ContextCompat.getExternalFilesDirs(context, null)
            for (dir in externalFilesDirs) {
                if (dir != null && dir.exists()) {
                    directories.add(dir.absolutePath)
                }
            }

            // Common media directories
            val mediaDirectories = listOf(
                Environment.DIRECTORY_MOVIES,
                Environment.DIRECTORY_DCIM,
                Environment.DIRECTORY_DOWNLOADS
            )

            for (mediaDir in mediaDirectories) {
                val dir = Environment.getExternalStoragePublicDirectory(mediaDir)
                if (dir != null && dir.exists()) {
                    directories.add(dir.absolutePath)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return directories.distinct()
    }

    fun getAvailableStorageSpace(path: String?): Long {
        return try {
            val targetPath = path ?: Environment.getExternalStorageDirectory().absolutePath
            val stat = StatFs(targetPath)
            stat.availableBlocksLong * stat.blockSizeLong
        } catch (e: Exception) {
            0L
        }
    }

    fun getTotalStorageSpace(path: String?): Long {
        return try {
            val targetPath = path ?: Environment.getExternalStorageDirectory().absolutePath
            val stat = StatFs(targetPath)
            stat.totalBytes
        } catch (e: Exception) {
            0L
        }
    }

    fun isExternalStorageAvailable(): Boolean {
        val state = Environment.getExternalStorageState()
        return Environment.MEDIA_MOUNTED == state
    }

    // ==================== MEDIA SCANNING ====================

    fun scanMediaFiles(directories: List<String>): List<Map<String, Any>> {
        val mediaFiles = mutableListOf<Map<String, Any>>()
        
        try {
            for (directory in directories) {
                val dir = File(directory)
                if (dir.exists() && dir.isDirectory) {
                    scanDirectory(dir, mediaFiles)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return mediaFiles
    }

    private fun scanDirectory(directory: File, mediaFiles: MutableList<Map<String, Any>>) {
        try {
            val files = directory.listFiles() ?: return
            
            for (file in files) {
                if (file.isDirectory) {
                    scanDirectory(file, mediaFiles)
                } else if (isVideoFile(file)) {
                    val fileInfo = mapOf(
                        "path" to file.absolutePath,
                        "name" to file.name,
                        "size" to file.length(),
                        "lastModified" to file.lastModified(),
                        "extension" to file.extension.lowercase()
                    )
                    mediaFiles.add(fileInfo)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun isVideoFile(file: File): Boolean {
        val videoExtensions = setOf(
            "mp4", "avi", "mkv", "mov", "wmv", "flv", "webm", "m4v",
            "3gp", "3gpp", "mts", "ts", "mpg", "mpeg", "mp2", "mpe",
            "mpv", "m2v", "m4p", "m4b", "divx", "xvid", "asf", "rm",
            "rmvb", "vob", "ogv", "drc", "mxf", "roq", "nsv"
        )
        return videoExtensions.contains(file.extension.lowercase())
    }

    fun getVideoFilesFromMediaStore(): List<Map<String, Any>> {
        val videoFiles = mutableListOf<Map<String, Any>>()
        
        try {
            val projection = arrayOf(
                MediaStore.Video.Media._ID,
                MediaStore.Video.Media.DISPLAY_NAME,
                MediaStore.Video.Media.DATA,
                MediaStore.Video.Media.SIZE,
                MediaStore.Video.Media.DATE_MODIFIED,
                MediaStore.Video.Media.DURATION,
                MediaStore.Video.Media.RESOLUTION
            )

            val cursor: Cursor? = context.contentResolver.query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                projection,
                null,
                null,
                "${MediaStore.Video.Media.DATE_MODIFIED} DESC"
            )

            cursor?.use {
                val idColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
                val nameColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME)
                val dataColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
                val sizeColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE)
                val dateColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_MODIFIED)
                val durationColumn = it.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION)

                while (it.moveToNext()) {
                    val id = it.getLong(idColumn)
                    val name = it.getString(nameColumn)
                    val path = it.getString(dataColumn)
                    val size = it.getLong(sizeColumn)
                    val dateModified = it.getLong(dateColumn)
                    val duration = it.getLong(durationColumn)

                    val videoInfo = mapOf(
                        "id" to id,
                        "name" to name,
                        "path" to path,
                        "size" to size,
                        "dateModified" to dateModified,
                        "duration" to duration
                    )
                    videoFiles.add(videoInfo)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return videoFiles
    }

    fun addToMediaStore(filePath: String?): Boolean {
        if (filePath == null) return false
        
        try {
            val file = File(filePath)
            if (!file.exists()) return false

            val intent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
            intent.data = Uri.fromFile(file)
            context.sendBroadcast(intent)
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    fun deleteFromMediaStore(filePath: String?): Boolean {
        if (filePath == null) return false
        
        try {
            val resolver: ContentResolver = context.contentResolver
            val uri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI
            val selection = "${MediaStore.Video.Media.DATA} = ?"
            val selectionArgs = arrayOf(filePath)
            
            val deletedRows = resolver.delete(uri, selection, selectionArgs)
            return deletedRows > 0
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    // ==================== PERMISSIONS ====================

    fun requestStoragePermissions(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11+ requires MANAGE_EXTERNAL_STORAGE permission
            Environment.isExternalStorageManager()
        } else {
            // Android 10 and below
            val readPermission = ContextCompat.checkSelfPermission(
                context, Manifest.permission.READ_EXTERNAL_STORAGE
            ) == PackageManager.PERMISSION_GRANTED
            
            val writePermission = ContextCompat.checkSelfPermission(
                context, Manifest.permission.WRITE_EXTERNAL_STORAGE
            ) == PackageManager.PERMISSION_GRANTED
            
            readPermission && writePermission
        }
    }

    fun hasStoragePermissions(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Environment.isExternalStorageManager()
        } else {
            val readPermission = ContextCompat.checkSelfPermission(
                context, Manifest.permission.READ_EXTERNAL_STORAGE
            ) == PackageManager.PERMISSION_GRANTED
            
            val writePermission = ContextCompat.checkSelfPermission(
                context, Manifest.permission.WRITE_EXTERNAL_STORAGE
            ) == PackageManager.PERMISSION_GRANTED
            
            readPermission && writePermission
        }
    }

    fun requestManageExternalStoragePermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                intent.data = Uri.parse("package:${context.packageName}")
                activity.startActivity(intent)
                true
            } catch (e: Exception) {
                e.printStackTrace()
                false
            }
        } else {
            true // Not needed for older versions
        }
    }

    // ==================== SYSTEM UTILITIES ====================

    fun isDeviceRooted(): Boolean {
        return try {
            val buildTags = Build.TAGS
            if (buildTags != null && buildTags.contains("test-keys")) {
                return true
            }

            val paths = arrayOf(
                "/system/app/Superuser.apk",
                "/sbin/su",
                "/system/bin/su",
                "/system/xbin/su",
                "/data/local/xbin/su",
                "/data/local/bin/su",
                "/system/sd/xbin/su",
                "/system/bin/failsafe/su",
                "/data/local/su"
            )

            for (path in paths) {
                if (File(path).exists()) return true
            }

            false
        } catch (e: Exception) {
            false
        }
    }

    // ==================== PERFORMANCE ====================

    fun setHighPerformanceMode(enabled: Boolean): Boolean {
        return try {
            if (enabled) {
                activity.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            } else {
                activity.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            }
            true
        } catch (e: Exception) {
            false
        }
    }

    fun getCpuUsage(): Double {
        return try {
            val reader = RandomAccessFile("/proc/stat", "r")
            val load = reader.readLine()
            reader.close()

            val toks = load.split(" +".toRegex()).toTypedArray()
            val idle1 = toks[4].toLong()
            val cpu1 = toks[2].toLong() + toks[3].toLong() + toks[5].toLong() + 
                      toks[6].toLong() + toks[7].toLong() + toks[8].toLong()

            Thread.sleep(360)

            val reader2 = RandomAccessFile("/proc/stat", "r")
            val load2 = reader2.readLine()
            reader2.close()

            val toks2 = load2.split(" +".toRegex()).toTypedArray()
            val idle2 = toks2[4].toLong()
            val cpu2 = toks2[2].toLong() + toks2[3].toLong() + toks2[5].toLong() + 
                       toks2[6].toLong() + toks2[7].toLong() + toks2[8].toLong()

            ((cpu2 - cpu1).toDouble() / ((cpu2 + idle2) - (cpu1 + idle1))) * 100.0
        } catch (e: Exception) {
            0.0
        }
    }

    fun getMemoryUsage(): Map<String, Long> {
        return try {
            val runtime = Runtime.getRuntime()
            mapOf(
                "totalMemory" to runtime.totalMemory(),
                "freeMemory" to runtime.freeMemory(),
                "maxMemory" to runtime.maxMemory(),
                "usedMemory" to (runtime.totalMemory() - runtime.freeMemory())
            )
        } catch (e: Exception) {
            emptyMap()
        }
    }

    // ==================== UI UTILITIES ====================

    fun showToast(message: String, duration: Int) {
        activity.runOnUiThread {
            Toast.makeText(context, message, duration).show()
        }
    }

    fun vibrate(duration: Long) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createOneShot(duration, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(duration)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun keepScreenOn(keepOn: Boolean) {
        activity.runOnUiThread {
            if (keepOn) {
                activity.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            } else {
                activity.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            }
        }
    }

    fun setSystemUIVisibility(fullscreen: Boolean) {
        activity.runOnUiThread {
            if (fullscreen) {
                activity.window.decorView.systemUiVisibility = (
                    View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                )
            } else {
                activity.window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
            }
        }
    }
}