import 'dart:convert';
import 'dart:io';
import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/HomeTabs.dart';
import 'ViewTaskManagement.dart';

class TaskManagement extends StatefulWidget {
  final String taskdata;
  const TaskManagement({Key key, @required this.taskdata}) : super(key: key);

  @override
  _TaskManagementState createState() => _TaskManagementState();
}

class _TaskManagementState extends State<TaskManagement> {
  bool isVisible = false;
  bool isAssigntypeVisible = true;
  File file;
  String task_id = "";
  String sid = "-1";
  String ids = '0';
  String dropdownvalue;
  var items = ['Low', 'Medium', 'High', 'Urgent'];
  String _selectedFromDate = 'Start Date';
  String _selectedDueDate = 'Due Date';
  String _myActivity;
  String _myActivityResult;
  final formKey = new GlobalKey<FormState>();
  String fileName = "";
  String selectedemp = "Assign To";
  List empList;
  String selectedempid = "0";
  List searchResult = [];
  List empNames = [];
  String _title;
  String _jobdetails;
  String buttonNmae = "Submit";
  var title = TextEditingController();
  var jobdetails = TextEditingController();
  final TextEditingController _typeAheadController = TextEditingController();
  String titleText = "";
  String SelectAssignedToVal = "";
  DateTime fromdate;
  DateTime todate;
  String roleName;
  @override
  void initState() {
    setTaskData();
    setData(sid);
    getallemployeelist();
    setAssigntypeVisible();
    super.initState();
    _myActivity = '';
    _myActivityResult = '';
  }
  bool isInternetAvailable = true;


