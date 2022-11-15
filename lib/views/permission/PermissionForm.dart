import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';
import '../home/HomeTabs.dart';

class PermissionForm extends StatefulWidget {
  @override
  _PermissionFormState createState() => _PermissionFormState();
}

class _PermissionFormState extends State<PermissionForm> {
  String _selectedFromDate = 'Select  Date';
  String _selectFromTime = 'Select From Time';
  String _selectToTym = 'Select To Time';
  String _reasonType = 'Select Reason';
  String reasonName;
  String comment;
  String _hour, _minute, _time;
  String _fromhour, _fromminute, _fromtime;
  String dateTime;
  DateTime selectedDate = DateTime.now();
  TimeOfDay fromselectedTime = TimeOfDay(hour: 00, minute: 00);
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  TextEditingController _timeController = TextEditingController();
  var discription = TextEditingController();
  var selectedFromdate = TextEditingController();
  var selectedToTime = TextEditingController();
  var body;
  bool isInternetAvailable = true;


  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.blue, // navigation bar color
      statusBarColor: Colors.white, // status bar color
    ));
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
    ): new Scaffold(
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
            "Apply Permission",
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
          physics: NeverScrollableScrollPhysics(),
          child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/body_bg.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  SizedBox(
                    height: 500,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(18, 50, 18, 0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage("assets/images/applyleave_card.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Column(
                        children: [
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
                                  title: Text(
                                    _selectedFromDate,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: Color(0xFF000000)),
                                  ))),
                          Card(
                              margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                              child: ListTile(
                                onTap: () {
                                  _selectTime(context);
                                },
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.timer_outlined,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    _selectTime(context);
                                  },
                                ),
                                title: Text(_selectFromTime,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: Color(0xFF000000))),
                              )),
                          Card(
                              margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                              child: ListTile(
                                onTap: () {
                                  _selectToTim(context);
                                },
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.timer_outlined,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    _selectToTim(context);
                                  },
                                ),
                                title: Text(_selectToTym,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: Color(0xFF000000))),
                              )),
                          Card(
                            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: ListTile(
                                title: Text(_reasonType,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: Color(0xFF000000))),
                                trailing: DropdownButton(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black,
                                  ),
                                  iconSize: 42,
                                  items: <String>[
                                    'Cold',
                                    'Fever',
                                    'headache',
                                    'PersonalWork',
                                    'others'
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
                                      reasonName = newVal;
                                      _reasonType = 'Selected Reason';
                                    });
                                  },
                                  value: reasonName,
                                )),
                          ),
                          SizedBox(
                            height: 40,
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
                                      if (_selectedFromDate == 'Select  Date') {
                                        Utilities.showAlert(
                                            context, "Please Select Date");
                                      } else if (_selectFromTime ==
                                          'Select From Time') {
                                        Utilities.showAlert(
                                            context, "Please Select From Time");
                                      } else if (_selectToTym ==
                                          'Select To Time') {
                                        Utilities.showAlert(
                                            context, "Please Select To Time");
                                      } else if (reasonName == null) {
                                        Utilities.showAlert(
                                            context, "Please Select Reason");
                                      } else {
                                        applyPermsion();
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
                                    onTap: () async {
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
                        ],
                      ),
                    ),
                  ),
                ]),
              )),
        ));
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 0)),
      lastDate: DateTime(2100),
    );
    if (date != null) //if the user has selected a date
      setState(() {
        _selectedFromDate = Jiffy(date).format('dd-MM-yyyy');
        _selectFromTime = 'Select From Time';
        _selectToTym = "Select To Time";
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    if (_selectedFromDate == "Select  Date") {
      final snackBar = SnackBar(
        content: Text('Please Select Date'),
        action: SnackBarAction(
          label: 'ok',
          textColor: Colors.white,
          onPressed: () {
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: fromselectedTime,
      );
      if (picked != null)
        setState(() {
          _selectToTym = "Select To Time";
          fromselectedTime = picked;
          _fromhour = fromselectedTime.hour.toString();
          _fromminute = fromselectedTime.minute.toString();
          _fromtime = _fromhour + ':' + _fromminute;
          _timeController.text = _fromtime;
          _selectFromTime = _fromtime;
          _timeController.text = formatDate(
              DateTime(
                  2019, 08, 1, fromselectedTime.hour, fromselectedTime.minute),
              [hh, ':', nn, " ", am]).toString();
        });
    }
  }

  Future<Null> _selectToTim(BuildContext context) async {
    if (_selectFromTime == "Select From Time") {
      final snackBar = SnackBar(
        content: Text('Please Select From Time'),
        action: SnackBarAction(
          label: 'ok',
          textColor: Colors.white,
          onPressed: () {
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: selectedTime,
      );
      if (picked != null)
        setState(() {
          selectedTime = picked;
          _hour = selectedTime.hour.toString();
          _minute = selectedTime.minute.toString();
          _time = _hour + ':' + _minute;
          _timeController.text = _time;

          DateTime now =
              DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute);
          DateTime berlinWallFellDate = DateTime(
              2019, 08, 1, fromselectedTime.hour, fromselectedTime.minute);
          if (berlinWallFellDate.compareTo(now) > 0) {
            _selectToTym = "Select To Time";
            final snackBar = SnackBar(
              content: Text('To time should be greater than From Time'),
              action: SnackBarAction(
                label: 'ok',
                onPressed: () {
                },
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            _selectToTym = _time;
            _timeController.text = formatDate(
                DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
                [hh, ':', nn, " ", am]).toString();
          }
        });
    }
  }

  applyPermsion() async {
    String id;
    if (reasonName == 'Cold') {
      id = '12';
    } else if (reasonName == 'Fever') {
      id = '14';
    } else if (reasonName == 'headache') {
      id = '17';
    } else if (reasonName == 'PersonalWork') {
      id = '16';
    } else {
      id = '19';
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({
      "date": _selectedFromDate,
      "from_time": _selectFromTime,
      "to_time": _selectToTym,
      "reason": id,
      "statusId": "2",
      "submitted_by": int.parse(prefs.getString("userId")),
      "comment": discription.text
    });
    ApiService.post('permsnAdd',body).then((success) {
      final body = json.decode(success.body);
      setState(() {
        if (body['message'] == "successful") {
          final snackBar = SnackBar(
            content: Text('Permission Applied Success'),
            action: SnackBarAction(
              label: 'ok',
              onPressed: () {
              },
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeTabs(),
            ),
          );
        }
      });
    });
  }
}
