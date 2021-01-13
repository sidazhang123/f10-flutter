import 'package:flutter/material.dart';
import 'package:flutterf10/notification/doRequest.dart';

class AddSARuleDialog extends StatefulWidget {
  String channel;
  Map<int, String> shMap = Map<int, String>();
  Map<int, String> stMap = {0:"↑",1:"新进"};
  String id;

  AddSARuleDialog(String id, Map<int, String> shMap, Map<int, String> stMap,
      String channel) {
    this.id = id;
    this.channel = channel;
    this.shMap = shMap;
    this.stMap = stMap;
  }

  @override
  _AddSARuleDialogState createState() =>
      _AddSARuleDialogState(this.id, this.shMap, this.channel, this.stMap);
}

class _AddSARuleDialogState extends State<AddSARuleDialog> {
  final _formAddRuleKey = GlobalKey<FormState>();
  String channel;
  Map<int, String> shMap;
  String id;
  Map<int, String> stMap;

  _AddSARuleDialogState(this.id, this.shMap, this.channel, this.stMap);

  String checkEmpty(dynamic value) {
    if (value == null || value == "") {
      return "不能为空";
    }
    return null;
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
                  UpdateOneRule(id, channel, "流通占比表0", shMap, stMap,
                      "shareholder_analysis");
                } else {
                  //call create
                  CreateOneRule(
                      channel, "流通占比表0", shMap, stMap, "shareholder_analysis");
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
                  _buildSHListView(),
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

  Widget _buildSHListView() {
    return ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: _buildSHFormField());
  }




  List<Widget> _buildSHFormField() {
    List<Widget> res = List<Widget>();
    res.add(ListTile(
        title: Text(
          "股东包含",
          key: ObjectKey("sh"),
        ),
        trailing: IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {
              setState(() {
                int c = 0;
                shMap.forEach((k, _) {
                  if (k > c) {
                    c = k;
                  }
                });
                shMap[c + 1] = "";
              });
            })));
    shMap.forEach((k, v) {
      res.add(TextFormField(
        key: ObjectKey(k),
        decoration: InputDecoration(
            labelText: res.length > 0 ? "OR" : "",
            prefixIcon: Icon(Icons.format_size),
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    shMap.remove(k);
                  });
                })),
        keyboardType: TextInputType.text,
        initialValue: v,
        validator: (value) {
          return checkEmpty(value);
        },
        onChanged: (value) => shMap[k] = value,
      ));
    });

    return res;
  }
}
