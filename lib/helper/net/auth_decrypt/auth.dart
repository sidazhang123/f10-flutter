import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutterf10/const.dart';
import 'package:intl/intl.dart';
String GenAuthHeader(){
  var now =  DateTime.now().toUtc().add( Duration(hours: 8));
  var formatter = DateFormat('yyyy-MM-ddTHH:mm');
  var ss=utf8.encode(SharedSecret);
  var hmacSha256 =  Hmac(sha256, ss); // HMAC-SHA256
  var digest = hmacSha256.convert(utf8.encode(formatter.format(now))).bytes;
  var sha = sha256.convert(ss+digest);
  return sha.toString();
}
