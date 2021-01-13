package sidazhang123.flutterf10;


import android.content.Intent;
import android.os.Build;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


public class MainActivity extends FlutterActivity {

    private Intent forService;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        forService = new Intent(MainActivity.this, MyService.class);
//        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP_MR1) {
//            if (!Settings.canDrawOverlays(getApplicationContext())) {
//               startActivity(new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION));
//            }
//        }
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "sidazhang123.flutterf10.fgservice")
                .setMethodCallHandler(new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                        if (methodCall.method.equals("startService")) {
                            startService();
                            result.success("Service Started");
                        }
                    }
                });
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
        stopService(forService);
    }

    private void startService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(forService);
        } else {
            startService(forService);
        }
    }


}