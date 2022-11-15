import 'dart:convert';

import 'package:entreplan_flutter/views/leave/UpdateLeaveStatus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';
import '../../helpers/Utilities.dart';

class ApprovePermission extends StatefulWidget {
  @override
  _ApprovePermissionState createState() => _ApprovePermissionState();
}

class _ApprovePermissionState extends State<ApprovePermission> {
  List permissionList;
  bool listVisible = false;
  bool isVisible = false;
  String roleName = "";
  bool isInternetAvailable = true;

  void initState() {
    super.initState();
    getpermissionList();
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
            "Approve Permission List",
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
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/body_bg.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(children: [
              Column(
                children: [
                  Visibility(
                      visible: listVisible,
                      child:Container(
                          height: MediaQuery.of(context).size.height*0.7,
                              child: SafeArea(
                                bottom: true,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                            itemCount: permissionList == null ? 0 : permissionList.length,
                            itemBuilder: (context, index) {
                                return MypermissionTile(
                                    date: permissionList[index]['date'],
                                    fromTime: permissionList[index]['from_time'],
                                    toTime: permissionList[index]['to_time'],
                                    reason: permissionList[index]['reason'],
                                    submitedBy: permissionList[index]['submitted_by'],
                                    id: permissionList[index]['id'],
                                    roleName: roleName,
                                    status: permissionList[index]['status']);
                            },
                          ),
                              ))),
                  Visibility(
                    visible: isVisible,
                    child: Center(
                      heightFactor: 1.5,
                      child: Container(
                        child: Lottie.network(
                          'https://assets10.lottiefiles.com/private_files/lf30_lkquf6qz.json',fit: BoxFit.fill,),
                      ),
                    ),
                  ),
                ],
              )
            ]),
          ),
        ));
  }

  getpermissionList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('subPrmsnList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        roleName = prefs.getString("role");
        permissionList = jsonDecode(data)['permList'];
        if (permissionList.length < 0) {}
        if (permissionList.length == 0) {
          isVisible = true;
          listVisible = false;
        } else {
          listVisible = true;
          isVisible = false;
        }
      }); // just printed length of data
    });
  }
}

class MypermissionTile extends StatefulWidget {
  final String date;
  final String fromTime;
  final String toTime;
  final String reason;
  final String submitedBy;
  final String id;
  final String status;
  final String roleName;

  MypermissionTile({this.date, this.fromTime, this.toTime, this.reason, this.submitedBy, this.id, this.roleName, this.status});

  @override
  _MypermissionTileState createState() => _MypermissionTileState();
}

class _MypermissionTileState extends State<MypermissionTile> {
  String statusName = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
      margin: EdgeInsets.only(right: 16,left: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      padding: EdgeInsets.only(top: 16, right: 16, left: 16),
      child: Card(
        color: Color(0xfff1f3f6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        child: Column(
          children: <Widget>[
            ListTile(
              onTap: () {
                if (widget.status == "New") {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateLeaveStatus(id: widget.id, type: "permission")));
                } else if ((widget.status == "Approved by supervisor") && (widget.roleName == "HOD")) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateLeaveStatus(id: widget.id, type: "permission")));
                } else if ((widget.status == "Approved by HOD") && (widget.roleName == "HiringManager")) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateLeaveStatus(id: widget.id, type: "permission")));
                }
              },
              leading: Image.asset(
                _setImage(),
                height: 150,
              ),
              title: Text(
                "\nEmployee :${widget.submitedBy} \n\nDate : ${widget.date}  \n\nFrom Time :  ${widget.fromTime} hrs \n\nTo Time :  ${widget.toTime} hrs \n\nStatus : ${widget.status} \n",
                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'avenir', ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  String _setImage() {
    String statusState = widget.status;
    if (statusState == "Approved by supervisor") {
      statusName = "Approved by supervisor";
      return "assets/images/pending.png";
    } else if (statusState == "Approved by HOD") {
      statusName = "Approved by HOD";
      return "assets/images/pending.png";
    } else if (statusState == "Approved by HR") {
      statusName = "Approved by HR";
      return "assets/images/approved.png";
    } else if (statusState == "Reject") {
      statusName = "Rejected";
      return "assets/images/reject.png";
    } else {
      statusName = "Pending For Approval";
      return "assets/images/pending.png";
    }
  }
}
