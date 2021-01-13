import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutterf10/helper/net/auth_decrypt/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';

Future<String> getUpdateInfo() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String curVer = "v" + packageInfo.version;
  var dio = Dio();
  dio.options.headers[""] = GenAuthHeader();
  Response<dynamic> rsp =
      await dio.get("https://");
  List<String> infoList = rsp.toString().split(":");

  if (infoList.length != 2) {
    Fluttertoast.showToast(
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.grey[400],
      msg: "更新信息错误",
    );
    return Future<String>.value("");
  }
  String version=infoList[0];
  String sha=infoList[1];
  // print("$version,$sha");
  if (curVer != version) {
    print("need update $curVer=> $version");
    // get release path, the first ele indicates the apk if you have uploaded it
    return Future<String>.value(sha);
  } else {
    return Future<String>.value("");
  }
}
