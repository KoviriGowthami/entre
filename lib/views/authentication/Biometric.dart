import 'dart:io';
import 'package:entreplan_flutter/views/home/HomeTabs.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Biometric extends StatefulWidget {
  const Biometric({Key key}) : super(key: key);

  @override
  State<Biometric> createState() => _BiometricState();
}

class _BiometricState extends State<Biometric> {

  final prefs =  SharedPreferences.getInstance();
  DateTime pre_backpress = DateTime.now();
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
   bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;


  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
          ? _SupportState.supported
          : _SupportState.unsupported),
    );
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
      condition();
    });
  }

  void condition() {
    if(_canCheckBiometrics){
      _authenticateWithBiometrics();
    }else{
    _navigateToHome();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason:
        'Scan your fingerprint (or face or whatever) to authenticate',
      );
      setState(() {
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }
    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
      if(message == 'Authorized') {
        BiometricDetail(_authorized);
      }else{
        _authenticateWithBiometrics();
      }
    });
  }

  BiometricDetail(biometric) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('biometric',biometric);
      _navigateToHome();
  }
  void _navigateToHome() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeTabs()));
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
      final timegap = DateTime.now().difference(pre_backpress);
        final cantExit = timegap >= Duration(seconds: 2);
      pre_backpress = DateTime.now();
        if(cantExit){
          final snack = SnackBar(content: Text('Press Back button again to Exit'),duration: Duration(seconds: 2),);
          ScaffoldMessenger.of(context).showSnackBar(snack);
          return false;
        }else{
          return true;
        }
      },
      child: Scaffold(
        body: Center(
          child: Container(
            child:  Image.asset(
              "assets/images/entreplan_logo.png",
              fit: BoxFit.cover,
              height: 40,
            ),
          ),
        ),
      ),
    );
  }
  }


enum _SupportState {
  unknown,
  supported,
  unsupported,
}