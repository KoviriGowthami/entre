import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';
import '../home/HomeTabs.dart';

class AssignPermission extends StatefulWidget {
  @override
  _AssignPermissionState createState() => _AssignPermissionState();
}

class _AssignPermissionState extends State<AssignPermission> {
  String _selectedFromDate = 'Select  Date';
  String _selectFromTime = 'Select From Time';
  String _selectToTym = 'Select To Time';
  String _reasonType = 'Select Reason';
  String reasonName;
  String comment;
  List empList;
  String selectedemp = "Employee details";
  String selectedempid = "0";
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
  final TextEditingController _typeAheadController = TextEditingController();
  List searchResult = [];
  bool isInternetAvailable = true;

  void initState() {
    super.initState();
    getEmployeeList();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.blue, // navigation bar color
      statusBarColor: Colors.white, // status bar color
    ));
    makeEmployeeList();
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
          "Assign Permission",
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
              width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/body_bg.png"),
            fit: BoxFit.fill,
          ),
      ),
      child: SingleChildScrollView(
          child: Column(children: <Widget>[
            Container(
                color: Colors.white,
                margin: EdgeInsets.fromLTRB(30, 50, 30, 10),
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _typeAheadController,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 15),
                        border: InputBorder.none,
                        hintText: " Employee Name"),
                  ),
                  suggestionsCallback: (pattern) async {
                    return getfilteredLIst(pattern, empList);
                  },
                  itemBuilder: (context, empList) {
                    return ListTile(
                      onTap: () {
                        this._typeAheadController.text = empList['emp_name'];
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
                      title: Text(
                          empList['emp_name'] + '  (${empList['emp_number']})'),
                    );
                  },
                  onSuggestionSelected: (empList) {},
                )),
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
                    icon: Image.asset(
                      "assets/images/cal_icon2.png",
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
                      child: Image.asset('assets/images/assignNew.png',height: 30),
                      onTap: ()async{
                        if (_selectedFromDate == 'Select  Date') {
                          Utilities.showAlert(context, "Please Select Date");
                        } else if (_selectFromTime == 'Select From Time') {
                          Utilities.showAlert(context, "Please Select From Time");
                        } else if (_selectToTym == 'Select To Time') {
                          Utilities.showAlert(context, "Please Select To Time");
                        } else if (reasonName == null) {
                          Utilities.showAlert(context, "Please Select Reason");
                        } else {
                          applyPermsion();
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Container(child: GestureDetector(
                    child: Image.asset('assets/images/cancelnew_btn.png',height: 30),
                    onTap: ()async{Navigator.pop(context);},
                  ),)
                ],
              ),
            ),
          ]),
      )),
        ),
    );
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
      }); // just printed length of data
    });
  }

  makeEmployeeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('role') == "Supervisor") {
      getEmployeeList();
    } else if (prefs.getString('role') == "HOD") {
      getRoleBasedEmployeeList();
    } else {
      getAllEmployeeList();
    }
  }

  getRoleBasedEmployeeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});

    ApiService.post('getRoleBasedEmployeeList',body).then((success) {
      String data = success.body; //store response as string

      setState(() {
        empList = jsonDecode(data)['eom_list'];
      }); // just printed length of data
    });
  }

  getAllEmployeeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('employeeDetailsAll',body).then((success) {
      String data = success.body; //store response as string

      setState(() {
        empList = jsonDecode(data)['employeeDetailsAll'];
      }); // just printed length of data
    });
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
    final body = jsonEncode({
      "date": _selectedFromDate,
      "from_time": _selectFromTime,
      "to_time": _selectToTym,
      "reason": id,
      "statusId": "8",
      "submitted_by": selectedempid,
      "comment": discription.text
    });
    ApiService.post('permsnAssign',body).then((success) {
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
