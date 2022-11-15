import 'dart:convert';

import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';
import '../home/HomeTabs.dart';
import '../home/ListViewHome.dart';

class ApplyLeave extends StatefulWidget {
  @override
  _ApplyLeaveState createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> {
  String _selectedFromDate = ' Select From  Date';
  String _selectedToDate = ' Select To  Date';
  List meetinglist_room = [];
  String _meetingroom;
  String slotTime;
  String leave = "";
  String leaveTypeid = "";
  String leaveBalanace = "";
  String comment;
  var discription = TextEditingController();
  DateTime fromdate;
  var body;
  List durationType = [
    {"id": "1", "name": "Morning"},
    {"id": "2", "name": "Afternoon"}
  ];
  List dayDurationType = [];
  String durationTypeValue;
  String durationTypeValueId = "";
  String dayDurationTypeValue;
  String dayDurationTypeId = "";
  bool isDuration = false;
  bool isDurationCard = false;
  bool isInternetAvailable = true;

  void initState() {
    super.initState();
    leavetype("");
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
    return isInternetAvailable?
    Scaffold(
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
            "Apply Leave",
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
          child:Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/body_bg.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child:  SingleChildScrollView(
                child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(18, 50, 18, 0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                                AssetImage("assets/images/applyleave_card.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Column(children: [
                          Card(
                            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                                  child: Text(
                                    "Select Leave Type",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Myriad',
                                    ),
                                  ),
                                ),
                                ListTile(
                                  dense: true,
                                  trailing: DropdownButton(
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black,
                                    ),
                                    iconSize: 30,
                                    items: meetinglist_room.map((item) {
                                      return new DropdownMenuItem(
                                          child: new Text(
                                            item['name'],
                                          ),
                                          value: item['name']);
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _meetingroom = value;
                                        for (int i = 0;
                                            i < meetinglist_room.length;
                                            i++) {
                                          if (value ==
                                              meetinglist_room[i]['name']) {
                                            loadJson(meetinglist_room[i]['id']);
                                            leaveTypeid =
                                                meetinglist_room[i]['id'];
                                          }
                                        }
                                      });
                                    },
                                    value: _meetingroom,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Card(
                            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: ListTile(
                              title: Text('Available Leaves :  $leaveBalanace',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Color(0xFF000000),
                                    fontFamily: 'Myriad',
                                  )),
                            ),
                          ),
                          Card(
                              margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                              child: ListTile(
                                onTap: () {
                                  _selectFromDate(context);
                                },
                                trailing: IconButton(
                                  icon: Image.asset(
                                    "assets/images/cal_icon1.png",
                                  ),
                                  onPressed: () {
                                    _selectFromDate(context);
                                  },
                                ),
                                title: Text(_selectedFromDate,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Color(0xFF000000),
                                      fontFamily: 'Myriad',
                                    )),
                              )),
                          Card(
                              margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                              child: ListTile(
                                onTap: () {
                                  _selectDate(context);
                                },
                                trailing: IconButton(
                                  icon: Image.asset(
                                    "assets/images/cal_icon2.png",
                                  ),
                                  onPressed: () {
                                    _selectDate(context);
                                  },
                                ),
                                title: Text(_selectedToDate,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Color(0xFF000000),
                                      fontFamily: 'Myriad',
                                    )),
                              )),
                          Visibility(
                            visible: isDurationCard,
                            child: Card(
                              margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                                    child: Text(
                                      "Duration",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Myriad',
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.only(left: 50),
                                        dense: true,
                                        trailing: DropdownButton(
                                          hint: Text('Select'),
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.black,
                                          ),
                                          iconSize: 30,
                                          items: dayDurationType.map((item) {
                                            return new DropdownMenuItem(
                                                child: new Text(
                                                  item['name'],
                                                ),
                                                value: item['name']);
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              dayDurationTypeValue = null;
                                              dayDurationTypeId = null;
                                              dayDurationTypeValue = value;
                                              for (int i = 0; i < dayDurationType.length; i++) {
                                                if (value == dayDurationType[i]['name']) {
                                                  dayDurationTypeId = dayDurationType[i]['id'].toString();
                                                }
                                              }
                                              if(dayDurationTypeId == '0'){
                                               setState(() {
                                                 durationTypeValueId = '0';
                                               });
                                              }
                                              durationVisibility();
                                            });
                                          },
                                          value: dayDurationTypeValue,
                                        ),
                                      ),
                                      Visibility(
                                        visible: isDuration,
                                        child: ListTile(
                                          contentPadding: EdgeInsets.only(left: 50),
                                          dense: true,
                                          trailing: DropdownButton(
                                            hint: Text('Select'),
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black,
                                            ),
                                            iconSize: 30,
                                            items: durationType.map((item) {
                                              return new DropdownMenuItem(
                                                  child: new Text(
                                                    item['name'],
                                                  ),
                                                  value: item['name']);
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                durationTypeValue = '';
                                                durationTypeValue = value;
                                                for (int i = 0; i < durationType.length; i++) {
                                                  if (value == durationType[i]['name']) {
                                                    durationTypeValueId = durationType[i]['id'];
                                                  }
                                                }
                                              });
                                            },
                                            value: durationTypeValue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
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
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'Myriad',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: GestureDetector(
                                    child: Image.asset(
                                        'assets/images/applynew_btn.png',
                                        height: 30),
                                    onTap: () async {
                                      if (leaveTypeid == '') {
                                        Utilities.showAlert(context,
                                            "Please Select To  Leave Type");
                                      }else if (_selectedFromDate ==
                                          ' Select From  Date') {
                                        Utilities.showAlert(
                                            context, "Please Select From  Date");
                                      } else if (_selectedToDate ==
                                          ' Select To  Date') {
                                        Utilities.showAlert(
                                            context, "Please Select To  Date");
                                      }else if (dayDurationTypeId == '') {
                                        Utilities.showAlert(context,
                                            "Please Select Duration");
                                      } else {
                                        applyLeave("");
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Container(
                                  child: GestureDetector(
                                    child: Image.asset(
                                        'assets/images/cancelnew_btn.png',
                                        height: 30),
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                        ]),
                      ),
                    ],
                  ),
              ),
              ),
        ));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 60)),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      var now = date;
      var berlinWallFellDate = fromdate;
