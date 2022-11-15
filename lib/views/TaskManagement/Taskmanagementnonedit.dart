import 'dart:convert';
import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/views/TaskManagement/TaskManagement.dart';
import 'package:entreplan_flutter/views/TaskManagement/ViewTaskManagement.dart';
import 'package:entreplan_flutter/views/home/HomeTabs.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/Utilities.dart';

class Taskmanagementnonedit extends StatefulWidget {
  final String taskmanagement;
  final String task;
  final String taskdata;
  final String task_assignedto;
  Taskmanagementnonedit(
      {Key key,
      @required this.taskmanagement,
      @required this.task,
      @required this.taskdata,
      this.task_assignedto})
      : super(key: key);

  @override
  _TaskmanagementnoneditState createState() => _TaskmanagementnoneditState();
}

class _TaskmanagementnoneditState extends State<Taskmanagementnonedit> {
  String dropdownvalue = 'Priority';
  int id;
  bool isEditVisible = false;
  bool isCancelVisible = false;
  bool isVisibleButton = false;
  bool isVisible = false;
  String selectedemp = "Contact To";
  List empList;
  String selectedempid = "0";
  List searchResult = [];
  final TextEditingController _typeAheadController = TextEditingController();
  String title = "";
  String details = "";
  String start_date = "";
  String due_date = "";
  String priority = "";
  String priority_name = "";
  String assigned;
  String assigned_status = "";
  String assigned_to = "";
  String assigned_to_name = "";
  String assigned_by = "";
  String assigned_by_name = "";
  String assigned_on = "";
  String status = "";
  String status_name = "";
  String task_id = "";
  bool isInternetAvailable = true;

  _TaskmanagementnoneditState();

  setData(id) {
    setState(() {
      if (id == 1) {
        isVisible = true;
      } else {
        isVisible = false;
      }
    });
  }

