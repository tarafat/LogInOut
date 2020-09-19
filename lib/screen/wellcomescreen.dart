import 'package:Loginout/providers/ApiConnector.dart';
import 'package:Loginout/screen/signin_out_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;

import '../providers/db_provider.dart';

class WellcomeScreen extends StatefulWidget {
  static const routeName = '/WellcomeScreen';

  @override
  State<StatefulWidget> createState() => new WellcomeState();
}

class WellcomeState extends State<WellcomeScreen> {
  var _isInit = true;
  var _isLoading = false;
  bool internet;
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      await Provider.of<ApiConnector>(context, listen: false)
          .enableLServices()
          .then((value) {
        setState(() {
          _isLoading = false;
        });
      });
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Container(
              //   child: Image.asset('assets/images/zab.png'),
              // ),
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Welcome To",
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "ASL Log in out app",
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * .05,
                width: MediaQuery.of(context).size.width * .7,
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        color: Colors.blueAccent,
                        child: Text("CONTINUE", style: TextStyle(fontSize: 14)),
                        textColor: Colors.white,
                        splashColor: Colors.grey,
                        onPressed: () {
                          // _formKey.currentState.validate();
                          Navigator.of(context)
                              .pushReplacementNamed(SignInOutScreen.routeName);
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
