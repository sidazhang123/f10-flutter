import 'package:flutter/material.dart';
import 'package:flutterf10/notification/doRequest.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddLTRuleDialog extends StatefulWidget {
  String channel;
  String keyword;
  Map<int, String> contains = Map<int, String>();
  Map<int, String> excludes = Map<int, String>();
  String id;

  AddLTRuleDialog(String id, String keyword, Map<int, String> contains, Map<int, String> excludes,String channel) {
    this.id = id;
    this.keyword = keyword;
    this.channel = channel;
    this.contains=contains;
    this.excludes=excludes;
  }

  @override
  _AddLTRuleDialogState createState() => _AddLTRuleDialogState(
      this.id, this.keyword, this.contains, this.channel, this.excludes);
}

class _AddLTRuleDialogState extends State<AddLTRuleDialog> {
  final _formAddRuleKey = GlobalKey<FormState>();
  String channel;
  String keyword;
  Map<int, String> contains;
  String id;
  Map<int, String> excludes;

  _AddLTRuleDialogState(
      this.id, this.keyword, this.contains, this.channel, this.excludes);

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
              if (contains.length == 0 && excludes.length == 0) {
                Fluttertoast.showToast(
                  msg: "\"包含\"与\"排除\"不可同时为空",
                );
                return;
              }
              if (form.validate()) {
                form.save();
                if (id != null && id != "") {
                  UpdateOneRule(id, channel, keyword, contains,excludes,"latest_tips");
                } else {
                  //call create
                  CreateOneRule(channel, keyword, contains,excludes,"latest_tips");
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
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '在...中',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    initialValue:
                        keyword != null && keyword.isNotEmpty ? keyword : "",
                    validator: (value) {
                      return checkEmpty(value);
                    },
                    onChanged: (value) => keyword = value,
                  ),
                  Divider(),
                  _buildContainsListView(),
                  Divider(),
                  _buildExcludesListView(),
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

  Widget _buildExcludesListView() {
    return ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: _buildExcludeFormField());
  }

  List<Widget> _buildExcludeFormField() {
    List<Widget> res = List<Widget>();
    res.add(ListTile(
        title: Text(
          "排除",
          key: ObjectKey("excludes"),
        ),
        trailing: IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {
              setState(() {
                int c = 0;
                excludes.forEach((k, _) {
                  if (k > c) {
                    c = k;
                  }
                });
                excludes[c + 1] = "";
              });
            })));
    excludes.forEach((k, v) {
      res.add(TextFormField(
        key: ObjectKey(k),
        decoration: InputDecoration(
            labelText: res.length > 0 ? "OR" : "",
            prefixIcon: Icon(Icons.format_clear),
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    excludes.remove(k);
                  });
                })),
        keyboardType: TextInputType.text,
        initialValue: v,
        validator: (value) {
          return checkEmpty(value);
        },
        onChanged: (value) => excludes[k] = value,
      ));
    });

    return res;
  }

  List<Widget> _buildContainFormField() {
    List<Widget> res = List<Widget>();
    res.add(ListTile(
        title: Text(
          "包含",
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
            labelText: res.length > 0 ? "AND" : "",
            prefixIcon: Icon(Icons.format_size),
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
          return checkEmpty(value);
        },
        onChanged: (value) => contains[k] = value,
      ));
    });

    return res;
  }
}
