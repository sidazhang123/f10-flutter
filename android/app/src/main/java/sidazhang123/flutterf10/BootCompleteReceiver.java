package sidazhang123.flutterf10;

import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;


public class BootCompleteReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        Log.e("f10", "f10 BootCompleteReceiver");
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.P) {
            Intent myIntent = new Intent(context, MyService.class);
//                myIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startForegroundService(myIntent);
        } else {
            Log.e("f10", "f10 launching from normal < API 29"); // You can still launch an Activity
            try {
                Intent intentMain = new Intent(context, MyService.class);
//                intentMain.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                if (Build.VERSION.SDK_INT < 28) {
                    context.startService(intentMain);
                } else {
                    context.startForegroundService(intentMain);
                }
            } catch (ActivityNotFoundException ex) {
                Log.e("f10", "f10 ActivityNotFoundException" + ex.getLocalizedMessage());
            }
        }
    }


}