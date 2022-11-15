import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';
import '../../helpers/Utilities.dart';

class PunchinOut extends StatefulWidget {
  const PunchinOut({Key key}) : super(key: key);

  @override
  _PunchinOutState createState() => _PunchinOutState();
}

class _PunchinOutState extends State<PunchinOut> {
  final body = "";
  String buttonName = "";
  String loginuserid = "";
  var userid = TextEditingController();
  var id = TextEditingController();
  var punchnote = TextEditingController();
  DateTime now = new DateTime.now();
  bool isVisible = false;
  String punchid = "";
  bool isInternetAvailable = true;


  @override
  void initState() {
    super.initState();
    getAttendence();
  }

  void showToast() {
    setState(() {
      isVisible = !isVisible;
    });
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
      body: Center(
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
        appBar: AppBar(
          leading: Container(
            margin: EdgeInsets.all(5),
            child: GestureDetector(
              child: Image.asset(
                "assets/images/back_btn3.png",
                width: 35,
                height: 35,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Text(
            "Punch In",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Myriad',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                      Widget>[
      Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/body_bg.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              Container(
                margin:
                    EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('Date',
                          style: TextStyle(fontFamily: 'Myriad',)),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: 400,
                      decoration: myBoxDecoration(),
                      child: Text('${now.day}/${now.month}/${now.year}',
                          style: TextStyle(fontFamily: 'Myriad',)),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('Time:',
                          style: TextStyle(fontFamily: 'Myriad',)),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: 400,
                      decoration: myBoxDecoration(),
                      child: Text('${now.hour}:${now.minute}',
                          style: TextStyle(fontFamily: 'Myriad',)),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('Note',
                          style: TextStyle(fontFamily: 'Myriad')),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        style: TextStyle(fontFamily: 'Myriad'),
                        controller: punchnote,
                        maxLines: 10,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(15),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            hintText: "Enter your text here",
                            hintStyle: TextStyle(
                              fontFamily: 'Myriad',
                            )),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage("assets/images/apply_btn.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                      child: FlatButton(
                        padding: EdgeInsets.only(bottom: 7),
                        onPressed: () async {
                          final String body = jsonEncode({
                            "user_id": loginuserid,
                            "id": punchid,
                            "punch_note": punchnote.text.toString()
                          });
                          ApiService.post('punchInpunchOut',body).then((success) {
                            final data = json.decode(success.body);
                            getAttendence();
                          });
                        },
                        child: Text(buttonName,
                            style: TextStyle(fontFamily: 'Myriad',)),
                        color: Colors.transparent,
                        textColor: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 90,
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    ])),
        ));
  }

  getAttendence() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final body = jsonEncode({"user_id": prefs.getString('userId')});

    ApiService.post('attendance',body).then((success) {
      final data = json.decode(success.body);
      setState(() {
        loginuserid = prefs.getString('userId');
        punchid = data['attendancedetails']['id'];
        if (data['attendancedetails']['id'] != "") {
          buttonName = "Punch Out";
        } else {
          buttonName = "Punch In";
        }
      });
    });
  }

  myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(),
      borderRadius: BorderRadius.all(
          Radius.circular(5.0) //                 <--- border radius here
          ),
    );
  }
}
