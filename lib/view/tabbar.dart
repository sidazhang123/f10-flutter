import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutterf10/helper/dto/global.dart';
import 'package:flutterf10/notification/doRequest.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tabbar extends StatefulWidget {
  _MyTabbar createState() => _MyTabbar();
}

class _MyTabbar extends State<Tabbar> {
  String curChan = "";
  int curInd = 0;
  List<BottomNavigationBarItem> navItems = List<BottomNavigationBarItem>();

  @override
  void initState() {
    super.initState();
    panel2tabStream.stream.listen((chan) {
      setState(() {});
    });
  }

  Future<BottomNavigationBar> _navBarItems() async {
    final sp = await SharedPreferences.getInstance();

    var jsonStr = sp.getString("stat");
    if (jsonStr == null || jsonStr == "") {
      await GetFocusStat().then((_) {
        jsonStr = sp.getString("stat");
        return BottomNavigationBar(
          currentIndex: curInd,
          type: BottomNavigationBarType.shifting,
          onTap: (ind) {
            setState(() {
              if (curInd != ind) {
                curInd = ind;
                if (navItems != null && ind < navItems.length) {
                  curChan = (navItems[ind].title as Text).data;
                  tab2panelStream.add(curChan);
                }
              }
            });
          },
          items: _buildNavBarItemList(jsonDecode(jsonStr)),
        );
      });
    }
    return BottomNavigationBar(
      type: BottomNavigationBarType.shifting,
      currentIndex: curInd,
      onTap: (ind) {
        setState(() {
          if (curInd != ind) {
            curInd = ind;
            if (navItems != null && ind < navItems.length) {
              curChan = (navItems[ind].title as Text).data;
              if (curChan != "空") {
                tab2panelStream.add(curChan);
              }
            }
          }
        });
      },
      items: _buildNavBarItemList(jsonDecode(jsonStr)),
    );
  }

  List<BottomNavigationBarItem> _buildNavBarItemList(Map<String, dynamic> a) {
    bool c = true;
    navItems.clear();
    a.forEach((k, v) {
      if (c) {
        if (curChan == "" || curChan == null) {
          curChan = k;
          tab2panelStream.add(curChan);
        }
        c = false;
      }
      navItems.add(
        BottomNavigationBarItem(
          title: Text(
            k,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          icon: Badge(
            shape: BadgeShape.circle,
            borderRadius: 100,
            child: curChan == k
                ? Icon(
              Icons.map,
              color: Colors.red.shade400,
            )
                : Icon(
              Icons.event,
              color: Colors.blue,
            ),
            badgeContent: Badge(
              elevation: 0,
              shape: BadgeShape.circle,
              padding: EdgeInsets.all(0),
              badgeContent: Text(
                v.toString(),
                style: TextStyle(color: Colors.white, wordSpacing: 0),
              ),
            ),
          ),
        ),
      );
    });
    while (navItems.length < 2) {
      navItems.add(
        BottomNavigationBarItem(title: Text("空"), icon: Icon(Icons.block)),
      );
    }

    return navItems;
  }

  @override
  Widget build(ctx) {
    return FutureBuilder<BottomNavigationBar>(
      future: _navBarItems(), // a previously-obtained Future<String> or null
      builder:
          (BuildContext context, AsyncSnapshot<BottomNavigationBar> snapshot) {
        List<Widget> children;

        if (snapshot.hasData) {
          return snapshot.data;
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
}
