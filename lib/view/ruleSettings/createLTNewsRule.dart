import 'package:flutter/material.dart';
import 'package:flutterf10/notification/doRequest.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddLTNewsRuleDialog extends StatefulWidget {
  String channel;
  String keyword;
  Map<int, String> contains = Map<int, String>();
  Map<int, String> excludes = Map<int, String>();
  String id;

  AddLTNewsRuleDialog(String id, String keyword, Map<int, String> contains, Map<int, String> excludes,String channel) {
    this.id = id;
    this.keyword = keyword;
    this.channel = channel;
    this.contains=contains;
    this.excludes=excludes;
  }

  @override
  _AddLTNewsRuleDialogState createState() => _AddLTNewsRuleDialogState(
      this.id, this.keyword, this.contains, this.channel, this.excludes);
}

class _AddLTNewsRuleDialogState extends State<AddLTNewsRuleDialog> {
  final _formAddRuleKey = GlobalKey<FormState>();
  String channel;
  String keyword;
  Map<int, String> contains;
  String id;
  Map<int, String> excludes;

  _AddLTNewsRuleDialogState(
      this.id, this.keyword, this.contains, this.channel, this.excludes);

  String checkEmpty(dynamic value) {
    if (value == null || value == "") {
      return "不能为空";
    }
    return null;
  }
  String checkEmptyAndLen(dynamic value){
    if (value == null || value == "") {
      return "不能为空";
    }
    if (value.toString().length!=6){
      return "代码需要6位";
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
              if (contains.length == 0) {
                Fluttertoast.showToast(
                  msg: "\"代码\"不可为空",
                );
                return;
              }
              if (form.validate()) {
                form.save();
                if (id != null && id != "") {
                  UpdateOneRule(id, channel, keyword, contains,excludes,"latest_tips_news");
                } else {
                  //call create
                  CreateOneRule(channel, keyword, contains,excludes,"latest_tips_news");
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
                      _buildContainsListView(),
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

  Widget _buildContainsListView() {
    return ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: _buildContainFormField());
  }


  List<Widget> _buildContainFormField() {
    List<Widget> res = List<Widget>();
    res.add(ListTile(
        title: Text(
          "代码",
          key: ObjectKey("contains"),
        ),
        trailing: IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {
              setState(() {
                int c = 0;
                contains.forEach((k, _) {
                  if (k > c) {
                    c = k;
                  }
                });
                contains[c + 1] = "";
              });
            })));
    contains.forEach((k, v) {
      res.add(TextFormField(
        key: ObjectKey(k),
        decoration: InputDecoration(
            labelText: res.length > 1 ? "AND" : "",
            prefixIcon: Icon(Icons.format_list_numbered),
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    contains.remove(k);
                  });
                })),
        keyboardType: TextInputType.text,
        initialValue: v,
        validator: (value) {
          return checkEmptyAndLen(value);
        },
        onChanged: (value) => contains[k] = value,
      ));
    });

    return res;
  }
}
