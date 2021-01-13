class RuleRsp {
  bool success;
  List<Rule> rules;

  RuleRsp.fromJsonMap(Map<String, dynamic> map)
      : success = map["success"],
        rules = List<Rule>.from(map["rules"].map((it) => Rule.fromJsonMap(it)));

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = success;
    data['rules'] =
        rules != null ? this.rules.map((v) => v.toJson()).toList() : null;
    return data;
  }
}

class Rule {
  String channel;
  String key;
  String tar_col;
  List<String> cond1;
  List<String> cond2;
  String id;

  Rule(
      {this.channel = "",
      this.key = "",
      this.cond1,
      this.cond2,
      this.id = "",
      this.tar_col = ""});

  Rule.fromJsonMap(Map<String, dynamic> map) {
    channel = map["channel"];
    key = map["key"];
    cond1 = map["cond1"]==null?List<String>():List<String>.from(map["cond1"]);
    cond2 = map["cond2"]==null?List<String>():List<String>.from(map["cond2"]);
    id = map["id"];
    tar_col = map["tar_col"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['channel'] = channel;
    data['key'] = key;
    data['cond1'] = cond1;
    data['cond2'] = cond2;
    data['id'] = id;
    data['tar_col'] = tar_col;
    return data;
  }
}
