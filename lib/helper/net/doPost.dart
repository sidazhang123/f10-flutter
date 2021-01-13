import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutterf10/const.dart';
import 'package:flutterf10/helper/net/auth_decrypt/decrypt.dart';

import 'auth_decrypt/auth.dart';
import 'auth_decrypt/encrypt.dart';

var dio = Dio();
const route = {
  "createRules": "rules/create",
  "getRules": "rules/get",
  "deleteRules": "rules/delete",
  "updateRules": "rules/update",
  "readFocus": "focus/get",
  "purgeFocus": "focus/purge",
  "generateFocus":"focus/generate",
  "jpushReg": "jpush_reg",
  "getStat": "focus/stat",
  "log": "log",
  "toggleFocusDel": "focus/delete",
  "toggleFocusFav":"focus/fav",
  "getChanODay":"chan_o_day/get",
  "setChanODay":"chan_o_day/set",
};

// ignore: non_constant_identifier_names
Future<String> Post(String routeStr,
    {String param = "{}",
    ContentType = "application/x-www-form-urlencoded",
    JPushID = ""}) async {
  try {
    print(routeStr);
    dio.options.headers[""] = GenAuthHeader();
    dio.options.headers["Content-Type"] = ContentType;
    if (JPushID != "") {
      dio.options.headers["jpush_id"] = JPushID;
    }
    dio.transformer = FlutterTransformer();
    dio.options.receiveTimeout = 3000;
    dio.options.connectTimeout = 3000;

    var msg = await dio.post(BaseUrl + route[routeStr], data: Encrypt(param));
    return Future.value(Decrypt(msg.toString()));
  } on DioError catch (e) {
    if (e.response == null) {
      print(e);
    } else {
      await Future.error(Decrypt(e.response.toString().trim()));
    }
  }
}
