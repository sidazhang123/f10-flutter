import 'dart:convert';

import 'package:rflutter_alert/rflutter_alert.dart';

class FocusRsp {
  bool success;
  List<Msg> msg;

  FocusRsp.fromJsonMap(Map<String, dynamic> map) {
    success = map["success"];
    var dec = jsonDecode(map["msg"]);
    if (dec == null || dec.length == 0) {
      msg = [];
    } else {
      msg = List<Msg>.from(dec.map((it) => Msg.fromJsonMap(it)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = success;
    data['msg'] = msg != null ? this.msg.map((v) => v.toJson()).toList() : null;
    return data;
  }
}

class Msg {
  String Id;
  String Gentime;
  String Code;
  String Name;
  String Fetchtime;
  String Tabupdatetime;
  String
      Keys; //"{\"最新报道\": {\"Msg\": \"2020-03-20森远股份\",\"Contain\": [\"一季度\",\"扭亏为盈\"]}}"
  String Chan;
  int Fav;
  int Del;
  RegExp exp = new RegExp(r"增长([\d.]+)%");

  Msg.fromJsonMap(Map<String, dynamic> map)
      : Id = map["_id"],
        Gentime = map["Gentime"],
        Code = map["Code"],
        Name = map["Name"],
        Fetchtime = map["Fetchtime"],
        Keys = map["Keys"],
        Chan = map["Chan"],
        Fav = map["Fav"],
        Del = map["Del"],
        Tabupdatetime =
            map.containsKey("tabupdatetime") ? map["tabupdatetime"] : "";

  Msg.copy(Msg other)
      : this.Id = other.Id,
        this.Gentime = other.Gentime,
        this.Code = other.Code,
        this.Name = other.Name,
        this.Fetchtime = other.Fetchtime,
        this.Keys = other.Keys,
        this.Chan = other.Chan,
        this.Fav = other.Fav,
        this.Del = other.Del,
        this.Tabupdatetime = other.Tabupdatetime;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = Id;
    data['Gentime'] = Gentime;
    data['Code'] = Code;
    data['Name'] = Name;
    data['Fetchtime'] = Fetchtime;
    data['Keys'] = Keys;
    data['Chan'] = Chan;
    data['Fav'] = Fav;
    data["Del"] = Del;
    data["tabupdatetime"] = Tabupdatetime;
    return data;
  }

  dynamic get(String propertyName) {
    switch (propertyName) {
      case "inc":
        {
          RegExpMatch m = exp.firstMatch(this.Keys);
          if (m != null) {
            double d = double.tryParse(m.group(1));
            if (d != null) {
              return d;
            }
          }
          return 0.0;
        }
        break;

      case "fetchtime":
        {
          return int.parse(this.Fetchtime.replaceAll("-", ""));
        }
        break;

      case "code":
        {
          return int.parse(this.Code);
        }
        break;

      default:
        {
          return null;
        }
        break;
    }
  }
}
