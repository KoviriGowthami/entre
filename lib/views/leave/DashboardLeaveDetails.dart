import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';
import '../../helpers/Utilities.dart';

class DashBoardLeaveDetails extends StatefulWidget {
  const DashBoardLeaveDetails({Key key}) : super(key: key);

  @override
  State<DashBoardLeaveDetails> createState() => _DashBoardLeaveDetailsState();
}

class _DashBoardLeaveDetailsState extends State<DashBoardLeaveDetails> {
  bool isNdVisible = false;
  bool listVisible = false;
  List empLeaveList = [];
  bool isInternetAvailable = true;
  DateTime latedate;
  String empLateInDate = Jiffy(DateTime.now()).format('dd-MM-yyyy');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEmpLeaveDetails();
  }

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
                "Leave Details",
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
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          child: Card(
                            margin: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Myriad',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap:(){
                                        _lateInDate(context);
                                      },
                                      child: Text(
                                        empLateInDate,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Myriad',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          _lateInDate(context);
                                        },
                                        icon: Icon(
                                          Icons.calendar_month_outlined,
                                          size: 20,
                                        )),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                          visible: listVisible,
                          child: Container(
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  child: SafeArea(
                                    bottom: true,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: empLeaveList == null
                                          ? 0
                                          : empLeaveList.length,
                                      itemBuilder: (context, index) {
                                        return EmpLeaveDetailsTile(
                                            employeeName: empLeaveList[index]
                                                ['name'],
                                            duration: empLeaveList[index]
                                                ['duration'],
                                            durationType: empLeaveList[index]
                                                ['durationType'],
                                            leaveType: empLeaveList[index]
                                                ['type'],
                                            leaveStatus: empLeaveList[index]
                                                ['status']);
                                      },
                                    ),
                                  )))),
                      Visibility(
                        visible: isNdVisible,
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
                    ],
                  ),
                )));
  }

  Future<void> _lateInDate(BuildContext context) async {
    latedate = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 60)),
      lastDate: DateTime.now(),
    );
    if (latedate != null) //if the user has selected a date
      setState(() {
        empLateInDate = Jiffy(latedate).format('dd-MM-yyyy');
        print(empLateInDate);
        getEmpLeaveDetails();
      });
  }

  getEmpLeaveDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode(
        {"plantId": prefs.getString('PlantId'), "date": empLateInDate});
    print(body);
    ApiService.post("empLeavesbyDt", body).then((success) {
      String data = success.body; //store response as string
      print(data);
      setState(() {
        empLeaveList = jsonDecode(data)['empLeaveList'];
        if (empLeaveList.length == 0) {
          isNdVisible = true;
          listVisible = false;
        } else {
          listVisible = true;
          isNdVisible = false;
        }
      });
    });
  }
}

class EmpLeaveDetailsTile extends StatefulWidget {
  final String employeeName;
  final String leaveType;
  final String leaveStatus;
  final String duration;
  final String durationType;

  EmpLeaveDetailsTile({
    Key key,
    this.employeeName,
    this.leaveType,
    this.leaveStatus,
    this.duration,
    this.durationType,
  });
  @override
  _EmpLeaveDetailsTileState createState() => _EmpLeaveDetailsTileState();
}

class _EmpLeaveDetailsTileState extends State<EmpLeaveDetailsTile> {
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
                      child: Text(widget.employeeName,
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
                        "Duration",
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(widget.duration,
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
                        "Duration Type",
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(widget.durationType,
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
                        "Type",
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(widget.leaveType,
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
                      child: Text(widget.leaveStatus,
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                      ),
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
}