// 0 denotes being equal positive value greater and negative value being less
      if (berlinWallFellDate.compareTo(now) > 0) {
        setState(() {
          _selectedToDate = ' Select To  Date';
        });
        final snackBar = SnackBar(
          content: Text('To date should be greater than From date'),
          action: SnackBarAction(
            label: 'ok',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        //peform logic here.....
      } else {
        setState(() {
          _selectedToDate = Jiffy(date).format('dd-MM-yyyy');
        });
      } //if the user has selected a date

    }
  }

  Future<void> _selectFromDate(BuildContext context) async {
    fromdate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 60)),
      lastDate: DateTime(2100),
    );
    if (fromdate != null) //if the user has selected a date
      setState(() {
        _selectedFromDate = Jiffy(fromdate).format('dd-MM-yyyy');
        _selectedToDate = Jiffy(fromdate).format('dd-MM-yyyy');
        isDurationCard = true;
        leaveDurationType();
      });
  }

  loadJson(leavebalance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({
      "user_id": int.parse(prefs.getString('userId')),
      "emp_number": int.parse(prefs.getString("empNumber")),
      "leaveType": leavebalance
    });

    ApiService.post('leaveCount',body,).then((success) {
      final body = json.decode(success.body);
      if (body['leaveCount'].length > 0) {
        setState(() {
          leaveBalanace = body['leaveCount'][0]["balance_leaves"].toString();
        });
      } else {
        setState(() {
          leaveBalanace = "0.0";
        });
      }
    });
  }

  applyLeave(leavebalance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({
      "user_id": int.parse(prefs.getString('userId')),
      "emp_number": int.parse(prefs.getString("empNumber")),
      "leave_type_id": leaveTypeid,
      "from_date": _selectedFromDate,
      "to_date": _selectedToDate,
      "comments": discription.text.toString(),
      "status_id": 1,
      "start_time": "",
      "end_time": "",
      "duration": int.parse(dayDurationTypeId),
      "duration_type" : int.parse(durationTypeValueId)
    });
    print(body);
     ApiService.post('applyLeave',body).then((success) {
      final body = json.decode(success.body);
      setState(() {
        final snackBar = SnackBar(
          content: Text(body['message']),
          action: SnackBarAction(
            label: 'Ok',
            textColor: Colors.white,
            onPressed: () {
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        if(body['message'] == 'Successfully submitted'){
          Navigator.pop(context);
        }
      }
          );
    });
  }

  leavetype(_meetingroom) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('leaveType',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        meetinglist_room = jsonDecode(data)['leaveType'];
        for (int i = 0; i < meetinglist_room.length; i++) {
          if (meetinglist_room[i]['name'] == _meetingroom) {
            leave = meetinglist_room[i]['name'];
          }
        }
      }); // just printed
    });
  }

  leaveDurationType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('leaveDuration',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        dayDurationType = jsonDecode(data)['leaveDuration'];
      }); // just printed
    });
  }

  durationVisibility() async {
    if(dayDurationTypeValue == "Half Day"){
      setState(() {
        isDuration = true;
      });
    }else{
      setState(() {
        isDuration = false;
      });
    }
  }

}
