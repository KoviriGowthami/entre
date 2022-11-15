import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/Utilities.dart';

class PunchinEmpDetails extends StatefulWidget {
  final String type;
  PunchinEmpDetails({Key key, @required this.type}) : super(key: key);
  @override
  _PunchinEmpDetailsState createState() => _PunchinEmpDetailsState();
}

class _PunchinEmpDetailsState extends State<PunchinEmpDetails> {
  bool isNdVisible = false;
  bool listVisible = false;
  String appTitle = "";
  bool isInternetAvailable = true;
  void initState() {
    super.initState();
    if (widget.type == "visitor") {
      appTitle = "Visitor Details";
      getvisitorList();
    } else {
      getpunchinList();
      appTitle = "Punchedin Employee Details";
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.green, // navigation bar color
      statusBarColor: Colors.green, // status bar color
    ));
  }

  List punchinList;
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
    ):
    Scaffold(
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Visibility(
                      visible: listVisible,
                      child: Container(
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.88,
                              child: SafeArea(
                                bottom: true,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: punchinList == null
                                      ? 0
                                      : punchinList.length,
                                  itemBuilder: (context, index) {
                                    if (widget.type == "visitor") {
                                      return VisitorEmpDetailsTile(
                                          vehicleNumber: punchinList[index]
                                              ['vehicle_number'],
                                          address: punchinList[index]['address'],
                                          name: punchinList[index]['name'],
                                          passId: punchinList[index]['pass_id']);
                                    } else {
                                      return PunchinEmpDetailsTile(
                                        employeeName: punchinList[index]['name'],
                                        employeeCode: punchinList[index]
                                            ['empCode'],
                                        departmentName: punchinList[index]
                                            ['department'],
                                        earlyIn: punchinList[index]['earlyIn'],
                                        lateIn: punchinList[index]['lateIn'],
                                        earlyOut: punchinList[index]
                                            ['earlyOut'],
                                        lateOut: punchinList[index]['lateOut'],
                                      );
                                    }
                                  },
                                ),
                              )))),
                  Visibility(
                    visible: isNdVisible,
                    child: Center(
                      heightFactor: 1.5,
                      child: Container(
                        child: Lottie.network(
                          'https://assets10.lottiefiles.com/private_files/lf30_lkquf6qz.json',fit: BoxFit.fill,),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }

  getpunchinList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"departmentId":prefs.getString("deptId"),"cdate":Jiffy(DateTime.now()).format('yyyy-MM-dd')});
    ApiService.post('empPunchIn',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        punchinList = jsonDecode(data)['empPunchInList'];
        print(punchinList);
        for (int i = 0; i < punchinList.length; i++) {
        }
        if (punchinList.length == 0) {
          isNdVisible = true;
          listVisible = false;
        } else {
          listVisible = true;
          isNdVisible = false;
        }
      }); // just printed length of data
    });
  }

  getvisitorList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});

    ApiService.post('visitorInPlantCountAndList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        punchinList = jsonDecode(data)['visitor_personslist'];
        for (int i = 0; i < punchinList.length; i++) {
        }
        if (punchinList.length == 0) {
          isNdVisible = true;
        } else {
          listVisible = true;
        }
      }); // just printed length of data
    });
  }
}

class PunchinEmpDetailsTile extends StatefulWidget {
  final String employeeName;
  final String employeeCode;
  final String departmentName;
  final String earlyIn;
  final String lateIn;
  final String earlyOut;
  final String lateOut;

  PunchinEmpDetailsTile(
      {Key key,
      this.employeeName,
      this.employeeCode,
      this.departmentName,
      this.earlyIn,
      this.lateIn,
      this.earlyOut,
      this.lateOut});
  @override
  _PunchinEmpDetailsTileState createState() => _PunchinEmpDetailsTileState();
}

class _PunchinEmpDetailsTileState extends State<PunchinEmpDetailsTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
      margin: EdgeInsets.only(right: 16,left: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      padding: EdgeInsets.only(top: 16, right: 16, left: 16),
      child: Card(
        color: Color(0xfff1f3f6),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Table(
                children: [
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Employee",style: TextStyle(
                        fontFamily: 'Myriad',
                      ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(widget.employeeName,style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Code",style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(widget.employeeCode,style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Department",style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(widget.departmentName,style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Early In",style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(widget.earlyIn,style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Late In",style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(widget.lateIn,style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Early Out",style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(widget.earlyOut,style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    )
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Late Out",style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(widget.lateOut,style: TextStyle(
                        fontFamily: 'Myriad',
                      ),),
                    )
                  ]),
                ],
              )
            ),
          ],
        ),
      ),
    ));
  }
}

class VisitorEmpDetailsTile extends StatefulWidget {
  final String vehicleNumber;
  final String address;
  final String name;
  final String passId;
  VisitorEmpDetailsTile(
      {Key key, this.vehicleNumber, this.address, this.name, this.passId});
  @override
  _VisitorEmpDetailsTileState createState() => _VisitorEmpDetailsTileState();
}

class _VisitorEmpDetailsTileState extends State<VisitorEmpDetailsTile> {
  @override
  Widget build(BuildContext context) {
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
              title: Text(
                "\n"
                "  Name                       :   ${widget.name}"
                "\n\n Address                   :   ${widget.address} "
                "\n\n Vehicle Number     :   ${widget.vehicleNumber}"
                "\n\n Pass Id                    :   ${widget.passId}"
                "\n",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'avenir',
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
