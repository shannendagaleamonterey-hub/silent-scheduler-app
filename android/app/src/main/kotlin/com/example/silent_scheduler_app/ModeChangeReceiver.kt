package com.example.silent_scheduler_app

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.util.Log

class ModeChangeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        when (intent.action) {
            "com.example.silent_scheduler_app.APPLY_MODE" -> {
                val mode = intent.getStringExtra("mode") ?: "silent"
                Log.d("ModeChangeReceiver", "Applying mode: $mode")

                when (mode) {
                    "silent" -> {
                        if (notificationManager.isNotificationPolicyAccessGranted) {
                            notificationManager.setInterruptionFilter(
                                NotificationManager.INTERRUPTION_FILTER_NONE
                            )
                        }
                        audioManager.ringerMode = AudioManager.RINGER_MODE_SILENT
                    }

                    "vibrate" -> {
                        audioManager.ringerMode = AudioManager.RINGER_MODE_VIBRATE
                    }
                }
            }

            "com.example.silent_scheduler_app.RESTORE_MODE" -> {
                Log.d("ModeChangeReceiver", "Restoring normal mode")

                if (notificationManager.isNotificationPolicyAccessGranted) {
                    notificationManager.setInterruptionFilter(
                        NotificationManager.INTERRUPTION_FILTER_ALL
                    )
                }
                audioManager.ringerMode = AudioManager.RINGER_MODE_NORMAL
            }
        }
    }
}