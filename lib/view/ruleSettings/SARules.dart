import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterf10/helper/dto/ruleRsp.dart';
import 'package:flutterf10/notification/doRequest.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'createSARule.dart';

class SARules extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SARulesState();
}

class SARulesState extends State<SARules> {
  final TextEditingController _filter = TextEditingController();
  String _searchText = "";
  List<Rule> _filteredRules = List<Rule>();
  List<Rule> rules = List<Rule>();
  Widget _appBarTitle = Text("\"股东研究\"规则");
  Icon _searchIcon = new Icon(Icons.search);

  SARulesState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          _filteredRules = rules;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

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
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: _searchIcon,
            onPressed: _searchPressed,

          ),
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
          child: _rulesFetchOrFilterDispatcher(),
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

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close);
        this._appBarTitle = TextField(
          controller: _filter,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search...'
          ),
        );
      } else {
        this._searchIcon = Icon(Icons.search);
        this._appBarTitle = Text("\"股东研究\"规则");
        _filteredRules = rules;
        _filter.clear();
      }
    });
  }

  Widget _buildCard(BuildContext context, Rule rule) {
    Map<int, String> shMap = Map<int, String>();
    Map<int, String> stMap = {0:"↑",1:"新进"};
    String shStr = "";
    String stStr = "";
    for (int i = 0; i < rule.cond1.length; i++) {
      shMap[i] = rule.cond1[i];
      shStr += shMap[i] + "/";
    }
    if (shStr.length > 0) {
      shStr = shStr.substring(0, shStr.length - 1);
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
                    navRule(context, rule, shMap,stMap).then((res) {
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
              "只要股东名称中包含\"$shStr\"，\n则推送到\"${rule.channel}\""),
        ),
      ),
    );
  }

  Future<bool> navRule(BuildContext context, Rule rule, Map<int, String> shMap,Map<int, String> stMap) async {
    return await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddSARuleDialog( rule.id,shMap,stMap,rule.channel),
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

  Widget _rulesFetchOrFilterDispatcher() {
    if (_searchText.isNotEmpty && rules.isNotEmpty) {
      List<Rule> tempList = List<Rule>();
      rules.forEach((r) {
        r.cond1.forEach((personName) {
          if (personName.contains(_searchText)) {
            tempList.add(r);
            return;
          }
        });
      });
      _filteredRules = tempList;
      return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 8)),
                _buildCardListView(_filteredRules),
              ]));
    } else {
      return _rulesFutureBuilder();
    }
  }

  Widget _rulesFutureBuilder() {
    return FutureBuilder<List<Rule>>(
      future: GetRules("shareholder_analysis"), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<Rule>> snapshot) {
        if (snapshot.hasData) {
          rules = snapshot.data;
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

  Future<bool> _buildConfirmationDialog(BuildContext context, String documentID) {
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
