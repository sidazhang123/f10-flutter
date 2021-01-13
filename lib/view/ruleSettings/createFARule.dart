import 'package:flutter/material.dart';
import 'package:flutterf10/notification/doRequest.dart';

class AddFARuleDialog extends StatefulWidget {
  String channel;
  Map<int, String> npMap = Map<int, String>();
  Map<int, String> npPerMap = Map<int, String>();
  String id;

  AddFARuleDialog(String id, Map<int, String> npMap, Map<int, String> npPerMap,
      String channel) {
    this.id = id;
    this.channel = channel;
    this.npMap = npMap;
    this.npPerMap = npPerMap;
  }

  @override
  _AddFARuleDialogState createState() =>
      _AddFARuleDialogState(this.id, this.npMap, this.channel, this.npPerMap);
}

class _AddFARuleDialogState extends State<AddFARuleDialog> {
  final _formAddRuleKey = GlobalKey<FormState>();
  String channel;
  Map<int, String> npMap;
  String id;
  Map<int, String> npPerMap;

  _AddFARuleDialogState(this.id, this.npMap, this.channel, this.npPerMap);

  String checkEmpty(String value) {
    if (value == null || value == "") {
      return "不能为空";
    }
    return null;
  }

  String checkFormat(String value) {
    print(value);
    double r = double.tryParse(value);
    print(r);
    if (r == null ) {
      return "格式错误";
    }
    return null;
  }

  String checkLessThan(int k, String v) {
    if (k == 0) {
      return null;
    }
    double curNp = double.tryParse(v);
    if (curNp == null ) {
      return "格式错误";
    }

    double lastNp = double.tryParse(npMap[k - 1]);
    if (lastNp == null ) {
      return "上一条格式错误";
    }
    if (lastNp <= curNp) {
      return "不得>=上条净利";
    }
    return null;
  }
  Map<int,String> mergeMaps(Map<int,String> f,Map<int,String> b){
    Map<int,String> r=Map<int,String>();
    f.forEach((k,v){
      r[k]=v+"|"+b[k];
    });
    return r;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              final form = _formAddRuleKey.currentState;

              if (form.validate()) {
                form.save();
                if (id != null && id != "") {
                  //save one cond, merge
                  UpdateOneRule(
                      id, channel, "", mergeMaps(npMap,npPerMap), Map<int,String>(), "financial_analysis");
                } else {
                  //call create
                  CreateOneRule(
                      channel, "", mergeMaps(npMap,npPerMap), Map<int,String>(), "financial_analysis");
                }
                Navigator.of(context).pop(true);
              }
            },
            child: Text(
              id != null && id.isNotEmpty ? "UPDATE" : 'SAVE',
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(16.0),
        child: Form(
            key: _formAddRuleKey,
            child: Center(
                child: ListView(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.all(15.0),
                    children: <Widget>[
                  _buildNPListView(),
                  Divider(),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '推送到',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.speaker_phone),
                    ),
                    keyboardType: TextInputType.text,
                    initialValue:
                        channel != null && channel.isNotEmpty ? channel : "",
                    validator: (value) {
                      return checkEmpty(value);
                    },
                    onChanged: (value) => channel = value,
                  ),
                ]))),
      ),
    );
  }

  Widget _buildNPListView() {
    return ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: _buildNPFormField());
  }

  List<Widget> _buildNPFormField() {
    List<Widget> res = List<Widget>();
    res.add(ListTile(
        title: Text(
          "净利润",
          key: ObjectKey("np"),
        ),
        trailing: IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {
              setState(() {
                npMap[npMap.length]="0";
                npPerMap[npPerMap.length]="-100";
                print("$npMap,$npPerMap");
              });
            })));
    npMap.forEach((k, v) {
      res.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              // wrap your Column in Expanded
              child:
                TextFormField(
                  key: ObjectKey("np$k"),
                  decoration: InputDecoration(
                      labelText: "净利多于",
                      border: OutlineInputBorder(),
                     ),
                  keyboardType: TextInputType.text,
                  initialValue: v,
                  validator: (value) {
                    return checkLessThan(k, value);
                  },
                  onChanged: (value) => npMap[k] = value,
            ),
          ),
          Expanded(
              // wrap your Column in Expanded
              child:
                TextFormField(
                  key: ObjectKey("npper$k"),
                  decoration: InputDecoration(
                      labelText: "增长大于%",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              npMap.remove(k);
                              npPerMap.remove(k);
                            });
                          })),
                  keyboardType: TextInputType.text,
                  initialValue: npPerMap[k],
                  validator: (value) {
                    return checkFormat(value);
                  },
                  onChanged: (value) => npPerMap[k] = value,
            )
          )
        ],
      ));
    });

    return res;
  }
}
