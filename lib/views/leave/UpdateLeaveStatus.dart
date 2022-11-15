import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/views/home/ListViewHome.dart';
import 'package:entreplan_flutter/views/leave/ApproveLeave.dart';
import 'package:entreplan_flutter/views/permission/ApprovePermissionList.dart';
import 'package:entreplan_flutter/views/permission/MyPermissionList.dart';
import 'package:entreplan_flutter/views/permission/Permission.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/Utilities.dart';
import '../home/HomeTabs.dart';

class UpdateLeaveStatus extends StatefulWidget {
  final String id;
  final String type;
  final String leaveType;
  final String leaveEmpName;
  final String leaveEmpDate;
  final String leaveEmpDateApplied;
  final String noofDays;
  UpdateLeaveStatus({
    Key key,
    @required this.id,
    @required this.type, this.leaveType, this.leaveEmpName, this.leaveEmpDate, this.leaveEmpDateApplied, this.noofDays,
  }) : super(key: key);
  _UpdateLeaveStatusState createState() => _UpdateLeaveStatusState();
}

class _UpdateLeaveStatusState extends State<UpdateLeaveStatus> {
  var discription = TextEditingController();
  String empName = '';
  String appTitle = "";
  bool isCancel = true;
  bool isApproveReject = true;
  bool  isInternetAvailable = true;
  @override
  void initState() {
    super.initState();
    setName();
    if(widget.leaveType == 'Self'){
      isCancel = true;
      isApproveReject = false;
    }else if(widget.leaveType == 'SCHEDULED'){
      isCancel = true;
      isApproveReject = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == "permission") {
      appTitle = "Approve Permission";
    } else {
      appTitle = "Approve Leave";
    }
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
    ):Scaffold(
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
            "$appTitle",
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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/body_bg.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: ListView(children: <Widget>[
              SizedBox(height: 60),
              Card(
                margin: EdgeInsets.all(20),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Table(children: [
                    TableRow(children: [
                      TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Employee',
                              style: TextStyle(
                                fontFamily: 'Myriad',
                                color: Colors.black,
                              ),
                            ),
                          )),
                      TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(widget.leaveEmpName == '' ? empName : widget.leaveEmpName,
                              style: TextStyle(
                                fontFamily: 'Myriad',
                                color: Colors.black,
                              ),
                            ),
                          )),
                    ]),
                    TableRow(children: [
                      TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Date Applied',
                              style: TextStyle(
                                fontFamily: 'Myriad',
                                color: Colors.black,
                              ),
                            ),
                          )),
                      TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(widget.leaveEmpDateApplied,
                              style: TextStyle(
                                fontFamily: 'Myriad',
                                color: Colors.black,
                              ),
                            ),
                          )),
                    ]),
                    TableRow(children: [
                      TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Date',
                              style: TextStyle(
                                fontFamily: 'Myriad',
                                color: Colors.black,
                              ),
                            ),
                          )),
                      TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(widget.leaveEmpDate,
                              style: TextStyle(
                                fontFamily: 'Myriad',
                                color: Colors.black,
                              ),
                            ),
                          )),
                    ]),
                    TableRow(children: [
                      TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'No. of Days',
                              style: TextStyle(
                                fontFamily: 'Myriad',
                                color: Colors.black,
                              ),
                            ),
                          )),
                      TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(widget.noofDays,
                              style: TextStyle(
                                fontFamily: 'Myriad',
                                color: Colors.black,
                              ),
                            ),
                          )),
                    ]),
                  ]),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/approveleave_card.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: TextFormField(
                  scrollPhysics: ScrollPhysics(),
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  controller: discription,
                  onChanged: ((String comment) {
                    setState(() {
                      comment = comment;
                    });
                  }),
                  decoration: InputDecoration(
                    hintText: 'Comment ...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                  child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible : isApproveReject,
                      child: Row(
                        children: [
                          Container(child: GestureDetector(
                                  child:Image.asset('assets/images/approvenew_btn.png',height: 30,),
                                  onTap: () async {
                                    setData(widget.id, 2, widget.type);
                                    approve(context);
                                    Navigator.pop(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ApproveLeave()));
                                  })),
                          SizedBox(width: 10),
                          Container(
                            child:
                          GestureDetector(
                              child:Image.asset('assets/images/reject_btnnew.png',height: 30,),
                              onTap:  () async {
                                reject(context);
                                setData(widget.id, 1, widget.type);
                                Navigator.pop(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ApproveLeave()));
                              })),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Visibility(
                      visible: isCancel,
                      child: Container(child:
                      GestureDetector(
                        child: Image.asset('assets/images/cancelnew_btn.png',height: 30),
                          onTap: () async {
                            cancel(context);
                            setData(widget.id, 0, widget.type);
                            Navigator.pop(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ApproveLeave()));
                          })),
                    ),
                  ],
                ),
              )),
            ])));
  }

  setName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empName = prefs.getString("empName");
      print(empName);
      print("empName");
    });
  }

  setData(widget, id, type) async {
    String staId;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (type == "permission") {
      if ((id == 2) && (prefs.getString('role') == "Supervisor")) {
        staId = "8";
      } else if ((id == 2) && (prefs.getString('role') == "HOD")) {
        staId = "9";
      } else if ((id == 2) && (prefs.getString('role') == "HiringManager")) {
        staId = "10";
      } else if (id == 1) {
        staId = "7";
      } else {
        staId = "3";
      }
      final body = jsonEncode({
        "user_id": prefs.getString("userId"),
        "statusId": staId,
        "permissionId": widget.toString(),
        "comment": discription.text
      });
      ApiService.post("permsnUpdate",body).then((success) {
        String data = success.body; //store response as string
        data = jsonDecode(data)['message'];
        if (data == "Successfully Approved") {
          Navigator.pop(
              context,
              MaterialPageRoute(
                  builder: (context) => ApprovePermission()));
        }
      });
    } else {
      if (id == 1) {
        id = "-1";
      }
      final body = jsonEncode({
        "user_id": prefs.getString("userId"),
        "status_id": id.toString(),
        "leave_request_id": widget.toString()
      });
      print(body);
      ApiService.post("leaveApprovals",body).then((success) {
        String data = success.body; //store response as string
        data = jsonDecode(data)['message'];
      });
    }
  }

  void approve(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Approved Successfully'),
        action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  void reject(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Rejected Successfully'),
        action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  void cancel(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Cancelled Successfully'),
        action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}
