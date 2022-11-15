import 'dart:convert';

import 'package:entreplan_flutter/views/leave/UpdateLeaveStatus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';
import '../../helpers/Utilities.dart';

class ApproveLeave extends StatefulWidget {
  const ApproveLeave({Key key}) : super(key: key);

  @override
  _ApproveLeaveState createState() => _ApproveLeaveState();
}

class _ApproveLeaveState extends State<ApproveLeave> {
  String status;
  String status1;
  bool listVisible = false;
  bool isVisible = false;
  void initState() {
    super.initState();
    getLeaveList();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.green, // navigation bar color
      statusBarColor: Colors.green, // status bar color
    ));
  }

  onGoBack(dynamic value) {
    setState(() {});
    getLeaveList();
  }

  List leaveList;
  bool isInternetAvailable = true;

  @override
  Widget build(BuildContext context) {
    if (Utilities.dataState == "Connection lost") {
      setState(() {
        isInternetAvailable = true;
      });
    } else {
      setState(() {
        isInternetAvailable = false;
      });
    }
    return isInternetAvailable
        ? Scaffold(
            body: Center(
                heightFactor: 1,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                  child: // Load a Lottie file from your assets
                      Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          child: Lottie.asset('assets/json/nointernet.json',
                              fit: BoxFit.contain, height: 200, width: 200)),
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
                )),
          )
        : Scaffold(
            appBar: AppBar(
              leading: Container(
                margin: EdgeInsets.all(5),
                child: GestureDetector(
                  child: Image.asset(
                    "assets/images/back_btn3.png",
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              title: Text(
                "Approve Leave List",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: 'Myriad',
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: Center(
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/body_bg.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: SingleChildScrollView(
                      child: Column(children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
                      child: ListTile(
                          onTap: () {},
                          title: Text("Status",
                              textAlign: TextAlign.start,
                              style: TextStyle(color: Color(0xFF000000))),
                          trailing: DropdownButton(
                            hint: Text('Pending'),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                            iconSize: 42,
                            items: <String>[
                              'Pending',
                              'Scheduled',
                              'Rejected',
                              'Cancelled',
                              'Taken'
                            ].map((item) {
                              return new DropdownMenuItem(
                                  child: new Text(
                                    item,
                                  ),
                                  value: item
                                      .toString() //Id that has to be passed that the dropdown has.....
                                  );
                            }).toList(),
                            onChanged: (String newVal) {
                              setState(() {
                                status = newVal;
                                getLeaveList();
                              });
                            },
                            value: status,
                          )),
                    ),
                    Visibility(
                        visible: listVisible,
                        child: Column(children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.75,
                            child: SafeArea(
                              bottom: true,
                              child: ListView.builder(
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    leaveList == null ? 0 : leaveList.length,
                                itemBuilder: (context, index) {
                                  return StoreListTile(
                                    leaveList[index]['emp_name'] == null
                                        ? ""
                                        : leaveList[index]['emp_name'],
                                    leaveList[index]['date_applied'] == null
                                        ? ""
                                        : leaveList[index]['date_applied'],
                                    leaveList[index]['date'] == null
                                        ? ""
                                        : leaveList[index]['date'],
                                    leaveList[index]['no_of_days'] == null
                                        ? ""
                                        : leaveList[index]['no_of_days'],
                                    leaveList[index]['status'] == null
                                        ? ""
                                        : leaveList[index]['status'],
                                    leaveList[index]['leave_request_id'] == null
                                        ? ""
                                        : leaveList[index]['leave_request_id'],
                                  );
                                },
                              ),
                            ),
                          )
                        ])),
                    Visibility(
                      visible: isVisible,
                      child: Center(
                        heightFactor: 1.5,
                        child: Container(
                          child: Lottie.network(
                            'https://assets10.lottiefiles.com/private_files/lf30_lkquf6qz.json',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ]))),
            ));
  }

  getLeaveList() async {
    String SId;
    if (status == 'Taken') {
      SId = '3';
    } else if (status == 'Scheduled') {
      SId = '2';
    } else if (status == 'Rejected') {
      SId = '-1';
    } else if (status == 'Cancelled') {
      SId = '0';
    } else {
      SId = '1';
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body =
        jsonEncode({"user_id": prefs.getString('userId'), "status": SId});
    ApiService.post("approvedLeavelist", body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        leaveList = jsonDecode(data)['subOrdinateleaves'];
        print(leaveList);
        if (leaveList.length == 0) {
          isVisible = true;
          listVisible = false;
        } else {
          listVisible = true;
          isVisible = false;
        }
      }); // just printed length of data
    });
  }

  String statusName = '';
  @override
  Widget StoreListTile(
      empName, dateApplied, date, noofDays, status1, leaveRequestId) {
    this.status1 = status1;
    _setImage();
    return GestureDetector(
        child: Container(
      margin: EdgeInsets.only(right: 16, left: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      padding: EdgeInsets.only(top: 16, right: 16, left: 16),
      child: Card(
        color: Color(0xfff1f3f6),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        child: Column(
          children: <Widget>[
            ListTile(
              onTap: () {
                if (statusName == "PENDING APPROVAL") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdateLeaveStatus(
                                id: leaveRequestId,
                                type: "leave",
                                leaveType: "",
                                leaveEmpName: empName,
                                leaveEmpDate: date,
                                leaveEmpDateApplied: dateApplied,
                                noofDays: noofDays,
                              ))).then(onGoBack);
                } else if (statusName == 'SCHEDULED') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdateLeaveStatus(
                                id: leaveRequestId,
                                type: "leave",
                                leaveType: "SCHEDULED",
                                leaveEmpName: empName,
                                leaveEmpDate: date,
                                leaveEmpDateApplied: dateApplied,
                                noofDays: noofDays,
                              ))).then(onGoBack);
                }
              },
              title: Table(
                children: [
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Employee",
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        empName,
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                      ),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Date Applied",
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        dateApplied,
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                      ),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Date",
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        date,
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                      ),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "No. of Days",
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        noofDays,
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                      ),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Status",
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        statusName,
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                      ),
                    )
                  ]),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

  String _setImage() {
    String statusState = status1;

    if (statusState == "3") {
      statusName = "TAKEN";
      return "assets/images/approved.png";
    } else if (statusState == "-1") {
      statusName = "REJECTED";
      return "assets/images/reject.png";
    } else if (statusState == "0") {
      statusName = "CANCELLED";
      return "assets/images/cancelled.png";
    } else if (statusState == "1") {
      statusName = "PENDING APPROVAL";
      return "assets/images/pending.png";
    } else if (statusState == "2") {
      statusName = "SCHEDULED";
      return "assets/images/approved.png";
    } else if (statusState == "1") {
      statusName = "PENDING APPROVAL";
      return "assets/images/pending.png";
    } else {
      statusName = "Pending For Approval";
      return "assets/images/pending.png";
    }
  }
}
