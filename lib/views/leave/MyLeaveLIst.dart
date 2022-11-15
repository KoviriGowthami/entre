import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';
import '../../helpers/Utilities.dart';
import 'UpdateLeaveStatus.dart';

class MyLeaveList extends StatefulWidget {
  const MyLeaveList({Key key}) : super(key: key);

  @override
  _MyLeaveListState createState() => _MyLeaveListState();
}

class _MyLeaveListState extends State<MyLeaveList> {
  String status;
  String status1;
  bool listVisible = false;
  bool isVisible = false;
  bool isInternetAvailable = true;

  void initState() {
    super.initState();
    getLeaveList();
  }

  onGoBack(dynamic value) {
    setState(() {});
    getLeaveList();
  }

  List leaveList;

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
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Text(
            "My Leave List",
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
            child: SingleChildScrollView(
              child: Column(children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
                  child: ListTile(
                      onTap: () {
                      },
                      title: Text("Status",
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Color(0xFF000000) ,fontFamily: 'Myriad',)),
                      trailing: DropdownButton(
                        hint: Text('Taken'),
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
                  child:  Container(
                    height: MediaQuery.of(context).size.height * 0.76,
                    child: SafeArea(
                        bottom: true,
                        child: ListView.builder(
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                          leaveList == null ? 0 : leaveList.length,
                          itemBuilder: (context, index) {
                            return MyLeaveListTile(
                               leaveList[index]['date_applied'] == null ? "" : leaveList[index]['date_applied'],
                               leaveList[index]['date'] == null ? "" : leaveList[index]['date'],
                               leaveList[index]['no_of_days'] == null ? "" : leaveList[index]['no_of_days'],
                               leaveList[index]['status'] == null ? "" : leaveList[index]['status'],
                               leaveList[index]['leave_request_id'] == null ? "" : leaveList[index]['leave_request_id'],
                            );
                          },
                        )),
                  ),
                ),
                Visibility(
                  visible: isVisible,
                  child: Center(
                    heightFactor: 1,
                    child: Container(
                      child: Lottie.network(
                          'https://assets10.lottiefiles.com/private_files/lf30_lkquf6qz.json',fit: BoxFit.fill,),
                    ),
                  ),
                ),
              ]),
            )));
  }

  getLeaveList() async {
    String StatusId;
    if (status == 'Pending') {
      StatusId = '1';
    } else if (status == 'Scheduled') {
      StatusId = '2';
    } else if (status == 'Rejected') {
      StatusId = '-1';
    } else if (status == 'Cancelled') {
      StatusId = '0';
    } else {
      StatusId = '3';
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body =
        jsonEncode({"user_id": prefs.getString('userId'), "status": StatusId});
    ApiService.post("MyLeavelist",body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        leaveList = jsonDecode(data)['MyLeaves'];
        print(leaveList);
        if (leaveList.length == 0) {
          isVisible = true;
          listVisible = false;
        } else {
          listVisible = true;
          isVisible = false;
        }
      });
    });
  }

  String statusName = '';
  @override
  Widget MyLeaveListTile(dateApplied,date, noofDays,status1,leaveRequesId) {
    this.status1 = status1;
    _setImage();
    return GestureDetector(
        child: Container(
      margin: EdgeInsets.only(right: 16,left: 16),
      padding: EdgeInsets.only(top: 16, right: 16, left: 16),
      child: Card(
        color: Color(0xfff1f3f6),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        child: Column(
          children: <Widget>[
            ListTile(
              onTap: () {
                var leaveType = 'Self';
                if (statusName == "New" || statusName == "Scheduled") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdateLeaveStatus(
                            id: leaveRequesId,
                            type: "leave",
                            leaveType: leaveType,
                            leaveEmpName: '',
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
                        "Date Applied",style: TextStyle(
                        fontFamily: 'Myriad',
                      ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(dateApplied,style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Date",style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(date,style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("No. of Days",style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(noofDays,style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Status",style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(statusName,style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    )
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  String _setImage() {
    String statusState = status1;
    if (statusState == "2") {
      statusName = "Scheduled";
    } else if (statusState == "-1") {
      statusName = "Rejected";
    } else if (statusState == "3") {
      statusName = "Taken";
    } else if (statusState == "1") {
      statusName = "New";
    } else {
      statusName = "Cancelled";
    }
  }
}
