import 'package:Loginout/providers/ApiConnector.dart';
import 'package:Loginout/screen/wellcomescreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'
    show MultiProvider, ChangeNotifierProvider;
import './screen/splashscreen.dart';
import './screen/login_screen.dart';
import './screen/signin_out_screen.dart';
import './screen/qr_scanner_screen.dart';
import 'providers/AuthProvider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ApiConnector>(
          create: (_) => ApiConnector(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ASL Log In Out',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
        routes: {
          LoginScreen.routeName: (ctx) => LoginScreen(),
          SignInOutScreen.routeName: (ctx) => SignInOutScreen(),
          QRViewScreen.routeName: (ctx) => QRViewScreen(),
          WellcomeScreen.routeName: (ctx) => WellcomeScreen(),
        },
      ),
    );
  }
}
