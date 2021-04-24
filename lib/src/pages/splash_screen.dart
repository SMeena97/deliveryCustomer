import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../controllers/splash_screen_controller.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  SplashScreenController _con;

  SplashScreenState() : super(SplashScreenController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    // loadData();
    navigateService();
  }

  navigateService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("language_selected")) {
      Timer(Duration(seconds: 5),
          () => Navigator.pushReplacementNamed(context, '/Courier'));
    } else {
      Timer(Duration(seconds: 5),
          () => Navigator.pushReplacementNamed(context, '/languageSettings'));
    }
  }

  void loadData() {
    _con.progress.addListener(() {
      double progress = 0;
      _con.progress.value.values.forEach((_progress) {
        progress += _progress;
      });
      if (progress == 100) {
        navigateService();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: ExactAssetImage('assets/img/logo.png'),
                      fit: BoxFit.fill),
                ),
              ),
              SizedBox(height: 50),
              // CircularProgressIndicator()
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
