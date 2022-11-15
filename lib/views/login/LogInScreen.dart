import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:entreplan_flutter/views/home/HomeTabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';
import '../home/ListViewHome.dart';

class LogInScreen extends StatefulWidget {
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String _userName;
  String _password;
  String userDetails;
  var password = TextEditingController();
  var userName = TextEditingController();
  bool _showPassword = false;
  bool isInternetAvailable = true;

  void startTimer() {
    try{
      Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          loading = false; //set loading to false
        });
        t.cancel(); //stops the timer
      });
    }catch(e){
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if(Utilities.dataState=="Connection lost"){
      setState(() {
        isInternetAvailable = true;
      });
    }else{
      setState(() {
        isInternetAvailable = false;
      });
    }
    return isInternetAvailable?Scaffold(
      body:
      Center(
          heightFactor: 1,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
            child:  // Load a Lottie file from your assets
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(child: Lottie.asset('assets/json/nointernet.json',fit: BoxFit.contain,height: 200,width: 200)),
                Container(
                  child: Text(
                    "No internet connection",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontFamily: 'Myriad',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(30),
                  child: Text(
                    "You are not connected to the internet. Make sure Wi-Fi or Mobile data is on, Airplane Mode is Off and try again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontFamily: 'Myriad',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
      ),
    ): Scaffold(
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg_screen.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: new Image.asset(
                  "assets/images/entreplan_logo.png",
                  width: 280,
                  height: 250,
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: AssetImage("assets/images/input_field.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: TextFormField(
                          controller: userName,
                          onChanged: ((String userName) {
                            setState(() {
                              _userName = userName;
                            });
                          }),
                          style: TextStyle(
                              color: Color(0xFF006837),
                            fontFamily: 'Myriad',
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Image.asset(
                              "assets/images/user_icon.png",
                              width: 20,
                              height: 20,
                            ),
                            hintText: "Username",
                            hintStyle: TextStyle(
                                color: Color(0xFF006837),
                                fontWeight: FontWeight.bold),
                          ),
                          textAlign: TextAlign.start,
                          validator: (value) {
                            startTimer();
                            if (value.isEmpty) {
                              return '  Please enter UserName';
                            }
                            if (value.length < 3) {
                              return '  Name must be more than 2 charater';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: AssetImage("assets/images/input_field.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: TextFormField(
                          controller: password,
                          onChanged: ((String password) {
                            setState(() {
                              _password = password;
                            });
                          }),
                          style: TextStyle(
                              color: Color(0xFF006837),
                            fontFamily: 'Myriad',),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Image.asset(
                              "assets/images/pwd_icon.png",
                              width: 20,
                              height: 20,
                            ),
                            hintText: "Password",
                            hintStyle: TextStyle(
                                color: Color(0xFF006837),
                                fontWeight: FontWeight.bold),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                              child: Icon(
                                _showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          obscureText: !_showPassword,
                          textAlign: TextAlign.start,
                          validator: (value) {
                            startTimer();
                            Pattern pattern =
                                ("^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])(?=.{8,})");
                            RegExp regex = new RegExp(pattern);
                            if (value.length == 0) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          child: Row(
                        children: <Widget>[
                          loading
                              ? Center(child: CircularProgressIndicator())
                              :
                              Container(
                                  color: Colors.transparent,
                                  child: GestureDetector(
                                    child: Image.asset(
                                      "assets/images/log btn.png",
                                      width: 200,
                                    ),
                                    onTap: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      if (_formKey.currentState.validate()) {
                                        final body = jsonEncode({
                                          "mobnumber": "",
                                          "username": userName.text.toString(),
                                          "password": password.text.toString(),
                                        });
                                        ApiService.post('loginWithMobNumOrUsrname',body)
                                            .then((success) async {
                                          final body =
                                              json.decode(success.body);
                                          if (body['status'] == 1) {
                                            userDetail(body);
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomeTabs()),
                                                ModalRoute.withName('/'));
                                          } else {
                                            setState(() {
                                              loading = true;
                                              startTimer();
                                            });
                                            Utilities.showAlert(context,
                                                "credentials mismatch");
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      )),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          child: Row(
                        children: <Widget>[
                          // ignore: deprecated_member_use
                          FlatButton(
                            textColor: Colors.green,
                            child: Text(
                              'Forgot Password',
                              style: TextStyle( color: Color(0xffB22222)),
                            ),
                            onPressed: () {},
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      )),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: new Image.asset(
                  "assets/images/prospecta_logo.png",
                  width: 280,
                  height: 200,
                ),
              ),
            ])));
  }

  userDetail(response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', response['userDetails']['user_id']);
    prefs.setString('empName', response['userDetails']['emp_name']);
    prefs.setString('empNumber', response['userDetails']['emp_number']);
    prefs.setString("role", response['userDetails']['role']);
    prefs.setString("roleName", response['userDetails']['role_name']);
    prefs.setString("Proimage", response['userDetails']['image']);
    prefs.setString("Plantname", response['userDetails']['plant_name']);
    prefs.setString("PlantId", response['userDetails']['plant_id']);
    prefs.setString("deptId", response['userDetails']['department_id']);
    prefs.setBool('islogin', true);
    print( response['userDetails']['user_id']);
    print(" response['userDetails']['user_id']");
  }
}
