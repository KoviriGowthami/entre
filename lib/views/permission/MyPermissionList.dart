import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';
import '../../helpers/Utilities.dart';

class MypermissionList extends StatefulWidget {
  const MypermissionList({Key key}) : super(key: key);

  @override
  _MypermissionListState createState() => _MypermissionListState();
}

class _MypermissionListState extends State<MypermissionList> {
  List permissionList;
  bool isVisible = false;
  bool listVisible = false;
  bool isInternetAvailable = true;


  void initState() {
    super.initState();
    getPermissionList();
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
            "My Permission List",
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
          child: Column(
              children: [
                Visibility(
                    visible: listVisible,
                    child: Container(
                        height: MediaQuery.of(context).size.height*0.7,
                        child: SafeArea(
                          bottom: true,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: permissionList == null ? 0 : permissionList.length,
                              itemBuilder: (context, index) {
                                return ApprovePermissionList(
                                  date: permissionList[index]['date'],
                                  reason: permissionList[index]['reason'],
                                  status: permissionList[index]['status'],
                                  fromtime: permissionList[index]['from_time'],
                                  toTime: permissionList[index]['to_time'],
                                );
                              },
                            )))),
                Visibility(
                  visible: isVisible,
                  child: Center(
                    heightFactor: 1.5,
                    child: Container(
                      child: Lottie.network(
                          'https://assets10.lottiefiles.com/private_files/lf30_lkquf6qz.json',fit: BoxFit.fill,),
                    ),
                  ),
                )
              ],
            ),
        ));
  }

  getPermissionList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('getPrmsnLstByEmp',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        permissionList = jsonDecode(data)['prmsnList'];
        if (permissionList.length == 0) {
          isVisible = true;
        } else {
          listVisible = true;
        }
      }); // just printed length of data
    });
  }
}

class ApprovePermissionList extends StatefulWidget {
  final String date;
  final String reason;
  final String status;
  final String fromtime;
  final String toTime;

  ApprovePermissionList({this.date, this.reason, this.status, this.fromtime, this.toTime});

  @override
  _ApprovePermissionListState createState() => _ApprovePermissionListState();
}

class _ApprovePermissionListState extends State<ApprovePermissionList> {
  String statusName = '';
  String reasonName;
  String fromtime;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          margin: EdgeInsets.only(right: 16,left: 16),
          padding: EdgeInsets.only(top: 16, right: 16, left: 16),
          child: Column(
      children: <Widget>[
          Card(
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              child: Column(
            children: [
              ListTile(
                leading: Image.asset(
                  _setImage(),
                  height: 150,
                ),
                title: Text(
                  "\nDate : ${widget.date}  \n\nFrom Time :  ${widget.fromtime} hrs \n\nTo Time :  ${widget.toTime} hrs \n\nReason : ${widget.reason} \n\nStatus : $statusName \n",
                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'avenir',),
                ),
              ),
            ],
          ))
      ],
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
