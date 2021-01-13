import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterf10/helper/dto/focusStat.dart';
import 'package:flutterf10/notification/doRequest.dart';

class ChanODay extends StatefulWidget {
  createState() => ChanODayState();
}

class ChanODayState extends State<ChanODay> {
  Map<String, int> chanODay = Map<String, int>();
  final _formAddRuleKey = GlobalKey<FormState>();

//  ChanODayState() {
//    GetChanODay().then((chanList) {
//      chanList.forEach((c) {
//        chanODay[c.ChanName] = c.NoMsg;
//      });
//    });
//  }

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
                var p = "";
                chanODay.forEach((c, d) {
                  p += "{\"chanName\":\"$c\",\"NoMsg\":$d},";
                });
                print("p=$p");
                SetChanODay(p.substring(0,p.length-1));
                //////////////////////////////
                Navigator.of(context).pop(true);
              }
            },
            child: Text(
              "UPDATE",
              style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
          child: _chanDayFutureBuilder(), onRefresh: () async {}),
    );
  }

  Widget _chanDayFutureBuilder() {
    return FutureBuilder<List<Chans>>(
      future: GetChanODay(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<Chans>> snapshot) {
        if (snapshot.hasData) {
          List<Chans> chans = snapshot.data;
          chans.forEach((c) {
            chanODay[c.ChanName] = c.NoMsg;
          });
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
                margin: EdgeInsets.all(16.0),
                child: Form(
                    key: _formAddRuleKey,
                    child: Center(
                        child: ListView(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.all(15.0),
                      children: _buildForm(),
                    )))),
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

  List<Widget> _buildForm() {
    List<Widget> res = List<Widget>();
    chanODay.forEach((c, d) {
      res.add(
        TextFormField(
          decoration: InputDecoration(
            labelText: c,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          initialValue: d > 0 ? d.toString() : "",
          validator: (value) {
            var i = int.tryParse(value);
            if (i == null || i <= 0) {
              return "必须正整数";
            }
            return null;
          },
          onChanged: (v) {

              chanODay[c] = int.parse(v);
              print("onChange: $chanODay");

          },
        ),
      );
      res.add(Divider());
    });

    return res;
  }
}
