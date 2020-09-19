import 'dart:async';

import 'package:Loginout/model/auth.dart';
import 'package:Loginout/model/logginSession.dart';
import 'package:Loginout/providers/ApiConnector.dart';
import 'package:Loginout/providers/db_provider.dart';
import 'package:Loginout/screen/login_screen.dart';
import 'package:Loginout/screen/qr_scanner_screen.dart';
import 'package:Loginout/screen/timer_scree.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:geocoder/geocoder.dart' show Coordinates, Geocoder;
import 'package:geolocation/geolocation.dart'
    show Geolocation, Location, LocationAccuracy, LocationResult;
import 'package:get_mac/get_mac.dart' show GetMac;
import 'package:provider/provider.dart' show Provider;

class SignInOutScreen extends StatefulWidget {
  static const routeName = "/SignInOutScreen";

  const SignInOutScreen({Key key}) : super(key: key);

  @override
  _SignInOutScreenState createState() => _SignInOutScreenState();
}

class _SignInOutScreenState extends State<SignInOutScreen> {
  Location loc;
  String first;
  Auth auth;
  String postCode;
  String mac = 'Unknown';
  Timer timer;
  int time;
  DateTime timeOpenSession;
  LoginSession loginSession;
  TextEditingController _c;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _c = new TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    enableLServices();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var qrText;
    if (loginSession == null) {
      qrText = ModalRoute.of(context).settings.arguments as Map<String, String>;
    } else {
      qrText = {
        'qr': loginSession.org,
        'dateTime': loginSession.time.toString()
      };
      timeOpenSession = DateTime.parse(loginSession.time);
      time = DateTime.now().difference(timeOpenSession).inSeconds;
      if (timer == null && loginSession != null) {
        timer = Timer.periodic(Duration(minutes: 1), (timer) {
          Provider.of<ApiConnector>(context, listen: false).ping();
          print(DateTime.now());
        });
      }
    }

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Service Tracker'),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height -
                kToolbarHeight -
                kBottomNavigationBarHeight,
            width: MediaQuery.of(context).size.width,
            child: first == null
                ? Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 10,
                        shadowColor: Theme.of(context).primaryColorDark,
                        margin: EdgeInsets.only(
                            left: 15, right: 15, top: 15, bottom: 5),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'ID : ',
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                auth.user,
                                style: TextStyle(fontSize: 15),
                              ),
                              Spacer(),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        elevation: 10,
                        shadowColor: Theme.of(context).primaryColorDark,
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: <Widget>[
                              Text(
                                'Location : ',
                                style: TextStyle(fontSize: 15),
                              ),
                              Expanded(
                                child: Text(
                                  first,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      qrText == null
                          ? qrScanButton()
                          : Card(
                              elevation: 10,
                              shadowColor: Theme.of(context).primaryColorDark,
                              margin:
                                  EdgeInsets.only(left: 15, right: 15, top: 5),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  qrText['qr']
                                      .replaceAll(new RegExp('%'), '')
                                      .replaceAll('Code', 'Code : ')
                                      .replaceAll('Address', 'Address : ')
                                      .replaceAll('Mobile', 'Mobile : '),
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                      qrText == null
                          ? Text('')
                          : Card(
                              elevation: 10,
                              shadowColor: Theme.of(context).primaryColorDark,
                              margin: EdgeInsets.all(15),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'Start Time : ',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Expanded(
                                      child: Text(
                                        qrText['dateTime'],
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      qrText == null
                          ? Text(
                              'Scan your QR code to active session',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 15),
                            )
                          : TimerApp(true, time),
                      Spacer(),
                      qrText == null ? Text('') : logOutButton(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget qrScanButton() {
    return Container(
      margin: EdgeInsets.all(15),
      height: MediaQuery.of(context).size.height * .07,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(20.0),
        ),
        color: Colors.blueAccent,
        child: Text("Scan Qr Code", style: TextStyle(fontSize: 20)),
        textColor: Colors.white,
        splashColor: Colors.grey,
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(QRViewScreen.routeName);
        },
      ),
    );
  }

  Widget logOutButton() {
    return Container(
      height: MediaQuery.of(context).size.height * .07,
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(20.0),
        ),
        color: Colors.blueAccent,
        child: Text("Logout", style: TextStyle(fontSize: 20)),
        textColor: Colors.white,
        splashColor: Colors.grey,
        onPressed: _showDialog,
      ),
    );
  }

  enableLServices() async {
    DatabaseHelper _databaseHelper = DatabaseHelper();
    auth = await _databaseHelper.fetchAuthUser();
    loginSession = await _databaseHelper.fetchLoginSession();
    mac = await initPlatformState();
    Geolocation.enableLocationServices().then((val) async {
      LocationResult result;
      Geolocation.currentLocation(accuracy: LocationAccuracy.best)
          .listen((location) async {
        if (location.isSuccessful) {
          print('location found');
          result = location;
          loc = result.location;
          final coordinates = new Coordinates(loc.latitude, loc.longitude);
          await Geocoder.local
              .findAddressesFromCoordinates(coordinates)
              .then((value) {
            setState(() {
              postCode = value.first.postalCode;
              print(postCode);
              print(mac);
              first = value.first.addressLine;
            });
          });
        }
      });
      print(first);
    }).catchError((e) {
      print(e);
    });
  }

  Future<String> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await GetMac.macAddress;
      return platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get Device MAC Address.';
      return platformVersion;
    }
  }

  void _showDialog() async {
    String comment;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "Add Your Comment",
            style: TextStyle(color: Colors.blue),
          ),
          content: TextField(
            decoration: new InputDecoration(hintText: "Should Not Be Empty"),
            controller: _c,
          ),
          actions: <Widget>[
            new RaisedButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new RaisedButton(
              child: new Text("Submit"),
              onPressed: () {
                comment = _c.text.trim();
                print(comment.length);
                _c.clear();
                if (comment.length == 0) {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: new Text(
                          "Comment Can't be Empty",
                          style: TextStyle(color: Colors.blue),
                        ),
                        actions: [
                          RaisedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showDialog();
                              },
                              child: Text('Try Again'))
                        ],
                      );
                    },
                  );
                } else {
                  print("Else Working");
                  _c.clear();
                  Navigator.of(context).pop();
                  Provider.of<ApiConnector>(context, listen: false)
                      .closeSession(comment)
                      .then((value) {
                    print(value.toString() + ' from log out');
                    timer.cancel();
                    Navigator.of(context)
                        .pushReplacementNamed(LoginScreen.routeName);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}
