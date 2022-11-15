import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';
import 'OT.dart';

class Overtime extends StatefulWidget {
  @override
  _OvertimeState createState() => _OvertimeState();
}

class _OvertimeState extends State<Overtime> {
  String _selectedFromDate = 'Select  Date';
  String _selectToTime = 'Select From Time';
  String _selectToTym = 'Select To Time';
  String reasonName;
  String comment;
  String _fromhour, _fromminute, _fromtime;
  String _hour, _minute, _time;
  String dateTime;
  DateTime selectedDate = DateTime.now();
  TimeOfDay fromselectedTime = TimeOfDay(hour: 00, minute: 00);
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  TextEditingController _timeController = TextEditingController();
  var discription = TextEditingController();
  List empList;
  String selectedemp = "Employee details";
  String selectedempid = "0";
  List searchResult = [];
  final TextEditingController _typeAheadController = TextEditingController();
  var body;
  List empNames = [];
  bool isInternetAvailable = true;


  void initState() {
    super.initState();
    getEmployeeList();
  }

  @override
  Widget build(BuildContext context) {
    var format = DateFormat("HH:mm");
    var one = format.parse("10:40");
    var two = format.parse("18:20");

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
          "OVER TIME",
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
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/body_bg.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: ListView(shrinkWrap: true, children: <Widget>[
            Card(
                margin: EdgeInsets.fromLTRB(30, 30, 30, 10),
                child: Column(
                  children: <Widget>[
                    TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: this._typeAheadController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: " Employee Details"),
                      ),
                      suggestionsCallback: (pattern) async {
                        return getfilteredLIst(pattern, empList);
                      },
                      itemBuilder: (context, empList) {
                        return ListTile(
                          onTap: () {
                            this._typeAheadController.text =
                                empList['emp_name'];
                            setState(() {
                              selectedempid = empList['emp_number'];
                              selectedemp = empList['emp_name'];
                            });
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          leading: Icon(
                            Icons.person_add,
                            color: Colors.black,
                            size: 20.0,
                          ),
                          title: Text(empList['emp_name'] +
                              '  (${empList['emp_number']})'),
                        );
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (suggestion) {
                        this._typeAheadController.text = suggestion;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please select employee';
                        }
                        return value;
                      },
                      onSaved: (value) {
                        this.selectedempid = value;
                      },
                    ),
                  ],
                )),
            Card(
                margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: ListTile(
                  onTap: () {
                    _selectFromDate(context);
                  },
                  trailing: IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      _selectFromDate(context);
                    },
                  ),
                  title: Text(_selectedFromDate,
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Color(0xFF000000))),
                )),
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
                    title: Text(_selectToTime,
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Color(0xFF000000))))),
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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
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
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: GestureDetector(
                  child: Image.asset('assets/images/applynew_btn.png',height: 30,),
                  onTap: () {
                    applyPermsion();
                  }),
            ),
          ]),
        ),
      ),
    );
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
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    if (_selectedFromDate == "Select  Date") {
      final snackBar = SnackBar(
        content: Text('Please Select Date'),
        action: SnackBarAction(
          label: 'ok', onPressed: () {  },
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
          fromselectedTime = picked;
          _fromhour = fromselectedTime.hour.toString();
          _fromminute = fromselectedTime.minute.toString();
          _fromtime = _fromhour + ':' + _fromminute;
          _timeController.text = _fromtime;
          _selectToTime = _fromtime;
          _timeController.text = formatDate(
              DateTime(
                  2019, 08, 1, fromselectedTime.hour, fromselectedTime.minute),
              [hh, ':', nn, " ", am]).toString();
        });
    }
  }

  Future<Null> _selectToTim(BuildContext context) async {
    if (_selectToTime == "Select From Time") {
      final snackBar = SnackBar(
        content: Text('Please Select From Time'),
        action: SnackBarAction(
          label: 'ok', onPressed: () {  },
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

    if ((_typeAheadController.text == "" || selectedemp == null)) {
      Utilities.showAlert(context, "Please Select Employee");
    } else if (_selectedFromDate == "Select  Date") {
      Utilities.showAlert(context, "Please Select Date");
    } else if (_selectToTime == "Select From Time") {
      Utilities.showAlert(context, "Please Select From Time");
    } else if (_selectToTym == "Select To Time") {
      Utilities.showAlert(context, "Please Select To Time");
    }
    else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final body = jsonEncode({
        "otdate": _selectedFromDate,
        "start_time": _selectToTime,
        "end_time": _selectToTym,
        "status": "1",
        "emp_number": selectedempid,
        "user_id": int.parse(prefs.getString("userId")),
        "reason": discription.text.toString()
      });
      ApiService.post('assignOvertime',body).then((success) {
        setState(() {
          final snackBar = SnackBar(
            content: Text('OT Applied Success'),
            action: SnackBarAction(
              label: 'ok', onPressed: () {  },
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OT(),
            ),
          );
        });
      });
    }
  }

  getfilteredLIst(pattern, empList) {
    if (pattern == "") {
      return empList;
    } else {
      searchResult.clear();
      for (int i = 0; i < empList.length; i++) {
        var data = empList[i]['emp_name'];
        if (data.toLowerCase().contains(pattern.toLowerCase())) {
          searchResult.add(empList[i]);
        }
      }
      return searchResult;
    }
  }

  getEmployeeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('subOrdinateEmployees',body).then((success) {
      String data = success.body; //store response as string

      setState(() {
        empList = jsonDecode(data)['subOrdinateEmployees'];
        for (int i = 0; i < empList.length; i++) {
          empNames.add(empList[i]['emp_name'].replaceAll(' ', ''));
        }
      }); // just printed length of data
    });
  }
}
