package com.example.screen_stream
import android.os.Parcelable
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.media.projection.MediaProjection
import android.os.Build
import android.os.IBinder
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat

class MyMediaProjectionService : Service() {

    companion object {
        const val CHANNEL_ID = "media_projection_channel"
        const val NOTIFICATION_ID = 1
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIFICATION_ID, createNotification())

        // Retrieve MediaProjection object
        val mediaProjection = intent?.getParcelableExtra<Parcelable>("MEDIA_PROJECTION") as? MediaProjection
        mediaProjection?.let {
            startMediaProjection(it)
        }

        return START_NOT_STICKY
    }

    private fun startMediaProjection(mediaProjection: MediaProjection) {
        // TODO: Add screen recording or streaming logic here
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Screen Recording Service")
            .setContentText("Recording your screen...")
            .setSmallIcon(android.R.drawable.ic_dialog_info) // Replace with your notification icon
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Screen Recording",
            NotificationManager.IMPORTANCE_LOW
        )
        val manager = getSystemService(NotificationManager::class.java)
        manager?.createNotificationChannel(channel)
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null // Not a bound service
    }
}
