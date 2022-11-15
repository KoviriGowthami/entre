import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:date_format/date_format.dart';
import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:entreplan_flutter/views/home/ListViewHome.dart';
import 'package:entreplan_flutter/views/meetingroom/EmployeeList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/HomeTabs.dart';

class BookMeetingRoom extends StatefulWidget {
  BookMeetingRoom();

  @override
  _BookMeetingRoomState createState() => _BookMeetingRoomState();
}

class _BookMeetingRoomState extends State<BookMeetingRoom> {
  final color = const Color(0xff2d324f);
  final white = const Color(0xffFAFCFE);
  TimeOfDay fromselectedTime = TimeOfDay(hour: 00, minute: 00);
  String _fromhour, _fromminute, _fromtime;
  bool value = false;
  List decode;
  List meetinglist_room = [];
  String _meetingroom;
  String organiserName = " ";
  String _selectedToDate = 'To Date';
  String _selectedFromDate = 'From Date';
  String _selectFromTime = ' Select From Time';
  String _selectToTime = ' Select To Time';
  String _hour, _minute, _time;
  String seating = "";
  String meetingId = "";
  List empList;
  List empName;
  var meetingTitle = TextEditingController();
  String selectedemp = "Employee details";
  String selectedempid = "0";
  List searchResult = [];
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  TextEditingController _timeController = TextEditingController();
  final TextEditingController _typeAheadController = TextEditingController();
  bool loading = false;
  DateTime from_date;
  bool isInternetAvailable = true;

  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        loading = false; //set loading to false
      });
      t.cancel(); //stops the timer
    });
  }

  void initState() {
    super.initState();
    startTimer();
    getMeetinRoomList("");
    getallemployeelist();
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
          "Book Meeting Room",
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
        child: ListView(
          shrinkWrap: true,
          children: [
            Card(
              margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
              child: TextFormField(
                controller: meetingTitle,
                onChanged: ((String title) {
                  setState(() {
                    title = title;
                  });
                }),
                decoration: InputDecoration(
                  labelText: 'Meeting Titile',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Card(
                margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: Column(
                  children: <Widget>[
                    TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _typeAheadController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '$organiserName',
                            hintStyle: TextStyle(color: Colors.black)),
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
                          title: Text(empList['emp_name'] +
                              '  (${empList['emp_number']})'),
                        );
                      },
                      onSuggestionSelected: (empList) {},
                    )
                  ],
                )),
            Card(
                margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: ListTile(
                  title: Text("Meeting"),
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
                      });
                      getMeetinRoomList(_meetingroom);
                    },
                    value: _meetingroom,
                  ),
                )),
            Card(
              margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
              child: ListTile(
                title: Text(
                    'Seating Capacity :                                 $seating ',
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Color(0xFF000000))),
              ),
            ),
            Card(
                margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: ListTile(
                  onTap: () {
                    _select_fromDate(context);
                  },
                  trailing: IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      _select_fromDate(context);
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
                    _select_toDate(context);
                  },
                  trailing: IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      _select_toDate(context);
                    },
                  ),
                  title: Text(_selectedToDate,
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Color(0xFF000000))),
                )),
            Card(
                margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: ListTile(
                  onTap: () {
                    _select_FromTime(context);
                  },
                  trailing: IconButton(
                    icon: Icon(
                      Icons.timer_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      _select_FromTime(context);
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
                    _select_ToTime(context);
                  },
                  trailing: IconButton(
                    icon: Icon(
                      Icons.timer_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      _select_ToTime(context);
                    },
                  ),
                  title: Text(_selectToTime,
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Color(0xFF000000))),
                )),
            Card(
                margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text("All Day"),
                    SizedBox(
                      width: 180,
                    ),
                    Checkbox(
                      value: this.value,
                      onChanged: (bool value) {
                        this.value = value;
                      },
                    ),
                  ],
                )),
            Container(
              margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.25,right:MediaQuery.of(context).size.width*0.3),
              child: GestureDetector(
                  child: Image.asset('assets/images/add attendeeNew.png',height: 40),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Employeelist(),
                        ));
                  }),
            ),
            Card(
              margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
              child: ListView(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.all(20.0),
                children: <Widget>[
                  Text(
                    "Attendees:",
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  for (int i = 0; i < Utilities.selectedempList.length; i++)
                    ListTile(
                      title: Text(
                        "${Utilities.selectedempList[i]['emp_name']}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  for (int j = 0; j < Utilities.selectedcustomerList.length; j++)
                    ListTile(
                      title: Text(
                        "${Utilities.selectedcustomerList[j]['customer']},",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  for (int k = 0; k < Utilities.selectedvendorList.length; k++)
                    ListTile(
                      title: Text(
                        "${Utilities.selectedvendorList[k]['vendor_name']},",
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: GestureDetector(
                      child: Image.asset('assets/images/submitnew_btn.png',height: 30),
                      onTap: ()async{
                        setState(() {
                          loading = true;
                          startTimer();
                        });
                        if (meetingTitle.text.length == 0) {
                          Utilities.showAlert(
                              context, "Please Enter Meeting Title");
                        } else if (meetingId.length == 0) {
                          Utilities.showAlert(context, "Please Select Meeting");
                        } else if (_selectedFromDate == 'From Date') {
                          Utilities.showAlert(
                              context, "Please Select From Date");
                        } else if (_selectedToDate == 'To Date') {
                          Utilities.showAlert(context, "Please Select To Date");
                        } else if (_selectFromTime == ' Select From Time') {
                          Utilities.showAlert(
                              context, "Please Select From Time");
                        } else if (_selectToTime == ' Select To Time') {
                          Utilities.showAlert(context, "Please Select To Time");
                        } else {
                          submit();
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Container(child: GestureDetector(
                    child: Image.asset('assets/images/cancelnew_btn.png',height: 30),
                    onTap: ()async{
                      Navigator.pop(context);
                    },
                  ),)
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  submit() async {
    List tempEmp = [];
    List tempCust = [];
    List tempVend = [];
    for (int i = 0; i < Utilities.selectedempList.length; i++) {
      tempEmp.add(Utilities.selectedempList[i]['emp_number']);
    }
    for (int k = 0; k < Utilities.selectedvendorList.length; k++) {
      tempCust.add(Utilities.selectedvendorList[k]['id']);
    }
    for (int j = 0; j < Utilities.selectedcustomerList.length; j++) {
      tempVend.add(Utilities.selectedcustomerList[j]['contactId']);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({
      "user_id": int.parse(prefs.getString('userId')),
      "meeting_room_title": meetingTitle.text.toString(),
      "organiser": selectedempid,
      "from_date": _selectedFromDate,
      "to_date": _selectedToDate,
      "meeting_room_id": meetingId,
      "status_id": 1,
      "from_time": _selectFromTime,
      "to_time": _selectToTime,
      "all_day": 0,
      "employee_ids": tempEmp.join(","),
      "vendor_ids": tempCust.join(","),
      "customer_ids": tempVend.join(","),
    });
    ApiService.post('bookMeetingRoom',body).then((success) {
      final body = json.decode(success.body);
      setState(() {
        final snackBar = SnackBar(
          content: Text('Submitted Successfully'),
          action: SnackBarAction(
            label: 'ok',
            textColor: Colors.white,
            onPressed: () {
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeTabs(),
          ),
          (route) => false,
        );
      }
          );
    });
  }

  Future<void> _select_toDate(BuildContext context) async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 60)),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      var now = date;
      var berlinWallFellDate = from_date;
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
      } else {
        setState(() {
          _selectedToDate = Jiffy(date).format('dd-MM-yyyy');
        });
      } //if the user has selected a date

    }
  }

  Future<void> _select_fromDate(BuildContext context) async {
    from_date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 60)),
      lastDate: DateTime(2100),
    );
    if (from_date != null) //if the user has selected a date
      setState(() {
        _selectedFromDate = Jiffy(from_date).format('dd-MM-yyyy');
        _selectedToDate = ' Select To  Date';
      });
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

  getallemployeelist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});

    ApiService.post('employeeDetailsAll',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        empList = jsonDecode(data)['employeeDetailsAll'];
        if (empList.length < 0) {}
      }); // just printed length of data
      //}); // just printed length of data
    });
  }

  Future<Null> _select_FromTime(BuildContext context) async {
    if (_selectedFromDate == "Select  Date") {
      final snackBar = SnackBar(
        content: Text('Please Select Date'),
        action: SnackBarAction(
          label: 'ok',
          onPressed: () {
            // Some code to undo the change.
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

  Future<Null> _select_ToTime(BuildContext context) async {
    if (_selectToTime == "Select From Time") {
      final snackBar = SnackBar(
        content: Text('Please Select From Time'),
        action: SnackBarAction(
          label: 'ok',
          onPressed: () {
            // Some code to undo the change.
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
            _selectToTime = "Select To Time";
            final snackBar = SnackBar(
              content: Text('To time should be greater than From Time'),
              action: SnackBarAction(
                label: 'ok',
                textColor: Colors.white,
                onPressed: () {},
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            _selectToTime = _time;
            _timeController.text = formatDate(
                DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
                [hh, ':', nn, " ", am]).toString();
          }
        });
    }
  }

  getMeetinRoomList(_meetingroom) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('meetingRoomsList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        organiserName = prefs.getString('empName');
        meetinglist_room = jsonDecode(data)['meeting_rooms_list'];
        for (int i = 0; i < meetinglist_room.length; i++) {
          if (meetinglist_room[i]['name'] == _meetingroom) {
            seating = meetinglist_room[i]['seating'];
            meetingId = meetinglist_room[i]['id'];
          }
        }
      }); // just printed
    });
  }
}