  _saveForm() {
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _myActivityResult = _myActivity;
      });
    }
  }

  setData(id) {
    setState(() {
      if (int.parse(id) == 1) {
        isVisible = true;
      } else {
        isVisible = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = json.decode(widget.taskdata);
    if (body['type'] == "edit") {
      setState(() {
        titleText = "Edit Task";
      });
    } else {
      setState(() {
        titleText = "Create Task";
      });
    }

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
          "$titleText",
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
        child: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(18, 50, 18, 0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/applyleave_card.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                      child: TextFormField(
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                        controller: title,
                        onChanged: ((String val) {
                          setState(() {
                            _title = val;
                          });
                        }),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            labelText: "Title",
                            labelStyle: TextStyle(
                                fontFamily: 'Myriad', color: Colors.black)),
                        textAlign: TextAlign.start,
                        validator: (val) {
                          if (val.isEmpty) {
                            return "Please enter Title";
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                      child: TextFormField(
                        style: TextStyle(
                          fontFamily: 'Myriad',
                        ),
                        minLines: 2,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        controller: jobdetails,
                        onChanged: ((String val) {
                          setState(() {
                            _jobdetails = val;
                          });
                        }),
                        decoration: InputDecoration(
                            labelText: "Details",
                            labelStyle: TextStyle(
                                fontFamily: 'Myriad', color: Colors.black),
                            hintText: 'Enter Task Details',
                            hintStyle: TextStyle(
                              fontFamily: 'Myriad',
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            )),
                      ),
                    ),
                    SizedBox(
                        child: Card(
                            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: ListTile(
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                _selectFromDate(context);
                              },
                              trailing: IconButton(
                                icon: Image.asset(
                                  "assets/images/cal_icon1.png",
                                ),
                                onPressed: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  _selectFromDate(context);
                                },
                              ),
                              title: Text(_selectedFromDate,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontFamily: 'Myriad',
                                      color: Color(0xFF000000))),
                            ))),
                    SizedBox(
                        child: Card(
                            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: ListTile(
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                _selectFromDates(context);
                              },
                              trailing: IconButton(
                                icon:
                                    Image.asset("assets/images/cal_icon2.png"),
                                onPressed: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  _selectFromDates(context);
                                },
                              ),
                              title: Text(_selectedDueDate,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontFamily: 'Myriad',
                                      color: Color(0xFF000000))),
                            ))),
                    SizedBox(
                        child: Card(
                            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: DropdownButtonFormField(
                              hint: Text('     Select Priority'),
                              style: TextStyle(
                                  fontFamily: 'Myriad',
                                  color: Colors.black,),
                              value: dropdownvalue,
                              items: items.map((String items) {
                                return DropdownMenuItem(
                                    onTap: () {},
                                    value: items,
                                    child: Text(items));
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  dropdownvalue = newValue.toString();
                                });
                              },
                            ))),
                    Visibility(
                      visible: isAssigntypeVisible,
                      child: SizedBox(
                        child: Card(
                            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: Column(children: [
                              Row(
                                children: <Widget>[
                                  Text("Assign type",
                                      style: TextStyle(fontFamily: 'Myriad')),
                                  Radio(
                                    activeColor: Colors.green,
                                    value: 0,
                                    groupValue: int.parse(sid),
                                    onChanged: (val) {
                                      setState(() {
                                        sid = "0";
                                        setData(sid);
                                      });
                                    },
                                  ),
                                  Text(
                                    'Self',
                                    style: TextStyle(fontFamily: 'Myriad'),
                                  ),
                                  Radio(
                                    activeColor: Colors.green,
                                    value: 1,
                                    groupValue: int.parse(sid),
                                    onChanged: (val) {
                                      setState(() {
                                        sid = "1";
                                        setData(sid);
                                      });
                                    },
                                  ),
                                  Text(
                                    'Employee',
                                    style: TextStyle(fontFamily: 'Myriad'),
                                  ),
                                ],
                              ),
                            ])),
                      ),
                    ),
                    Visibility(
                        visible: isVisible,
                        child: (Container(
                          padding: EdgeInsets.all(10),
                          child: TypeAheadFormField(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: this._typeAheadController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: " Contact To"),
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
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
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
                            transitionBuilder:
                                (context, suggestionsBox, controller) {
                              return suggestionsBox;
                            },
                            onSuggestionSelected: (suggestion) {
                              this._typeAheadController.text = suggestion;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please select employee';
                              }
                            },
                            onSaved: (value) {
                              this.selectedempid = value;
                            },
                          ),
                        ))),
                    Container(
                        child: Text(
                      "$fileName",
                      style: TextStyle(fontFamily: 'Myriad', ),
                    )),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildsubmit(context),
                          SizedBox(
                              width: 40,
                              ),
                          buildCancel(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    fromdate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 0)),
      lastDate: DateTime(2100),
    );
    if (fromdate != null) {
      setState(() {
        _selectedFromDate = Jiffy(fromdate).format('dd-MM-yyyy');
        _selectedDueDate = 'Due Date';
      });
    }
  }

  Future<void> _selectFromDates(BuildContext context) async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 0)),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      var now = date;
      var berlinWallFellDate = fromdate;
      if (berlinWallFellDate.compareTo(now) > 0) {
        setState(() {
          _selectedDueDate = 'Due Date';
        });
        final snackBar = SnackBar(
          content: Text('To date should be greater than From date'),
          action: SnackBarAction(
            label: 'ok',
            onPressed: () {
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        //peform logic here.....
      } else {
        setState(() {
          _selectedDueDate = Jiffy(date).format('dd-MM-yyyy');
        });
      }
    }
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;
    final path = result.files.single.path;
    file = File(path);
    var files = file.path.toString();
    var fileNa = files.split('/');
    setState(() {
      fileName = fileNa[fileNa.length - 1];
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

    ApiService.post('employeeDetailsByRoleAll',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        empList = jsonDecode(data)['employeeDetailsAll'];
        for (int i = 0; i < empList.length; i++) {
          empNames.add(empList[i]['emp_name'].replaceAll(' ', ''));
          if (empList[i]['emp_name'].replaceAll(' ', '') ==
              (SelectAssignedToVal.replaceAll(' ', ''))) {
            selectedempid = empList[i]['emp_number'];
          }
        }
      }); // just printed length of data
    });
  }

  @override
  Widget buildsubmit(BuildContext context) {
    if (dropdownvalue == "Low") {
      ids = '1';
    } else if (dropdownvalue == "Medium") {
      ids = '2';
    } else if (dropdownvalue == "High") {
      ids = '3';
    } else if (dropdownvalue == "Urgent") {
      ids = '4';
    }

    return Container(
      child: GestureDetector(
        onTap: () async {
          if ((title.text == null) || (title.text.replaceAll(" ", "") == "")) {
            Utilities.showAlert(context, "Please Enter Title");
          } else if ((_selectedFromDate == 'Start Date')) {
            Utilities.showAlert(context, "Please Select Start Date");
          } else if ((_selectedDueDate == 'Due Date')) {
            Utilities.showAlert(context, "Please Select Due Date");
          } else if ((dropdownvalue == null)) {
            Utilities.showAlert(context, "Please Select Priority");
          } else if ((roleName == "Supervisor" ||
                  roleName == "DepartmentManager" ||
                  roleName == "HiringManager" ||
                  roleName == "HOD") &&
              sid == "-1") {
            Utilities.showAlert(context, "Please select Assign Type");
          } else if (sid == "-1") {
            sid = "0";
            selectedempid = "";
          } else if (sid == "1" &&
              (_typeAheadController.text == "" ||
                  selectedemp == null ||
                  selectedemp == "")) {
            Utilities.showAlert(context, "Please Select Employee");
          }
          else {
            if (buttonNmae == "Submit") {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              final body = jsonEncode({
                "user_id": int.parse(prefs.getString('userId')),
                "task_title": title.text.toString(),
                "start_date": _selectedFromDate,
                "due_date": _selectedDueDate,
                "task_details": jobdetails.text.toString(),
                "task_priority": ids,
                "task_type": sid,
                "assigned_to": selectedempid,
              });
              ApiService.post('createTask',body).then((value) async {
                final body = json.decode(value.body);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeTabs(),
                  ),
                  (route) => false,
                );
                final snackBar = SnackBar(
                  content: Text('Task Created'),
                  action: SnackBarAction(
                    label: 'ok',
                    onPressed: () {
                    },
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              });
            } else {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              final body = jsonEncode({
                "user_id": int.parse(prefs.getString('userId')),
                "task_id": int.parse(task_id),
                "task_title": title.text.toString(),
                "start_date": _selectedFromDate,
                "due_date": _selectedDueDate,
                "task_details": jobdetails.text.toString(),
                "task_priority": ids,
                "task_type": sid,
                "assigned_to": selectedempid,
              });
              ApiService.post('editTask',body).then((value) {
                final body = json.decode(value.body);
                final snackBar = SnackBar(
                  content: Text('Task details Saved'),
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
              });
            }
          }
        },

          child: Image.asset('assets/images/submitnew_btn.png',height: 30),
      ),
    );
  }

  @override
  Widget buildCancel(BuildContext context) {
    return Container(
      child: GestureDetector(
        child: Image.asset('assets/images/cancelnew_btn.png',height: 30),
        onTap:  () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ViewTaskManagement()));
        },
      ),
    );
  }

  setTaskData() {
    final body = json.decode(widget.taskdata);
    if (body['type'] == "edit") {
      setState(() {
        title.text = body['task_title'].toString();
        _title = body['task_title'].toString();
        jobdetails.text = body['task_details'].toString();
        _typeAheadController.text = body['assigned_to'];
        SelectAssignedToVal = body['assigned_to'];
        dropdownvalue = body['task_priority'].toString();
        sid = body['task_type'];
        task_id = body['task_id'].toString();
        var string = body['start_date'];
        var string1 = body['due_date'];
        List split = string.split("-");
        List split1 = string1.split("-");
        fromdate = DateTime.parse(
            split[2] + '-' + split[1] + '-' + split[0] + ' 00:00:00');
        _selectedFromDate = Jiffy(fromdate).format('dd-MM-yyyy');
        todate = DateTime.parse(
            split1[2] + '-' + split1[1] + '-' + split1[0] + ' 00:00:00');
        _selectedDueDate = Jiffy(todate).format('dd-MM-yyyy');
        buttonNmae = "Save";
        setData(sid);
      });
    }
  }

  setAssigntypeVisible() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    roleName = prefs.getString("role").toString();
    if (roleName == "Supervisor" ||
        roleName == "Department Manager" ||
        roleName == "HiringManager" ||
        roleName == "HOD") {
      setState(() {
        isAssigntypeVisible = true;
      });
    } else {
      setState(() {
        isAssigntypeVisible = false;
      });
    }
  }
}
