import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterf10/helper/dto/focusRsp.dart';
import 'package:flutterf10/helper/dto/global.dart';
import 'package:flutterf10/helper/dto/keyField.dart';
import 'package:flutterf10/notification/doRequest.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwipingSlidableList extends StatefulWidget {
  GlobalKey<ScaffoldState> _key;

  SwipingSlidableList(GlobalKey<ScaffoldState> key) {
    this._key = key;
  }

  _SwipingSlidableListState createState() => _SwipingSlidableListState(_key);
}

class _SwipingSlidableListState extends State<SwipingSlidableList> {
  Map<String, List<Msg>> chanMsg = {};
  String chanMsgStr = "";
  String curChan;
  BuildContext Bcontext;
  bool pull = false;
  GlobalKey<ScaffoldState> _key;
  final sp = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    tab2panelStream.stream.listen((chan) {
      setState(() {
        curChan = chan;
      });
    });
    header2panelStream.stream.listen((openDialog) {
      if (openDialog = true) {
        _buildReport().then((tsList) {
          _onOpenReportDialog(Bcontext, tsList);
        });
      }
    });
  }

  Future<List<InlineSpan>> _buildReport() async {
    List<InlineSpan> tsList = [];

    List<Msg> t = [];
    chanMsg.forEach((_, msgList) {
      msgList.forEach((m) {
        t.add(m);
      });
    });
    t.sort((a, b) => a.Code.compareTo(b.Code));
    t.forEach((m) {
      tsList.add(TextSpan(
          text: m.Code,
          style:
              TextStyle(color: m.Fav == 1 ? Colors.pinkAccent : Colors.white)));
      tsList.add(WidgetSpan(
        child: Icon(
          Icons.more_vert,
          color: Colors.lightBlueAccent,
        ),
      ));
    });

    return Future.value(tsList);
  }

  _SwipingSlidableListState(GlobalKey<ScaffoldState> key) {
    this._key = key;
    sp.then((s) async {
      chanMsgStr = s.getString("chanMsg");

      if (chanMsgStr == "" || chanMsgStr == null) {
        await GetFocus().then((_) {
          chanMsgStr = s.getString("chanMsg");
          chanMsg = {};
          jsonDecode(chanMsgStr).forEach((k, v) {
            chanMsg[k] =
                (v as List<dynamic>).map((m) => Msg.fromJsonMap(m)).toList();
          });
        });
      } else {
        chanMsg = {};
        jsonDecode(chanMsgStr).forEach((k, v) {
          chanMsg[k] =
              (v as List<dynamic>).map((m) => Msg.fromJsonMap(m)).toList();
        });
      }
    });
  }

  handleDismiss(int index, String curC) {
    // Get a reference to the swiped item
    final swipedMsg = Msg.copy(chanMsg[curC][index]);
    String id = chanMsg[curC][index].Id;
    String name = chanMsg[curC][index].Name;
    setState(() {
      chanMsg[curC].removeAt(index);
    });

    _key.currentState.removeCurrentSnackBar();
    _key.currentState
        .showSnackBar(
          SnackBar(
            content: Text("Del $name"),
            duration: Duration(seconds: 3),
            action: SnackBarAction(
                label: "Undo",
                textColor: Colors.purpleAccent,
                onPressed: () {
                  // Insert it at swiped position and set state
                  setState(() => chanMsg[curC].insert(index, swipedMsg));
                }),
          ),
        )
        .closed
        .then((reason) {
      if (reason != SnackBarClosedReason.action) {
        // The SnackBar was dismissed by some other means
        // that's not clicking of action button
        // Make API call to backend
        ToggleFocusDel(id, 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Bcontext = context;
    return Container(
      child: RefreshIndicator(
          child: _SwipingListFutureBuilder(),
          onRefresh: () async {
            chanMsg = {};
            await GetFocusStat().then((_) async {
              await GetFocus().then((_) {
                panel2tabStream.add(true);

                setState(() {});
              });
            });
          }),
    );
  }

  Widget _SwipingListFutureBuilder() {
    double textsize = 16.0;
    return FutureBuilder(
      future: _buildSwipingListFuture(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String curC = (curChan == "" || curChan == null)
              ? chanMsg.keys.elementAt(0)
              : curChan;
//          msgs = (chanMsg[curC] as List<dynamic>)
//              .map((m) => Msg.fromJsonMap(m))
//              .toList();

          List<Msg> msgList = chanMsg[curC];

          return ListView.builder(
            itemCount: msgList.length,
            itemBuilder: (context, index) {
              Msg item = msgList[index];
              List<TextSpan> tsList = [];
              Map<String, dynamic> keysMap = jsonDecode(item.Keys);
              int c = 0;
              keysMap.forEach((k, v) {
                c += 1;
                KeyField keyObj =
                    KeyField.fromJsonMap(v as Map<String, dynamic>);
                List<TextSpan> tsListOfKey = [
                  TextSpan(
                      text: c < keysMap.length
                          ? keyObj.Msg.trim() + "\n"
                          : keyObj.Msg.trim(),
                      style: TextStyle(fontSize: textsize - 1))
                ];
//                print("keyObjMsg=>${keyObj.Msg}");
                markText(keyObj.Contain, tsListOfKey, textsize);
                tsListOfKey.insert(
                    0,
                    TextSpan(
                        text: k.length > 0 ? k + "\n" : "",
                        style: TextStyle(
                            backgroundColor: Colors.yellowAccent,
                            color: Colors.black,
                            fontSize: textsize - 1)));
                tsList += tsListOfKey;
              });

              return Column(
                children: <Widget>[
                  Dismissible(
                    key: ValueKey(item),
                    background: Container(
                      color: Colors.redAccent[700],
                      alignment: AlignmentDirectional.centerStart,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.pinkAccent[100],
                      alignment: AlignmentDirectional.centerEnd,
                      child: Icon(
                        Icons.favorite,
                        color: Colors.white,
                      ),
                    ),
                    child: Column(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: 8, right: 8, top: 2, bottom: 0),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 0),
                              child: Opacity(
                                opacity: item.Fav == 1 ? 1.0 : 0.0,
                                child: Icon(Icons.favorite,
                                    color: Colors.pinkAccent),
                              ),
                            ),
                            Align(
                              alignment: Alignment(-1.3, 0),
                              child: Text(
                                  '${item.Code}  ${item.Name}  ${item.Fetchtime.substring(2)} ${(item.Tabupdatetime != null && item.Tabupdatetime.length > 0) ? " @${item.Tabupdatetime.substring(3, 5)}月" : ""}',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 17,
                                    color: Colors.white70,
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 0.0, bottom: 5.0),
                          child: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: tsList,
                            ),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      const Divider(
                        color: Colors.blueGrey,
                        height: 1,
                        indent: 16.0,
                        endIndent: 16.0,
                        thickness: 0.5,
                      ),
                    ]),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        handleDismiss(index, curC);
//                        setState(() {
                        // set del=1 marking as deletedop
//                          ToggleFocusDel(chanMsg[curC][index].Id, 1);
//                          chanMsg[curC].removeAt(index);
//                        });
                        return true;
                      } else {
                        setState(() {
                          if (chanMsg[curC][index].Fav == 1) {
                            ToggleFocusFav(chanMsg[curC][index].Id, 0);
                            chanMsg[curC][index].Fav = 0;
                          } else {
                            ToggleFocusFav(chanMsg[curC][index].Id, 1);
                            chanMsg[curC][index].Fav = 1;
                          }
                        });
                        return false;
                      }
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
              ),
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

  Future<Map> _buildSwipingListFuture() async {
    if (chanMsg != null && chanMsg.length > 0) {

      return Future.value(chanMsg);
    }
    return await sp.then((s) {
      chanMsgStr = s.getString("chanMsg");
      chanMsg = {};
      jsonDecode(chanMsgStr).forEach((k, v) {

        chanMsg[k] =
            (v as List<dynamic>).map((m) => Msg.fromJsonMap(m)).toList();
      });
      return Future.value(chanMsg);
    });
  }

  void markText(List<String> set, List<TextSpan> s, double textsize) {
    for (var i = 0; i < set.length; i++) {
      var cur = 0;
      while (cur < s.length) {
        var item = s[cur];
        var sList = item.text.split(set[i]);
        var offset = 0;
        if (sList.length > 1) {
          s.removeAt(cur);
          for (var j = 0; j < sList.length; j++) {
            s.insert(cur + offset,
                TextSpan(text: sList[j], style: TextStyle(fontSize: textsize)));
            offset += 1;
            if (j != sList.length - 1) {
              s.insert(
                  cur + offset,
                  TextSpan(
                      text: set[i],
                      style: TextStyle(color: Colors.red, fontSize: textsize)));
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

  _onOpenReportDialog(context, tsList) {
    var alertStyle = AlertStyle(
      constraints: BoxConstraints.expand(),
      buttonAreaPadding: const EdgeInsets.all(10.0),
    );
    Alert(
        buttons: [],
        title: "",
        context: context,
        style: alertStyle,
        content: Center(
            child: SingleChildScrollView(
//                    physics: AlwaysScrollableScrollPhysics(),
                child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: tsList,
          ),
        )))).show();
  }
}

/////////////////////////////////////////////////
