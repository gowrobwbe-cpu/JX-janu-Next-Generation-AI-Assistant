package com.example.jx_ai_companion

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class JXNotificationListenerService : NotificationListenerService() {

    companion object {
        var isConnected: Boolean = false
            private set
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        isConnected = true
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        isConnected = false
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        // Notification posted
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        // Notification removed
    }
}
