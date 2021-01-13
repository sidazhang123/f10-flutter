import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterf10/helper/dto/focusRsp.dart';
import 'package:flutterf10/helper/dto/keyField.dart';
import 'package:flutterf10/notification/doRequest.dart';

class Recovery extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => recoveryState();
}

class recoveryState extends State<Recovery> {
  List<Msg> msgList;

  recoveryState() {
    if (msgList == null) {
      GetRecoveryList().then((r) {
        msgList = r;
      });
    }
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
        title: Text("推送回收站"),
      ),
      body: RefreshIndicator(
          child: _recoveryListFutureBuilder(),
          onRefresh: () async {
            setState(() {});
          }),
    );
  }

  Widget _recoveryListFutureBuilder() {
    return FutureBuilder<List<Msg>>(
      future: GetRecoveryList(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<Msg>> snapshot) {
        if (snapshot.hasData) {
          msgList = snapshot.data;
          List<TextSpan> tsList;
          return ListView.builder(
            itemCount: msgList.length,
            itemBuilder: (context, index) {
              Msg item = msgList[index];
              jsonDecode(item.Keys).forEach((k, v) {
                KeyField keyObj =
                    KeyField.fromJsonMap(v as Map<String, dynamic>);
                tsList = [TextSpan(text: keyObj.Msg)];
                markText(keyObj.Contain, tsList);
                tsList.insert(0, TextSpan(text: k + "\n"));
              });
              return Column(
                children: <Widget>[
                  Dismissible(
                    key: ValueKey(item),
                    background: Container(
                      color: Colors.green,
                      alignment: AlignmentDirectional.centerStart,
                      child: Icon(
                        Icons.restore,
                        color: Colors.white,
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.green,
                      alignment: AlignmentDirectional.centerStart,
                      child: Icon(
                        Icons.restore,
                        color: Colors.white,
                      ),
                    ),
                    child: Column(children: <Widget>[
                      ListTile(
                        title: Text(
                            '${item.Code}  ${item.Name}  ${item.Fetchtime.substring(2)}  ${item.Chan}',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white70)),
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  minWidth: double.infinity),
                              child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: tsList,
                                ),
                              ))),
                      const Divider(
                        color: Colors.lightBlueAccent,
                        height: 10,
                        thickness: 3,
                      ),
                    ]),
                    confirmDismiss: (direction) async {
                      setState(() {
                        // set del=0 marking as recovered
                        ToggleFocusDel(item.Id, 0);
                        msgList.removeAt(index);
                      });
                      return true;
                    },
                  )
                ],
              );
            },
          );
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
        } else if (snapshot.data==null) {
          return ListTile(
            title: Text("列表为空，刷新试试？"),
          );
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

  void markText(List<String> set, List<TextSpan> s) {
    for (var i = 0; i < set.length; i++) {
      var cur = 0;
      while (cur < s.length) {
        var item = s[cur];
        var sList = item.text.split(set[i]);
        var offset = 0;
        if (sList.length > 1) {
          s.removeAt(cur);
          for (var j = 0; j < sList.length; j++) {
            s.insert(cur + offset, TextSpan(text: sList[j]));
            offset += 1;
            if (j != sList.length - 1) {
              s.insert(cur + offset,
                  TextSpan(text: set[i], style: TextStyle(color: Colors.red)));
              offset += 1;
            }
          }
        }
        if (offset > 0) {
          cur += offset;
        } else {
          cur += 1;
        }
      }
    }
  }
}
