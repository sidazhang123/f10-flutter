import 'package:flutter/material.dart';
import 'package:flutterf10/const.dart';
import 'package:flutterf10/helper/net/doPost.dart';
import 'package:flutterf10/notification/doRequest.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
class RegisterJPush {
  String debugLable = 'Unknown';

  /*错误信息*/
  static final JPush jpush = new JPush();

  Future<void> initPlatformState(BuildContext context) async {
    jpush.getRegistrationID().then((rid) {
      print("jpush_id:$rid");
      //register to server
      Post("jpushReg",JPushID: rid).then((i)=>{Fluttertoast.showToast(
          msg: i,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0
      )});
    });

    jpush.setup(
      appKey: JPushAppKey,
      channel: "developer-default",
      production: false,
      debug: true,
    );

    try {
      jpush.addEventHandler(

        onReceiveNotification: (Map<String, dynamic> message) async {
//          print("flutter onReceiveNotification: $message");
//          print("message title: ${message["title"]}");
          if (message["title"]=="f10提醒" && (message["alert"] as String).contains("提醒")) {
            GetFocusStat();
            GetFocus();
          }
        },
        onOpenNotification: (Map<String, dynamic> message) async {
          GetFocusStat();
          GetFocus();
          print("flutter onOpenNotification: $message");
        },
        onReceiveMessage: (Map<String, dynamic> message) async {
          print("flutter onReceiveMessage: $message");
        },

      );
    } on Exception {

    }
  }
}
