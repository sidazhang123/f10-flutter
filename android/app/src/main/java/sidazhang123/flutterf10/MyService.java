package sidazhang123.flutterf10;

import android.annotation.SuppressLint;
import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.PowerManager;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

public class MyService extends Service {

    PowerManager.WakeLock wakeLock;
    boolean isServiceStarted = false;

    @Override
    public void onCreate() {
        super.onCreate();
        startNotification(this);
        PowerManager powerManager = (PowerManager) getSystemService(POWER_SERVICE);
        wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK,
                "MyApp::MyWakelockTag");
        wakeLock.acquire();

    }

    //    private void startNotification() {
//        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
//            isServiceStarted=true;
//            NotificationCompat.Builder builder = new NotificationCompat
//                    .Builder(this,createNotificationChannel("f10_service", "f10 Background Service"))
//                    .setContentText("running in background")
//                    .setContentTitle("f10提醒")
//                    .setSmallIcon(R.drawable.launch_background);
//
//            startForeground(101,builder.build());
//        }
//    }
    private void startNotification(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationCompat.Builder builder = new NotificationCompat
                    .Builder(context, createNotificationChannel("f10_service", "f10 Background Service"))
                    .setContentText("running in background")
                    .setContentTitle("f10")
                    .setSmallIcon(R.drawable.launch_background);

            startForeground(101, builder.build());
            isServiceStarted = true;
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private String createNotificationChannel(String channelId, String channelName) {
        NotificationChannel chan = new NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_NONE);
        chan.setLightColor(Color.BLUE);
        chan.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);
        NotificationManager service = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        service.createNotificationChannel(chan);
        return channelId;
    }

    public int onStartCommand(Intent intent, int flags, int startId) {
        String serviceAction = intent.getAction();

        if ("sidazhang123.flutterf10.ACTION.STOP_SERVICE".equals(serviceAction)) {
            Log.d("fg_service", "Stopping fg service");
            stopForeground(true);
            stopSelf();
        } else if ("sidazhang123.flutterf10.ACTION.START_SERVICE".equals(serviceAction) && !isServiceStarted) {
            Log.d("fg_service", "Starting fg service");
            isServiceStarted = true;

            startNotification(this);

        }
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        Log.e("f10", "onDestroy ");
        if (isServiceStarted) {
            isServiceStarted = false;
            if (wakeLock.isHeld()) {
                wakeLock.release();
            }
        }
        super.onDestroy();
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        Log.e("f10", "onTaskRemoved ");
        ensureService();
        super.onTaskRemoved(rootIntent);
    }

    private void ensureService() {
        int restartAlarmInterval = 5 * 1000;
        int resetAlarmTimer = 3 * 1000;
        // From this broadcast I am restarting the service
        Intent restartIntent = new Intent(this, MyService.class);
        restartIntent.setFlags(Intent.FLAG_RECEIVER_FOREGROUND);
        AlarmManager alarmMgr = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
        @SuppressLint("HandlerLeak")
        Handler mHandler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                Log.e("f10", "call alarm manager ");
                PendingIntent pendingIntent = PendingIntent.getBroadcast(getApplicationContext(), 87, restartIntent, PendingIntent.FLAG_CANCEL_CURRENT);
                long timer = System.currentTimeMillis() + restartAlarmInterval;
                int sdkInt = Build.VERSION.SDK_INT;

                if (sdkInt >= Build.VERSION_CODES.M) {
                    alarmMgr.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timer, pendingIntent);
                } else if (sdkInt >= Build.VERSION_CODES.KITKAT) {
                    alarmMgr.setExact(AlarmManager.RTC_WAKEUP, timer, pendingIntent);
                } else {
                    alarmMgr.set(AlarmManager.RTC_WAKEUP, timer, pendingIntent);
                }
                sendEmptyMessageDelayed(0, resetAlarmTimer);
                stopSelf();
            }
        };
        mHandler.sendEmptyMessageDelayed(0, 0);
    }
}
