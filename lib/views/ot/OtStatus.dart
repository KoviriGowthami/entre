import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:entreplan_flutter/views/ot/OT.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../home/HomeTabs.dart';

class OtStatus extends StatefulWidget {
  final String type;
  final String id;
  final String claimType;

  OtStatus(
      {Key key,
        @required this.type,
        @required this.id,
        @required this.claimType})
      : super(key: key);
  @override
  _OtStatusState createState() => _OtStatusState();
}

class _OtStatusState extends State<OtStatus> {
  List<String> dataList = [];
  List<String> claimDataList = [];
  bool visibility = false;
  String selectedType = "";
  String selectedTypeid = "";
  int selectedIndex = -1;
  String roleName = "";
  var navigate;
  bool isInternetAvailable = true;

  void initState() {
    super.initState();
    setData();
  }

  var discription = TextEditingController();

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
            "OverTime",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Myriad',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
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
                  margin: EdgeInsets.fromLTRB(30, 20, 30, 10),
                  child: TextFormField(
                    minLines: 2,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    controller: discription,
                    onChanged: ((String comment) {
                      setState(() {
                        comment = comment;
                      });
                    }),
                    decoration: InputDecoration(
                      hintText: 'Reason ...',
                      hintStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Column(children: [
                  Visibility(
                      visible: visibility,
                      child: Container(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          child: ToggleSwitch(
                            initialLabelIndex: -1,
                            totalSwitches: 2,
                            labels: claimDataList,
                            onToggle: (index) {
                              if (index == 0) {
                                selectedType = "Cash";
                                selectedTypeid = "2";
                              } else if (index == 1) {
                                selectedType = "Leave";
                                selectedTypeid = "1";
                              }
                            },
                          ),
                        ),
                      )),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    child: ToggleSwitch(
                      initialLabelIndex: selectedIndex,
                      totalSwitches: 3,
                      labels: dataList,
                      onToggle: (index) {
                        if (index == 0) {
                          if (roleName == "HiringManager" ||
                              roleName == "Department Manager") {
                            makeApiCall("0", widget.id, widget.claimType);
                          } else {
                            if (selectedTypeid == "") {
                              setState(() {
                                selectedIndex = -1;
                              });
                              Utilities.showAlert(
                                  context, "Please Select Claim Type");
                            } else {
                              makeApiCall("0", widget.id, widget.claimType);
                            }
                          }
                        } else if (index == 1) {
                          makeApiCall("1", widget.id, widget.claimType);
                        } else {
                          navigate = Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OT(),
                            ),
                                (route) => false,
                          );
                          return navigate;
                        }
                      },
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ));
  }

  makeApiCall(String selectedId, otId, claimType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String convertedId;
    String statusId;
    if (prefs.getString("role") == "Technician") {
      if (selectedId == "0") {
        convertedId = "2";
        statusId = "2";
      } else if (selectedId == "1") {
        convertedId = "1";
        statusId = "2";
      } else {
        convertedId = "0";
        statusId = "2";
      }
      final body = jsonEncode({
        "user_id": prefs.getString('userId'),
        "status_id": statusId,
        "ot_id": otId.toString(),
        "claim_type": convertedId.toString(),
        "notes": discription.text
      });

      ApiService.post('claimOT',body).then((success) async {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeTabs()));
      });
    } else if (prefs.getString("role") == "HiringManager") {
      if (selectedId == "0") {
        statusId = "6";
      } else if (selectedId == "1") {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeTabs()));
        return;
      }
      final body = jsonEncode({
        "user_id": prefs.getString('userId'),
        "status_id": statusId,
        "ot_id": otId.toString(),
        "claim_type": claimType.toString(),
        "notes": discription.text
      });

      ApiService.post('claimOT',body).then((success) async {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeTabs()));
      });
    } else {
      if (selectedId == "0") {
        if (prefs.getString('role') == "Supervisor") {
          convertedId = "3";
          claimType = selectedTypeid;
        } else {
          convertedId = "4";
        }
      } else if (selectedId == "1") {
        convertedId = "5";
      } else {
        convertedId = "";
      }
      final body = jsonEncode({
        "user_id": prefs.getString('userId'),
        "status_id": convertedId.toString(),
        "ot_id": otId.toString(),
        "claim_type": claimType.toString(),
        "notes": discription.text
      });
      ApiService.post('claimOT',body).then((success) async {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeTabs()));
      });
    }
  }

  setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('role') == "Supervisor") {
      setState(() {
        roleName = prefs.getString('role');
        claimDataList = ['Cash', 'Leave'];
        dataList = ['Verify', 'Reject', 'Cancel'];
        visibility = true;
      });
    } else if (prefs.getString('role') == "HiringManager") {
      setState(() {
        roleName = prefs.getString('role');
        dataList = ['Accept', '', 'Cancel'];
      });
    } else if (prefs.getString('role') == "Department Manager" ||
        prefs.getString('role') == "HOD") {
      setState(() {
        roleName = prefs.getString('role');
        dataList = ['Approve', 'Reject', 'Cancel'];
      });
    } else {
      setState(() {
        roleName = prefs.getString('role');
        dataList = ['Cash', 'Leave', 'Cancel'];
      });
    }
  }
}
