import 'package:flutterf10/helper/dto/focusStat.dart';

class ChanODay {

  bool success;
  List<Chans> chans;

  ChanODay.fromJsonMap(Map<String, dynamic> map):
        success = map["success"],
        chans = List<Chans>.from(map["chans"].map((it) => Chans.fromJsonMap(it)));

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = success;
    data['chans'] = chans != null ?
    this.chans.map((v) => v.toJson()).toList()
        : null;
    return data;
  }

}