  setEditCancelVisibility() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString("role").toString();
    String empNumber = prefs.getString("empNumber").toString();
    String empName = prefs.getString("empName").toString();
    if (role == "Supervisor" ||
        role == "Department Manager" ||
        role == "HiringManager" ||
        role == "HOD") {
      if (assigned_by == empNumber) {
        if (assigned_to_name.replaceAll(" ", "") ==
                empName.replaceAll(" ", "") ||
            assigned_to_name == "") {
          isEditVisible = true;
          isCancelVisible = true;
          isVisibleButton = true;
        } else {
          setState(() {
            isEditVisible = true;
            isCancelVisible = true;
            isVisibleButton = false;
          });
        }
      } else {
        setState(() {
          isEditVisible = false;
          isCancelVisible = false;
          isVisibleButton = true;
        });
      }
    } else {
      if (assigned_by != empNumber) {
        setState(() {
          isEditVisible = false;
          isCancelVisible = false;
          isVisibleButton = true;
        });
      } else {
        setState(() {
          isEditVisible = true;
          isCancelVisible = true;
          isVisibleButton = true;
        });
      }
    }
  }

  setStartVisibility() {
    setState(() {});
  }

  void initState() {
    super.initState();
    taskData();
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
            "Edit Task",
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
          child: SingleChildScrollView(
              child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 16),
            child: Column(
              children: [
                Card(
                  color: Color(0xfff1f3f6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child: Column(
                    children: [
                      Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 30, 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: Text("Title               :",
                                      style: TextStyle(
                                        fontFamily: 'Myriad',
                                      )),
                                ),
                                flex: 1,
                              ),
                              Expanded(
                                child: Container(
                                    child: Text(
                                      '$title',
                                      style: TextStyle(
                                        fontFamily: 'Myriad',
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.clip,
                                    ),
                                    alignment: Alignment.centerLeft),
                                flex: 2,
                              ),
                            ],
                          )),
                      Divider(
                        color: Colors.black,
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 30, 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                    child: Text(
                                  "Details           :",
                                  style: TextStyle(
                                    fontFamily: 'Myriad',
                                  ),
                                )),
                                flex: 1,
                              ),
                              Expanded(
                                child: Container(
                                    child: Text(
                                      '$details',
                                      style: TextStyle(
                                        fontFamily: 'Myriad',
                                      ),
                                      maxLines: null,
                                      softWrap: true,
                                      overflow: TextOverflow.fade,
                                    ),
                                    alignment: Alignment.centerLeft),
                                flex: 2,
                              ),
                            ],
                          )),
                      Divider(
                        color: Colors.black,
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 30, 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                    child: Text(
                                  "Start Date      :",
                                  style: TextStyle(
                                    fontFamily: 'Myriad',
                                  ),
                                )),
                                flex: 1,
                              ),
                              Expanded(
                                child: Container(
                                    child: Text('$start_date',
                                        style: TextStyle(
                                          fontFamily: 'Myriad',
                                        )),
                                    alignment: Alignment.centerLeft),
                                flex: 2,
                              ),
                            ],
                          )),
                      Divider(
                        color: Colors.black,
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 30, 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                    child: Text(
                                  "Due Date        :",
                                  style: TextStyle(
                                    fontFamily: 'Myriad',
                                  ),
                                )),
                                flex: 1,
                              ),
                              Expanded(
                                child: Container(
                                    child: Text('$due_date',
                                        style: TextStyle(
                                          fontFamily: 'Myriad',
                                        )),
                                    alignment: Alignment.centerLeft),
                                flex: 2,
                              ),
                            ],
                          )),
                      Divider(
                        color: Colors.black,
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 30, 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                    child: Text(
                                  "Priority           :",
                                  style: TextStyle(
                                    fontFamily: 'Myriad',
                                  ),
                                )),
                                flex: 1,
                              ),
                              Expanded(
                                child: Container(
                                    child: Text('$priority_name',
                                        style: TextStyle(
                                          fontFamily: 'Myriad',
                                        )),
                                    alignment: Alignment.centerLeft),
                                flex: 2,
                              ),
                            ],
                          )),
                      Divider(
                        color: Colors.black,
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 30, 10),
                          child: Column(children: [
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                      child: Text(
                                    "Assign type   :",
                                    style: TextStyle(
                                      fontFamily: 'Myriad',
                                    ),
                                  )),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Container(
                                      child: Text('$assigned_status',
                                          style: TextStyle(
                                            fontFamily: 'Myriad',
                                          )),
                                      alignment: Alignment.centerLeft),
                                  flex: 2,
                                ),
                              ],
                            ),
                          ])),
                      Divider(
                        color: Colors.black,
                      ),
                      Visibility(
                          visible: isVisible,
                          child: (Container(
                              margin: EdgeInsets.fromLTRB(20, 10, 30, 10),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child:
                                        Container(child: Text("Assigned To :")),
                                    flex: 1,
                                  ),
                                  Expanded(
                                    child: Container(
                                        child: Text('$assigned_to_name',
                                            style: TextStyle(
                                              fontFamily: 'Myriad',
                                            )),
                                        alignment: Alignment.centerLeft),
                                    flex: 2,
                                  ),
                                ],
                              )))),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: isEditVisible,
                                child: Container(
                                  child: GestureDetector(
                                    child: Image.asset(
                                      'assets/images/editnew.png',
                                      height: 30,
                                    ),
                                    onTap: () async {
                                      setState(() {
                                        if (assigned_status == "To Employee") {
                                          setState(() {
                                            assigned = "1";
                                          });
                                        } else {
                                          setState(() {
                                            assigned = "0";
                                          });
                                        }
                                      });
                                      final body = jsonEncode({
                                        "task_title": title,
                                        "task_id": task_id,
                                        "start_date": start_date,
                                        "due_date": due_date,
                                        "task_details": details,
                                        "task_priority": priority_name,
                                        "task_type": assigned,
                                        "assigned_to": assigned_to_name,
                                        "type": "edit"
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TaskManagement(
                                                    taskdata: body,
                                                  )));
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Visibility(
                                visible: isCancelVisible,
                                child: Container(
                                  child: GestureDetector(
                                    child: Image.asset(
                                      "assets/images/cancelnew_btn.png",
                                      height: 30,
                                    ),
                                    onTap: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewTaskManagement()));
                                    },
                                  ),
                                ),
                              )
                            ],
                          )),
                      SizedBox(
                        height: 25,
                      ),
                      Visibility(
                        visible: isVisibleButton,
                        child: Container(
                          child: GestureDetector(
                              onTap: () async {
                                if (status_name == 'New') {
                                  setState(() {
                                    status = '1';
                                  });
                                }
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                final body = jsonEncode({
                                  "user_id": prefs.getString('userId'),
                                  "task_id": widget.taskmanagement,
                                  "status_id": status
                                });

                                ApiService.post('startTaskPrograss',body)
                                    .then((success) {
//store response as string
                                  final snackBar = SnackBar(
                                    content: Text('Task Started'),
                                    action: SnackBarAction(
                                      label: 'ok',
                                      onPressed: () {
                                      },
                                    ),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HomeTabs()));
                                });
                              },
                              child: Image.asset(
                                'assets/images/startnew.png',
                                height: 30,
                              )
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          )),
        ));
  }

  taskData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({
      "user_id": prefs.getString('userId'),
      "task_id": widget.taskmanagement,
      "status_id": widget.task
    });
    ApiService.post('taskData',body).then((success) {
      String data = success.body; //store response as string
      //store response as string
      Map results = json.decode(data)['task_data'];
      setState(() {
        task_id = results['id'];
        title = results['title'];
        details = results['details'];
        start_date = results['start_date'];
        due_date = results['due_date'];
        priority_name = results['priority_name'];
        assigned_status = results['assigned_status'];
        assigned = results['assigned'];
        if (assigned_status == "To Employee") {
          isVisible = true;
          assigned_to_name = results['assigned_to_name'];
        } else {
          assigned_to_name = results['assigned_to_name'];
        }
        status = results['status'];
        status_name = results['status_name'];
        assigned_on = results['assigned_on'];
        assigned_by = results['assigned_by'];
        assigned_by_name = results['assigned_by_name'];
        setEditCancelVisibility();
        setStartVisibility();
      });
    });
  }
}
