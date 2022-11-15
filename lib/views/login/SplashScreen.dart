import 'dart:async';

import 'package:entreplan_flutter/views/home/HomeTabs.dart';
import 'package:entreplan_flutter/views/home/ListViewHome.dart';
import 'package:entreplan_flutter/views/login/LogInScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/Biometric.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  double opacityLevel = 1.0;

  void _changeOpacity() {
    setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      _changeOpacity();
    });

    getLoginstatus().then((status) {
      if (status) {
        _navigateToHome();
      } else {
        _navigateToLogin();
      }
    });
  }

  getLoginstatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration(milliseconds: 1500));
    if (prefs.getBool('islogin') == null) {
      return false;
    }
    else{
      return true;
    }
  }

  void _navigateToHome() {
    Timer(Duration(seconds: 3), () => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Biometric(),
      ),
          (route) => false,
    )
    );

  }
  void _navigateToLogin() {
    Timer(Duration(seconds: 3), () => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => LogInScreen(),
      ),
          (route) => false,
    ));
  }

  @override


  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Container(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                      opacity: opacityLevel,
                      duration: const Duration(seconds: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Image.asset(
                            "assets/images/entreplan_logo.png",
                            fit: BoxFit.cover,
                            height: 40,
                          ),
                        ],
                      )),
                )
              ],
            ),
          ),
        ));
  }
}
