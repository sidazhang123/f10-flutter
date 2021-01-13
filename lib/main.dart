import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterf10/helper/dto/global.dart';
import 'package:flutterf10/simpleAccountMenu.dart';
import 'package:flutterf10/view/chanODay.dart';
import 'package:flutterf10/view/homeView.dart';
import 'package:flutterf10/view/recovery.dart';
import 'package:flutterf10/view/ruleSettings/FARules.dart';
import 'package:flutterf10/view/ruleSettings/LTNewsRules.dart';
import 'package:flutterf10/view/ruleSettings/LTRules.dart';
import 'package:flutterf10/view/ruleSettings/SARules.dart';
import 'package:flutterf10/view/tabbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ota_update/ota_update.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

import 'helper/init/checkUpdate.dart';
import 'notification/doRequest.dart';
import 'notification/registerJPush.dart';

void main() => runApp(initApp());

class initApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: AnimatedSplashScreen.withScreenFunction(
            splash: "assets/f10_launcher.png",
            screenFunction: DuringSplash,
            duration: 0,
            splashTransition: SplashTransition.rotationTransition,
            pageTransitionType: PageTransitionType.bottomToTop,
            backgroundColor: Colors.white)
    );
  }

  Future<Widget> DuringSplash() async {
    [
      Permission.ignoreBatteryOptimizations,
      Permission.storage,
      Permission.notification,
      Permission.unknown
    ]
        .forEach((perm) async {
      if (!await perm.isGranted) {
        perm.request();
      }
    });

    await GetFocus();

    return Future.value(MyApp());
  }

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: HomeScreen(),
    );
  }
}

ThemeData _buildTheme() {
  final ThemeData base = ThemeData.dark();
  return base.copyWith(
      primaryIconTheme: base.iconTheme.copyWith(color: Colors.blueAccent));
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showRaisedButtonBadge = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  OtaEvent currentEvent;

  @override
  void initState() {
    super.initState();
    tryUpdate();
    startService();
    RegisterJPush().initPlatformState(context);
  }

  void tryUpdate() {
    Connectivity().checkConnectivity().then((connectivityResult) {
      if (connectivityResult == ConnectivityResult.wifi) {
        getUpdateInfo().then((sha) {
          if (sha.length > 0) {
            //ota_update
            try {
              Fluttertoast.showToast(
                toastLength: Toast.LENGTH_LONG,
                backgroundColor: Colors.grey[400],
                msg: "app更新中，进度见通知栏",
              );
              OtaUpdate()
                  .execute("https://",
                      destinationFilename: "f10_ota_update.apk")
                  .listen(
                    (OtaEvent event) {
                  setState(() => currentEvent = event);
                },
              );
            } catch (e) {
              print('Failed to make OTA update. Details: $e');
            }
          } else {
            Fluttertoast.showToast(
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.grey[400],
              msg: "已经是最新版",
            );
          }
        }).catchError((e) {
          print('Check Connectivity Err. Details: $e');
        });
      }
    });
  }

  void startService() async {
    var methodChannel = MethodChannel("sidazhang123.flutterf10.fgservice");
    String data = await methodChannel.invokeMethod("startService");
    print("f10: $data");
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: Tabbar(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: <Widget>[
              SimpleAccountMenu(
                icons: [
                  Icon(Icons.fiber_new),
                  Icon(Icons.person),
                  Icon(Icons.monetization_on),
                  Icon(Icons.settings),
                  Icon(Icons.track_changes),
                ],
                iconColor: Colors.blueGrey,
                onChange: (index) {
                  switch (index) {
                    case 0:
                      {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => LTRules()),
                        );
                      }
                      break;
                    case 1:
                      {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => SARules()),
                        );
                      }
                      break;
                    case 2:
                      {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => FARules()),
                        );
                      }
                      break;
                    case 3:
                      {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => ChanODay()),
                        );
                      }
                      break;
                    case 4:
                      {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => LTNewsRules()),
                        );
                      }
                      break;
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.restore_from_trash),
                onPressed: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(builder: (context) => Recovery()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.bookmark),
                onPressed: () {
                  header2panelStream.add(true);
                },
              ),
            ],
          ),
          backgroundColor: Colors.white,
        ),
        body: SwipingSlidableList(_scaffoldKey),
      ),
    );
  }
}
