import 'package:flutterf10/helper/net/auth_decrypt/encrypt.dart';
import 'package:flutterf10/helper/net/doPost.dart';

void Log(String msg)  {
     Post("log",param: Encrypt(msg));
}