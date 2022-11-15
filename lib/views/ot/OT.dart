import 'dart:convert';

import 'package:entreplan_flutter/views/ot/OtStatus.dart';
import 'package:entreplan_flutter/views/ot/Overtime.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';
import '../../helpers/Utilities.dart';

class OT extends StatefulWidget {
  @override
  _OTState createState() => _OTState();
}

class _OTState extends State<OT> {
  bool isVisible = false;
  bool isNdVisible = false;
  bool listVisible = false;
  String statusName;
  void initState() {
    super.initState();
    getOvertimeList();
  }

  List otList;
  String roleName = "";
  bool isInternetAvailable = true;

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
            "OverTime List",
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
          child:SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: ListTile(
                      onTap: () {},
                      title: Text("Sort by",
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Color(0xFF000000))),
                      trailing: DropdownButton(
                        hint: Text('All',),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                        iconSize: 42,
                        items: <String>[
                          'New',
                          'Claim Request',
                          'Verify',
                          'Approved',
                          'Rejected',
                          'Claimed'
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
                            statusName = newVal;
                            getOvertimeList();
                          });
                        },
                        value: statusName,
                      )),
                ),
                Visibility(
                    visible: listVisible,
                    child: Container(
                        child: SafeArea(
                          bottom: true,
                          child: ListView.builder(
                            physics: ScrollPhysics(),
                                    shrinkWrap:true,
                                    itemCount: otList == null ? 0 : otList.length,
                                    itemBuilder: (context, index) {
                                      return MyOtListTile(
                                          date: otList[index]['date'],
                                          startTime: otList[index]['start_time'],
                                          endTime: otList[index]['end_time'],
                                          status: otList[index]['status'],
                                          id: otList[index]['id'],
                                          claimType: otList[index]['claim_type'],
                                          name: otList[index]['name'],
                                          hours: otList[index]['hours'],
                                          roleName: roleName);
                                    },
                                  ),
                        ))),
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
          ),
        ),
        floatingActionButton: Container(
          width: 300,
          margin: EdgeInsets.only(right: 35),
          child: new Visibility(
            visible: isVisible,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Overtime()));
                // Add your onPressed code here!
              },
              label: const Text('Assign OT',style: TextStyle(fontFamily: 'Myriad',color: Colors.white),),
              icon: const Icon(Icons.add,color: Colors.white,),
              backgroundColor: Color(0xFF7d7d7d),
            ),
          ),
        ));
  }

  getOvertimeList() async {
    String statusId;
    if (statusName == 'Verify') {
      statusId = '3';
    } else if (statusName == 'Claim Request') {
      statusId = '2';
    } else if (statusName == 'Approved') {
      statusId = '4';
    } else if (statusName == 'Rejected') {
      statusId = '5';
    }  else if (statusName == 'Claimed') {
      statusId = '6';
    } else {
      statusId = '1';
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final body = jsonEncode({
      "user_id": prefs.getString('userId'),
      "role": prefs.getString("role"),
      "status_id" : statusId
    });
    ApiService.post('myOtList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        otList = jsonDecode(data)['myOtList'];
        roleName = prefs.getString("role");
        if (otList.length == 0) {
          isNdVisible = true;
          listVisible = false;
        } else {
          listVisible = true;
          isNdVisible = false;
        }
        if (prefs.getString("role") == "Supervisor") {
          isVisible = true;
        }
      });
    });
  }
}

class MyOtListTile extends StatefulWidget {
  final String date;
  final String startTime;
  final String endTime;
  final String status;
  final String id;
  final String claimType;
  final String name;
  final String hours;
  final String roleName;

  MyOtListTile(
      {this.date,
      this.startTime,
      this.endTime,
      this.id,
      this.status,
      this.claimType,
      this.name,
      this.hours,
      this.roleName});
  @override
  _MyOtListTileState createState() => _MyOtListTileState();
}

class _MyOtListTileState extends State<MyOtListTile> {
  String statusName = '';
  String claimType = '';

  @override
  Widget build(BuildContext context) {
    if (widget.claimType == "0") {
      claimType = "";
    } else if (widget.claimType == "2") {
      claimType = "Cash";
    } else if (widget.claimType == "1") {
      claimType = "Leave";
    }
    return GestureDetector(
        child: Container(
      margin: EdgeInsets.only(right: 16),
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
                DateTime now = new DateTime.now();
                DateTime berlinWallFellDate =
                    DateTime.parse(widget.date + ' ' + widget.endTime);
// 0 denotes being equal positive value greater and negative value being less
                if (berlinWallFellDate.compareTo(now) > 0) {
                  //peform logic here.....
                  final snackBar = SnackBar(
                    duration: const Duration(seconds: 5),
                    content: Text('Cannot claim until Over Time complete'),
                    action: SnackBarAction(
                      label: 'ok',
                      textColor: Colors.white,
                      onPressed: () {
                        // Some code to undo the change.
                      },
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  print(berlinWallFellDate.compareTo(now));
                  print("else");
                  if (widget.roleName == "Supervisor" &&
                      (widget.status == "Claim Request" ||
                          widget.status == "New")) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OtStatus(
                                type: "otList",
                                id: widget.id,
                                claimType: widget.claimType)));
                  } else if (widget.roleName == "HiringManager" &&
                      widget.status == "Approved") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OtStatus(
                                type: "otList",
                                id: widget.id,
                                claimType: widget.claimType)));
                  } else if ((widget.roleName == "Department Manager" ||
                          widget.roleName == "HOD") &&
                      widget.status == "Verified") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OtStatus(
                                type: "otList",
                                id: widget.id,
                                claimType: widget.claimType)));
                  }
                }
              },
              leading: Image.asset(
                _setImage(),
                height: 150,
              ),
              title: Text(
                "\nName: ${widget.name} \n\nDate : ${widget.date}  \n\nStart Time :  ${widget.startTime} hrs \n\nEnd Time :  ${widget.endTime} hrs \n\nHours :  ${widget.hours} "
                "hrs \n\nClaim: $claimType \n\nStatus:${widget.status}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'avenir',),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  String _setImage() {
    String statusState = widget.status;
    if (statusState == "Claim") {
      statusName = "Claim";
      return "assets/images/claimed.png";
    }
    if (statusState == "Claimed") {
      statusName = "Claim";
      return "assets/images/claimed.png";
    } else if (statusState == "Rejected") {
      statusName = "Rejected";
      return "assets/images/reject.png";
    } else if (statusState == "Verified") {
      statusName = "Verified";
      return "assets/images/verified.png";
    } else if (statusState == "Approved") {
      statusName = "Approved";
      return "assets/images/approved.png";
    } else {
      statusName = "New";
      return "assets/images/pending.png";
    }
  }
}
