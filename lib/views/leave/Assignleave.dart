import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:entreplan_flutter/views/home/ListViewHome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/HomeTabs.dart';

class Assignleave extends StatefulWidget {
  const Assignleave({Key key}) : super(key: key);

  @override
  _AssignleaveState createState() => _AssignleaveState();
}

class _AssignleaveState extends State<Assignleave> {
  String _selectedFromDate = 'From Date';
  List meetinglist_room = [];
  var discription = TextEditingController();
  String leave = "";
  String roleName = "";
  String leaveTypeid = " ";
  String slotTime;
  String _meetingroom;

  List leavelist;
  List empList;
  String leaveBalanace = "";
  String selectedemp = " ";
  String selectedempid = "0";
  List searchResult = [];
  String dropdownvalue = 'Leave Type';
  var items = ['Leave Type', 'Casual', 'Sick', 'Vacational'];
  final TextEditingController _typeAheadController = TextEditingController();
  DateTime fromdate;
  String _selectedToDate = ' Select To  Date';
  var body;
  bool isDuration = false;
  bool isDurationCard = false;
  List dayDurationType = [];
  List durationType = [
    {"id": "1", "name": "Morning"},
    {"id": "2", "name": "Afternoon"}
  ];
  String durationTypeValue;
  String durationTypeValueId = "0";
  String dayDurationTypeValue;
  String dayDurationTypeId = "";
  bool isInternetAvailable = true;

  void initState() {
    super.initState();
    _leavetype(context);
    leavetype("");
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
            "Assign Leave",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Myriad',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body:  SingleChildScrollView(
          physics: ScrollPhysics(),
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
              child: Container(
                margin: EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                    AssetImage("assets/images/applyleave_card.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                        margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                        color: Colors.white,
                        child: TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: _typeAheadController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 15),
                                border: OutlineInputBorder(),
                                hintText: " Employee Name",
                                hintStyle: TextStyle(
                                  fontFamily: 'Myriad',
                                )),
                          ),
                          suggestionsCallback: (pattern) async {
                            return getfilteredLIst(pattern, empList);
                          },
                          itemBuilder: (
                              context,
                              empList,
                              ) {
                            return ListTile(
                              onTap: () {
                                this._typeAheadController.text =
                                empList['emp_name'];
                                setState(() {
                                  selectedempid = empList['emp_number'];
                                  selectedemp = empList['emp_name'];
                                });

                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              },
                              leading: empList['emp_name'] == null ? Container() : Icon(
                                Icons.person_add,
                                color: Colors.black,
                                size: 20.0,
                              ),
                              title: empList['emp_name'] == null ? Text('No Users Found',style: TextStyle(color: Colors.black),) :  Text(empList['emp_name']+
                                  '  (${empList['emp_number'] == null ? '' : empList['emp_number']})'),
                            );
                          },
                          onSuggestionSelected: (empList) {},
                        )),
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
                                fontFamily: 'Myriad',
                                color: Colors.black,),
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
                                fontFamily: 'Myriad',
                                color: Color(0xFF000000))),
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
                                  fontFamily: 'Myriad',
                                  color: Color(0xFF000000))),
                        )),
                    Card(
                        margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                        child: ListTile(
                          onTap: () {
                            _selectDate(context);
                          },
                          trailing: IconButton(
                            icon:Image.asset(
                              "assets/images/cal_icon2.png",
                            ),
                            onPressed: () {
                              _selectDate(context);
                            },
                          ),
                          title: Text(_selectedToDate,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontFamily: 'Myriad',
                                  color: Color(0xFF000000))),
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
                          hintStyle: TextStyle(
                              fontFamily: 'Myriad', color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(20.0)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: GestureDetector(
                              child: Image.asset('assets/images/assignNew.png',height: 30),
                              onTap: ()async{
                                if (_selectedFromDate ==
                                    ' Select From  Date') {
                                  Utilities.showAlert(context,
                                      "Please Select From  Date");
                                } else if (_selectedToDate ==
                                    ' Select To  Date') {
                                  Utilities.showAlert(context,
                                      "Please Select To  Date");
                                } else if (leaveTypeid == ' ') {
                                  Utilities.showAlert(context,
                                      "Please Select To  Leave Type");
                                } else {
                                  assignLeave();
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Container(
                            child: GestureDetector(
                              child: Image.asset('assets/images/cancelnew_btn.png',height: 30),
                              onTap: (){
                                Navigator.pop(context);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ),
          ),
        ));
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
        if (empList.isEmpty) {

        }
      }); // just printed length of data
    });
  }

  makeEmployeeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('role') == "HiringManager") {
      getAllEmployeeList();
    } else {
      getEmployeeList();
    }
  }

  getAllEmployeeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});

    ApiService.post('employeeDetailsAll',body).then((success) {
      String data = success.body; //store response as string

      setState(() {
        empList = jsonDecode(data)['employeeDetailsAll'];
        if (empList.length < 0) {}
      }); // just printed length of data
    });
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
            label: 'Ok',
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

  Future<void> _leavetype(BuildContext context) async {
    ApiService.post('leaveType',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        empList = jsonDecode(data)['employeeDetailsAll'];
        if (leavelist.length < 0) {}
      }); // just printed length of data
    });
  }

  loadJson(leavebalance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({
      "user_id": int.parse(prefs.getString('userId')),
      "emp_number": int.parse(selectedempid),
      "leaveType": leavebalance
    });

    ApiService.post("leaveCount",body,).then((success) {
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

  assignLeave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({
      "user_id": int.parse(prefs.getString('userId')),
      "emp_number": selectedempid,
      "leave_type_id": leaveTypeid,
      "from_date": _selectedFromDate,
      "to_date": _selectedToDate,
      "comments": discription.text.toString(),
      "status_id": 3,
      "start_time": "",
      "end_time": "",
      "duration": int.parse(dayDurationTypeId),
      "duration_type" : int.parse(durationTypeValueId)
    });
    print(body);
    ApiService.post('applyLeaveEmpBySupervisor',body).then((success) {
      final body = json.decode(success.body);
      setState(() {
        final snackBar = SnackBar(
          content: Text(body['message']),
          action: SnackBarAction(
            label: 'Ok',
            textColor: Colors.white,
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        if(body['message'] == "Successfully assigned"){
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
}
