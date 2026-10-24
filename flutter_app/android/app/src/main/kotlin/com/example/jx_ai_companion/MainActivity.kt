package com.example.jx_ai_companion

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.database.Cursor
import android.graphics.Path
import android.graphics.Rect
import android.media.AudioManager
import android.net.Uri
import android.os.Bundle
import android.provider.ContactsContract
import android.provider.MediaStore
import android.provider.Settings
import android.text.TextUtils
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.URLEncoder

class MainActivity : FlutterFragmentActivity() {
    private val SYSTEM_CHANNEL = "com.jx.ai/system"
    private val TOOLS_CHANNEL = "com.jx.ai/android_tools"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. System Channel (Settings, Accessibility Status, Volume)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SYSTEM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityEnabled" -> {
                    result.success(isAccessibilitySettingsOn(applicationContext))
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "isNotificationListenerEnabled" -> {
                    val packageName = packageName
                    val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
                    val enabled = flat != null && flat.contains(packageName)
                    result.success(enabled)
                }
                "openNotificationListenerSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "performGlobalAction" -> {
                    val actionName = call.argument<String>("action")
                    val actionCode = when (actionName?.lowercase()) {
                        "back" -> AccessibilityService.GLOBAL_ACTION_BACK
                        "home" -> AccessibilityService.GLOBAL_ACTION_HOME
                        "recents" -> AccessibilityService.GLOBAL_ACTION_RECENTS
                        "notifications" -> AccessibilityService.GLOBAL_ACTION_NOTIFICATIONS
                        "quick_settings" -> AccessibilityService.GLOBAL_ACTION_QUICK_SETTINGS
                        else -> AccessibilityService.GLOBAL_ACTION_BACK
                    }
                    val success = JXAccessibilityService.performGlobal(actionCode)
                    result.success(success)
                }
                "adjustVolume" -> {
                    val direction = call.argument<String>("direction")
                    val percent = call.argument<Int>("percent")
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    val maxVol = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                    val flag = AudioManager.FLAG_SHOW_UI

                    if (percent != null) {
                        val targetVol = ((percent / 100.0) * maxVol).toInt().coerceIn(0, maxVol)
                        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, targetVol, flag)
                    } else {
                        when (direction?.lowercase()) {
                            "up" -> audioManager.adjustStreamVolume(AudioManager.STREAM_MUSIC, AudioManager.ADJUST_RAISE, flag)
                            "down" -> audioManager.adjustStreamVolume(AudioManager.STREAM_MUSIC, AudioManager.ADJUST_LOWER, flag)
                            "mute" -> audioManager.adjustStreamVolume(AudioManager.STREAM_MUSIC, AudioManager.ADJUST_MUTE, flag)
                        }
                    }
                    val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                    val percentage = (currentVolume.toDouble() / maxVol.toDouble() * 100).toInt()
                    result.success(mapOf("currentVolume" to currentVolume, "percentage" to percentage, "maxVolume" to maxVol))
                }
                else -> result.notImplemented()
            }
        }

        // 2. Real Android Tools Channel (Apps, Search, YouTube, WhatsApp, Phone, Camera, UI Control)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TOOLS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // APP CONTROL
                "openApp" -> {
                    val appName = call.argument<String>("appName") ?: ""
                    val packageName = call.argument<String>("packageName")
                    val res = launchAppByNameOrPackage(appName, packageName)
                    result.success(res)
                }
                "findInstalledApps" -> {
                    val query = call.argument<String>("query")?.lowercase() ?: ""
                    val apps = getInstalledAppsList(query)
                    result.success(apps)
                }
                "openSettingsSection" -> {
                    val section = call.argument<String>("section") ?: "main"
                    val success = openAndroidSettings(section)
                    result.success(mapOf("success" to success, "section" to section))
                }

                // WEB SEARCH & BROWSER
                "searchWeb" -> {
                    val query = call.argument<String>("query") ?: ""
                    val engine = call.argument<String>("engine") ?: "google"
                    val success = launchWebSearch(query, engine)
                    result.success(mapOf("success" to success, "query" to query))
                }

                // YOUTUBE
                "openYouTube" -> {
                    val query = call.argument<String>("query")
                    val success = launchYouTube(query)
                    result.success(mapOf("success" to success, "query" to query))
                }

                // WHATSAPP
                "openWhatsApp" -> {
                    val phone = call.argument<String>("phone")
                    val message = call.argument<String>("message")
                    val success = launchWhatsApp(phone, message)
                    result.success(mapOf("success" to success, "phone" to phone, "message" to message))
                }

                // PHONE & CONTACTS
                "searchContacts" -> {
                    val nameQuery = call.argument<String>("query") ?: ""
                    val contacts = queryContacts(nameQuery)
                    result.success(contacts)
                }
                "preparePhoneCall" -> {
                    val phoneNumber = call.argument<String>("phoneNumber") ?: ""
                    val success = launchDialer(phoneNumber)
                    result.success(mapOf("success" to success, "phoneNumber" to phoneNumber))
                }

                // CAMERA & GALLERY & MAPS
                "openCamera" -> {
                    val mode = call.argument<String>("mode") ?: "photo"
                    val success = launchCamera(mode)
                    result.success(mapOf("success" to success, "mode" to mode))
                }
                "openGallery" -> {
                    val success = launchGallery()
                    result.success(mapOf("success" to success))
                }
                "openMaps" -> {
                    val query = call.argument<String>("query") ?: ""
                    val success = launchMaps(query)
                    result.success(mapOf("success" to success, "query" to query))
                }

                // ACCESSIBILITY UI CONTROLS
                "inspectScreenHierarchy" -> {
                    val tree = JXAccessibilityService.dumpHierarchy()
                    result.success(tree)
                }
                "findAndClickNode" -> {
                    val text = call.argument<String>("text")
                    val viewId = call.argument<String>("viewId")
                    val contentDesc = call.argument<String>("contentDescription")
                    val success = JXAccessibilityService.findAndClick(text, viewId, contentDesc)
                    result.success(mapOf("success" to success, "target" to (text ?: viewId ?: contentDesc)))
                }
                "performScroll" -> {
                    val direction = call.argument<String>("direction") ?: "down"
                    val success = JXAccessibilityService.scroll(direction)
                    result.success(mapOf("success" to success, "direction" to direction))
                }
                "typeTextInNode" -> {
                    val targetText = call.argument<String>("targetText")
                    val textToType = call.argument<String>("text") ?: ""
                    val success = JXAccessibilityService.typeText(targetText, textToType)
                    result.success(mapOf("success" to success, "text" to textToType))
                }

                else -> result.notImplemented()
            }
        }
    }

    // --- APP LAUNCHING LOGIC ---
    private fun launchAppByNameOrPackage(appName: String, explicitPackage: String?): Map<String, Any> {
        val pm = packageManager

        if (!explicitPackage.isNullOrEmpty()) {
            val intent = pm.getLaunchIntentForPackage(explicitPackage)
            if (intent != null) {
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)
                return mapOf("success" to true, "appName" to appName, "packageName" to explicitPackage)
            }
        }

        // Common popular apps fast-mapping
        val knownPackages = mapOf(
            "youtube" to "com.google.android.youtube",
            "whatsapp" to "com.whatsapp",
            "facebook" to "com.facebook.katana",
            "fb" to "com.facebook.katana",
            "instagram" to "com.instagram.android",
            "chrome" to "com.android.chrome",
            "maps" to "com.google.android.apps.maps",
            "gmail" to "com.google.android.gm",
            "camera" to null, // handled by Intent
            "gallery" to "com.google.android.apps.photos",
            "settings" to "com.android.settings",
            "play store" to "com.android.vending",
            "clock" to "com.google.android.deskclock",
            "calculator" to "com.google.android.calculator"
        )

        val lowerName = appName.lowercase().trim()
        val pkg = knownPackages[lowerName]

        if (pkg != null) {
            val intent = pm.getLaunchIntentForPackage(pkg)
            if (intent != null) {
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)
                return mapOf("success" to true, "appName" to appName, "packageName" to pkg)
            }
        }

        // Search installed applications for matching label
        val packages = pm.getInstalledPackages(PackageManager.GET_META_DATA)
        for (p in packages) {
            val appInfo = p.applicationInfo ?: continue
            val label = pm.getApplicationLabel(appInfo).toString().lowercase()
            if (label == lowerName || label.contains(lowerName) || lowerName.contains(label)) {
                val launchIntent = pm.getLaunchIntentForPackage(p.packageName)
                if (launchIntent != null) {
                    launchIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(launchIntent)
                    return mapOf("success" to true, "appName" to label, "packageName" to p.packageName)
                }
            }
        }

        // If not found as app, fallback to opening market or browser search
        return mapOf(
            "success" to false,
            "errorMessage" to "App '$appName' was not found on this device."
        )
    }

    private fun getInstalledAppsList(query: String): List<Map<String, String>> {
        val pm = packageManager
        val list = mutableListOf<Map<String, String>>()
        val packages = pm.getInstalledPackages(0)

        for (p in packages) {
            val appInfo = p.applicationInfo ?: continue
            if ((appInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0) {
                // Skip internal system apps without launcher intents unless queried
                if (pm.getLaunchIntentForPackage(p.packageName) == null) continue
            }
            val label = pm.getApplicationLabel(appInfo).toString()
            if (query.isEmpty() || label.lowercase().contains(query) || p.packageName.lowercase().contains(query)) {
                list.add(mapOf("name" to label, "packageName" to p.packageName))
            }
        }
        return list.take(50)
    }

    private fun openAndroidSettings(section: String): Boolean {
        return try {
            val intentAction = when (section.lowercase()) {
                "wifi" -> Settings.ACTION_WIFI_SETTINGS
                "bluetooth" -> Settings.ACTION_BLUETOOTH_SETTINGS
                "display" -> Settings.ACTION_DISPLAY_SETTINGS
                "sound" -> Settings.ACTION_SOUND_SETTINGS
                "apps" -> Settings.ACTION_APPLICATION_SETTINGS
                "battery" -> Settings.ACTION_BATTERY_SAVER_SETTINGS
                "accessibility" -> Settings.ACTION_ACCESSIBILITY_SETTINGS
                else -> Settings.ACTION_SETTINGS
            }
            val intent = Intent(intentAction).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    // --- WEB SEARCH ---
    private fun launchWebSearch(query: String, engine: String): Boolean {
        return try {
            val url = if (query.startsWith("http://") || query.startsWith("https://")) {
                query
            } else {
                "https://www.google.com/search?q=" + URLEncoder.encode(query, "UTF-8")
            }
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    // --- YOUTUBE ---
    private fun launchYouTube(query: String?): Boolean {
        return try {
            if (query.isNullOrBlank()) {
                val intent = packageManager.getLaunchIntentForPackage("com.google.android.youtube")
                if (intent != null) {
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    return true
                }
            }
            val uri = if (query.isNullOrBlank()) {
                Uri.parse("https://www.youtube.com")
            } else {
                Uri.parse("https://www.youtube.com/results?search_query=" + URLEncoder.encode(query, "UTF-8"))
            }
            val intent = Intent(Intent.ACTION_VIEW, uri).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    // --- WHATSAPP ---
    private fun launchWhatsApp(phone: String?, message: String?): Boolean {
        return try {
            val encodedMsg = if (message != null) URLEncoder.encode(message, "UTF-8") else ""
            val uri = if (!phone.isNullOrBlank()) {
                val cleanPhone = phone.replace("+", "").replace(" ", "").replace("-", "")
                Uri.parse("https://api.whatsapp.com/send?phone=$cleanPhone&text=$encodedMsg")
            } else {
                Uri.parse("https://api.whatsapp.com/send?text=$encodedMsg")
            }
            val intent = Intent(Intent.ACTION_VIEW, uri).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                setPackage("com.whatsapp")
            }
            // Fallback without package if whatsapp app isn't bound directly
            try {
                startActivity(intent)
            } catch (ex: Exception) {
                intent.setPackage(null)
                startActivity(intent)
            }
            true
        } catch (e: Exception) {
            false
        }
    }

    // --- CONTACTS & PHONE ---
    private fun queryContacts(query: String): List<Map<String, String>> {
        val results = mutableListOf<Map<String, String>>()
        val uri: Uri = ContactsContract.CommonDataKinds.Phone.CONTENT_URI
        val projection = arrayOf(
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
            ContactsContract.CommonDataKinds.Phone.NUMBER
        )
        val selection = if (query.isNotEmpty()) {
            "${ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME} LIKE ?"
        } else null
        val selectionArgs = if (query.isNotEmpty()) arrayOf("%$query%") else null

        var cursor: Cursor? = null
        try {
            cursor = contentResolver.query(uri, projection, selection, selectionArgs, null)
            if (cursor != null) {
                val nameIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
                val numberIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
                while (cursor.moveToNext() && results.size < 10) {
                    val name = cursor.getString(nameIndex) ?: ""
                    val number = cursor.getString(numberIndex) ?: ""
                    results.add(mapOf("name" to name, "number" to number))
                }
            }
        } catch (e: Exception) {
            // Permission not granted or query failed
        } finally {
            cursor?.close()
        }
        return results
    }

    private fun launchDialer(phoneNumber: String): Boolean {
        return try {
            val uri = Uri.parse("tel:" + Uri.encode(phoneNumber))
            val intent = Intent(Intent.ACTION_DIAL, uri).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    // --- CAMERA, GALLERY & MAPS ---
    private fun launchCamera(mode: String): Boolean {
        return try {
            val intent = if (mode.lowercase() == "video") {
                Intent(MediaStore.ACTION_VIDEO_CAPTURE)
            } else {
                Intent(MediaStore.ACTION_IMAGE_CAPTURE)
            }
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun launchGallery(): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_VIEW).apply {
                type = "image/*"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun launchMaps(query: String): Boolean {
        return try {
            val uri = if (query.isNotEmpty()) {
                Uri.parse("geo:0,0?q=" + Uri.encode(query))
            } else {
                Uri.parse("geo:0,0")
            }
            val intent = Intent(Intent.ACTION_VIEW, uri).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun isAccessibilitySettingsOn(context: Context): Boolean {
        var accessibilityEnabled = 0
        val service = "${context.packageName}/${JXAccessibilityService::class.java.canonicalName}"
        try {
            accessibilityEnabled = Settings.Secure.getInt(
                context.applicationContext.contentResolver,
                Settings.Secure.ACCESSIBILITY_ENABLED
            )
        } catch (e: Settings.SettingNotFoundException) {
            // Ignored
        }
        val mStringColonSplitter = TextUtils.SimpleStringSplitter(':')
        if (accessibilityEnabled == 1) {
            val settingValue = Settings.Secure.getString(
                context.applicationContext.contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            )
            if (settingValue != null) {
                mStringColonSplitter.setString(settingValue)
                while (mStringColonSplitter.hasNext()) {
                    val accessibilityService = mStringColonSplitter.next()
                    if (accessibilityService.equals(service, ignoreCase = true)) {
                        return true
                    }
                }
            }
        }
        return false
    }
}
