import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterf10/helper/dto/ruleRsp.dart';
import 'package:flutterf10/notification/doRequest.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'createFARule.dart';

class FARules extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FARulesState();
}

class FARulesState extends State<FARules> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.reply),
        ),
        title: Text("\"财务分析\"规则"),
        actions: <Widget>[
          FlatButton(
              child: Icon(Icons.cloud_done),
              onLongPress: () {
                Fluttertoast.showToast(
                  toastLength: Toast.LENGTH_LONG,
                  msg: "正在生成，请等待通知推送，不要重复触发",
                );
                GenerateFocus();
              }),
        ],
      ),
      body: RefreshIndicator(
          child: _rulesFutureBuilder(),
          onRefresh: () async {
            setState(() {});
          }),
      floatingActionButton: buildAddRule(),
    );
  }

  buildAddRule() {
    return FloatingActionButton(
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: () {
        navRule(context, Rule(), Map<int, String>(),Map<int, String>()).then((res) {
          if (res == true) {
            setState(() {});
          }
        });
      },
      child: Icon(Icons.add),
    );
  }

  Widget _buildCard(BuildContext context, Rule rule) {

    Map<int, String> npMap = Map<int, String>();
    Map<int, String> npPerMap = Map<int, String>();
    String npStr = "";
    for (int i = 0; i < rule.cond1.length; i++) {
      List<String> a=rule.cond1[i].split("|");
      npMap[i]=a[0];
      npPerMap[i] = a[1];
      npStr += "净利>${a[0]}且增长>${a[1]}% 或\n";
    }
    if (npStr.length > 0) {
      npStr = npStr.substring(0, npStr.length - 2);
    }


    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Slidable.builder(
        actionPane: SlidableStrechActionPane(),
        secondaryActionDelegate: SlideActionBuilderDelegate(
            actionCount: 2,
            builder: (context, index, animation, renderingMode) {
              if (index == 0) {
                return IconSlideAction(
                  caption: 'Edit',
                  color: Colors.blue,
                  icon: Icons.edit,
                  onTap: () {
                    navRule(context, rule, npMap,npPerMap).then((res) {
                      if (res == true) {
                        setState(() {});
                      }
                    });
                  },
                  closeOnTap: false,
                );
              } else {
                return IconSlideAction(
                  caption: 'Delete',
                  closeOnTap: false,
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () {
                    _buildConfirmationDialog(context, rule.id).then((b) {
                      if (b == true) {
                        setState(() {});
                      }
                    });
                  },
                );
              }
            }),
        key: Key(rule.id),
        child: ListTile(
          title: Text(
              "财务分析满足:\n$npStr\n则推送到\"${rule.channel}\""),
        ),
      ),
    );
  }

  Future<bool> navRule(
      BuildContext context, Rule rule, Map<int, String> npMap,Map<int, String> npPerMap) async {

    return await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddFARuleDialog( rule.id,npMap,npPerMap,rule.channel),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildCardListView(List<Rule> rules) {
    return ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 20.0),
        children: rules.map((rule) => _buildCard(context, rule)).toList());
  }

  Widget _rulesFutureBuilder() {
    return FutureBuilder<List<Rule>>(
      future: GetRules("financial_analysis"), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<Rule>> snapshot) {
        if (snapshot.hasData) {
          List<Rule> rules = snapshot.data;
          return SingleChildScrollView(
              physics:AlwaysScrollableScrollPhysics(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 16, bottom: 8)),
                    _buildCardListView(rules),
                  ]));
        } else if (snapshot.hasError) {
          return Center(
              child: Column(
            children: <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ],
          ));
        } else {
          return Center(
              child: Column(children: <Widget>[
            SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Awaiting result...'),
            )
          ]));
        }
      },
    );
  }

  Future<bool> _buildConfirmationDialog(
      BuildContext context, String documentID) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete'),
          content: Text('Rule will be deleted'),
          actions: <Widget>[
            FlatButton(
              color:Colors.indigo,
                textColor: Colors.white,
                child: Text('删除'),
                onPressed: () {
                  DeleteOneRule(documentID,false);
                  Navigator.of(context).pop(true);
                }),
            FlatButton.icon(
                icon: Icon(Icons.info,color: Colors.red,),
                label: Text('同时删推送'),
                color:Colors.indigo,
                textColor: Colors.redAccent,
                onPressed: () {
                  DeleteOneRule(documentID,true);
                  Navigator.of(context).pop(true);
                }),
            FlatButton(
              child: Text('取消'),
              color:Colors.indigo,
              textColor: Colors.white,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        );
      },
    );
  }
}
