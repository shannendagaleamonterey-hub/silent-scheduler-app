package com.example.silent_scheduler_app

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "silent_scheduler/dnd"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val notificationManager =
                    getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

                when (call.method) {
                    "isDndAccessGranted" -> {
                        result.success(notificationManager.isNotificationPolicyAccessGranted)
                    }

                    "openDndSettings" -> {
                        val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    }

                    "enableSilentMode" -> {
                        if (notificationManager.isNotificationPolicyAccessGranted) {
                            notificationManager.setInterruptionFilter(
                                NotificationManager.INTERRUPTION_FILTER_NONE
                            )
                            result.success(true)
                        } else {
                            result.error("NO_DND_ACCESS", "Do Not Disturb access not granted", null)
                        }
                    }

                    "disableSilentMode" -> {
                        if (notificationManager.isNotificationPolicyAccessGranted) {
                            notificationManager.setInterruptionFilter(
                                NotificationManager.INTERRUPTION_FILTER_ALL
                            )
                            result.success(true)
                        } else {
                            result.error("NO_DND_ACCESS", "Do Not Disturb access not granted", null)
                        }
                    }

                    "scheduleModeChange" -> {
                        val startTime = call.argument<Long>("startTime")
                        val endTime = call.argument<Long>("endTime")
                        val mode = call.argument<String>("mode") ?: "silent"

                        if (startTime == null || endTime == null) {
                            result.error("INVALID_ARGS", "Missing startTime or endTime", null)
                            return@setMethodCallHandler
                        }

                        scheduleModeChange(startTime, endTime, mode)
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun scheduleModeChange(startTime: Long, endTime: Long, mode: String) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val startIntent = Intent(this, ModeChangeReceiver::class.java).apply {
            action = "com.example.silent_scheduler_app.APPLY_MODE"
            putExtra("mode", mode)
        }

        val endIntent = Intent(this, ModeChangeReceiver::class.java).apply {
            action = "com.example.silent_scheduler_app.RESTORE_MODE"
        }

        val startPendingIntent = PendingIntent.getBroadcast(
            this,
            startTime.toInt(),
            startIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val endPendingIntent = PendingIntent.getBroadcast(
            this,
            endTime.toInt(),
            endIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            startTime,
            startPendingIntent
        )

        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            endTime,
            endPendingIntent
        )
    }
}