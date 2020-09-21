import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;

import './wellcomescreen.dart';
import '../providers/AuthProvider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/LoginScreen";
  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String userid;
  String password;
  bool loginSuccess;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          height: deviceHeight,
          width: deviceWidth,
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(top: 30),
                  height: deviceHeight * .3,
                  width: deviceWidth * .5,
                  child: Image.asset(
                    'assets/images/cloudlogin.png',
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                Text(
                  "Welcome",
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 80.0),
                pnoneNumberField(),
                passwordField(),
                const SizedBox(height: 80.0),
                logInButton(),
                Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget pnoneNumberField() {
    return Container(
      height: MediaQuery.of(context).size.height * .04,
      width: MediaQuery.of(context).size.width * .9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black, fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle),
                contentPadding: EdgeInsets.only(bottom: 10),
                // labelText: " Your Mobile No. ",
                hintText: " Enter Your login ID",
                hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    textBaseline: TextBaseline.alphabetic),
              ),
              // validator: (String value){
              //   if(value.length == 11){
              //     return null;
              //   }
              //   return 'Please insert a valid mobile no';
              // },
              onSaved: (newValue) => userid = newValue,
            ),
          ),
        ],
      ),
    );
  }

  Widget passwordField() {
    return Container(
      height: MediaQuery.of(context).size.height * .04,
      width: MediaQuery.of(context).size.width * .9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: TextFormField(
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.lock_outline,
                  size: 25,
                ),
                suffixIcon: Icon(Icons.visibility_off),
                contentPadding: EdgeInsets.only(bottom: 10),
                hintText: " Enter Your Passward",
                hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    textBaseline: TextBaseline.alphabetic),
              ),
              onSaved: (newValue) => password = newValue,
            ),
          ),
        ],
      ),
    );
  }

  Widget logInButton() {
    return Container(
      height: MediaQuery.of(context).size.height * .05,
      width: MediaQuery.of(context).size.width * .7,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0),
        ),
        color: Colors.blueAccent,
        child: Text("LOGIN", style: TextStyle(fontSize: 14)),
        textColor: Colors.white,
        splashColor: Colors.grey,
        onPressed: () {
          _formKey.currentState.validate();
          _formKey.currentState.save();
          Provider.of<AuthProvider>(context, listen: false)
              .login(userid, password)
              .then((value) {
            loginSuccess = value;
            loginSuccess
                ? Navigator.of(context)
                    .pushReplacementNamed(WellcomeScreen.routeName)
                : _showDialog("Someting went wrong");
          });
          //  .then((val) => Navigator.of(context)
          //    .pushReplacementNamed(WellcomeScreen.routeName));
        },
      ),
    );
  }

  void _showDialog(String msg) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Login Failed",
            style: TextStyle(color: Colors.red, fontSize: 24),
          ),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
