import 'dart:convert';
import "package:multi_sort/multi_sort.dart";
import 'package:flutterf10/helper/dto/focusRsp.dart';
import 'package:flutterf10/helper/dto/focusStat.dart';
import 'package:flutterf10/helper/dto/ruleRsp.dart';
import 'package:flutterf10/helper/net/doPost.dart';
import 'package:flutterf10/helper/net/log.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> GetFocusStat() async {
  print("GetFocusStat called");
  await Post("getStat").then((rsp) async {
    try {
      FocusStat stat = FocusStat.fromJsonMap(jsonDecode(rsp));
      if (!stat.success) {
        throw Exception("failed to get FocusStat");
      } else if (stat.chans.length == 0) {
        throw Exception("empty FocusStat.Chans");
      } else {
        final sp = await SharedPreferences.getInstance();
        Map<String, int> chanMsg = Map<String, int>();
        stat.chans.forEach((chan) {
          chanMsg[chan.ChanName] = chan.NoMsg;
        });
        sp.setString("stat", jsonEncode(chanMsg));
      }
      return Future.value(null);
    } catch (e) {
      print("GetFocusStat=" + e.toString());
      Log(e.toString());
    }
  }).catchError((e) {
    print("GetFocusStat=" + e.toString());
    Log(e.toString());
  });
}

Future<void> GetFocus({String chan = "", date = ""}) async {
  print("GetFocus called");

  await Post("readFocus",
          param: "{\"chan\":{\"id\":\"$chan\"},\"date\":\"$date\",\"del\":0, \"fav\":2}")
      .then((rsp) async {

    try {
      FocusRsp focus = FocusRsp.fromJsonMap(jsonDecode(rsp));
      if (!focus.success) {
        throw Exception("failed to get Focus");
      } else if (focus.msg.length == 0) {
        throw Exception("empty Focus");
      } else {
        final sp = await SharedPreferences.getInstance();
        Map<String, List<Msg>> chanMsg = Map<String, List<Msg>>();
//        print("doReq=======>");
//        print(focus.msg.length);
        focus.msg.forEach((msg) {
          if (chanMsg.containsKey(msg.Chan)) {
            chanMsg[msg.Chan].add(msg);
          } else {
            chanMsg[msg.Chan] = [msg];
          }
          // if(msg.Chan=="题材达人"){print("tabudpate:${msg.Tabupdatetime}");}
        });
// multisort
        if (chanMsg.containsKey("财务")){
          chanMsg["财务"].multisort([false,false],["fetchtime","inc"]);
        }
        sp.setString("chanMsg", jsonEncode(chanMsg));

//        print("spChanMsg==========" + sp.getString("chanMsg"));
      }

      return Future.value(null);
    } catch (e) {
      print("GetFocus=" + e.toString());
      Log(e.toString());
    }
  }).catchError((e) {
    print("GetFocus=" + e.toString());
    Log(e.toString());
  });
}
Future<List<Msg>> GetRecoveryList() async {
  print("GetRecoveryList called");
  // pass fav=2 (not 0/1) to match all fav case
  String rsp = await Post("readFocus",param: "{\"del\":1, \"fav\":2}");
//  print(rsp);
  FocusRsp r = FocusRsp.fromJsonMap(jsonDecode(rsp));
  return r.msg;
}

Future<List<Chans>> GetChanODay() async {
  print("GetChanODay called");
  String rsp = await Post("getChanODay",param:"{}");
  FocusStat r = FocusStat.fromJsonMap(jsonDecode(rsp));
  return r.chans;
}
void SetChanODay(String p) async {
  print("SetChanODay called");
  Post("setChanODay", param: "{\"chans\":[$p]}").then((rsp) {
    Fluttertoast.showToast(
      msg: jsonDecode(rsp)["msg"],
    );
  });
}

Future<List<Rule>> GetRules(String tarCol) async {
  print("GetRules called");
  print(tarCol);
  String rsp = await Post("getRules",param:"{\"rules\":[{\"tar_col\":\"$tarCol\"}]}");
  RuleRsp r = RuleRsp.fromJsonMap(jsonDecode(rsp));
  return r.rules;
}

void DeleteOneRule(String id, bool delFocus) {
  print("DeleteOneRule called");
  String p;
  if (delFocus==true){
    p="{\"rules\":[{\"id\":\"$id\",\"tar_col\":\"applyToFocus\"}]}";
  }else{
    p="{\"rules\":[{\"id\":\"$id\"}]}";
  }

  Post("deleteRules", param: p).then((rsp) {
    Fluttertoast.showToast(
      msg: jsonDecode(rsp)["msg"],
    );
  });
}

void CreateOneRule(String channel,String keyword,Map<int,String>cond1,Map<int,String>cond2,String tar_col) {
  print("CreateOneRule called");
  print(cond1);
  Post("createRules", param: "{\"rules\":[{\"tar_col\":\"$tar_col\",\"channel\":\"$channel\",\"key\":\"$keyword\",\"cond1\":[\"${cond1.values.toList().join("\",\"")}\"],\"cond2\":[\"${cond2.values.toList().join("\",\"")}\"]}]}").then((rsp) {
    Fluttertoast.showToast(
      msg: jsonDecode(rsp)["msg"],
    );
  });
}

void UpdateOneRule(String id,String channel,String keyword,Map<int,String>cond1,Map<int,String>cond2,String tar_col) {
  print("UpdateOneRule called");
  print(cond1);
  Post("updateRules", param: "{\"rules\":[{\"tar_col\":\"$tar_col\",\"id\":\"$id\",\"channel\":\"$channel\",\"key\":\"$keyword\",\"cond1\":[\"${cond1.values.toList().join("\",\"")}\"],\"cond2\":[\"${cond2.values.toList().join("\",\"")}\"]}]}").then((rsp) {
    Fluttertoast.showToast(
      msg: jsonDecode(rsp)["msg"],
    );
  });
}

void GenerateFocus() {
  print("GenerateFocus called");
  Post("generateFocus").then((rsp) {

  });
}

void ToggleFocusDel(String objectId,int del) {
  print("ToggleFocusDel called");
  Post("toggleFocusDel", param: "{\"objectId\":\"$objectId\",\"del\":$del}").then((rsp) {
    Fluttertoast.showToast(
      msg: rsp,
    );
  });
}

void ToggleFocusFav(String objectId,int fav) {
  print("ToggleFocusFav called");
  Post("toggleFocusFav", param: "{\"objectId\":\"$objectId\",\"fav\":$fav}").then((rsp) {
    Fluttertoast.showToast(
      msg: rsp,
    );
  });
}