package com.example.focus_app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class AppBlockerService : AccessibilityService() {

    private val PREFS_NAME = "blocked_apps_prefs"
    private val BLOCKED_APPS_KEY = "blocked_apps_list"
    private val FOCUS_ACTIVE_KEY = "focus_mode_active"

    private var blockedApps: Set<String> = emptySet()
    private var isFocusActive: Boolean = false
    private var lastBlockedTime: Long = 0
    private val BLOCK_COOLDOWN_MS: Long = 1000

    override fun onServiceConnected() {
        super.onServiceConnected()

        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
            notificationTimeout = 100
        }
        serviceInfo = info

        loadBlockedApps()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        loadFocusState()

        if (!isFocusActive) return

        val packageName = event.packageName?.toString() ?: return

        if (packageName == this.packageName) return
        if (packageName == "com.android.systemui") return
        if (packageName == "com.android.launcher") return
        if (packageName == "com.android.launcher3") return
        if (packageName == "com.google.android.apps.nexuslauncher") return

        loadBlockedApps()

        if (blockedApps.contains(packageName)) {
            val currentTime = System.currentTimeMillis()

            if (currentTime - lastBlockedTime > BLOCK_COOLDOWN_MS) {
                lastBlockedTime = currentTime
                redirectToFocusApp()
            }
        }
    }

    override fun onInterrupt() {
        // Required override - no action needed
    }

    override fun onDestroy() {
        super.onDestroy()
    }

    private fun loadBlockedApps() {
        try {
            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            blockedApps = prefs.getStringSet(BLOCKED_APPS_KEY, emptySet()) ?: emptySet()
        } catch (e: Exception) {
            blockedApps = emptySet()
        }
    }

    private fun loadFocusState() {
        try {
            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            isFocusActive = prefs.getBoolean(FOCUS_ACTIVE_KEY, false)
        } catch (e: Exception) {
            isFocusActive = false
        }
    }

    private fun redirectToFocusApp() {
        try {
            val intent = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("blocked_redirect", true)
            }
            startActivity(intent)
        } catch (e: Exception) {
            // Silent fail to prevent crash in accessibility service
        }
    }
}
