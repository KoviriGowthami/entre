import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/views/TaskManagement/TaskManagement.dart';
import 'package:entreplan_flutter/views/TaskManagement/TaskWorkflow.dart';
import 'package:entreplan_flutter/views/TaskManagement/Taskmanagementnonedit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/Utilities.dart';

class ViewTaskManagement extends StatefulWidget {
  const ViewTaskManagement({Key key}) : super(key: key);

  @override
  _ViewTaskManagementState createState() => _ViewTaskManagementState();
}

class _ViewTaskManagementState extends State<ViewTaskManagement> {
  bool isVisible = false;
  bool listVisible = false;
  String role;
  bool isInternetAvailable = true;

  List taskList;
  void initState() {
    super.initState();
    gettaskList();
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
            "Task List",
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
            child: Column(
              children: [
                Visibility(
                  visible: listVisible,
                  child: Container(
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: taskList == null ? 0 : taskList.length,
                        itemBuilder: (context, index) {
                          if (taskList[index]['assigned'] == "Self") {
                            return TaskManagementTile(
                                id: taskList[index]['id'],
                                title: taskList[index]['title'],
                                assigned_to: taskList[index]['assigned'],
                                priority: taskList[index]['priority_name'],
                                start_date: taskList[index]['start_date'],
                                due_date: taskList[index]['due_date'],
                                status: taskList[index]['status_name']);
                          } else {
                            return TaskManagementTile(
                                id: taskList[index]['id'],
                                title: taskList[index]['title'],
                                assigned_to: taskList[index]['assigned_to'],
                                priority: taskList[index]['priority_name'],
                                start_date: taskList[index]['start_date'],
                                due_date: taskList[index]['due_date'],
                                status: taskList[index]['status_name']);
                          }
                        }),
                  ),
                ),
                Visibility(
                  visible: isVisible,
                  child: Center(
                    heightFactor: 1.5,
                    child: Container(
                      child: Lottie.network(
                          'https://assets10.lottiefiles.com/private_files/lf30_lkquf6qz.json',fit: BoxFit.fill,),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
          margin: EdgeInsets.only(right: 40,left: 40),
          width: 300,
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
              AssetImage("assets/images/apply_btn.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: FloatingActionButton.extended(

            onPressed: () {
              final String body = jsonEncode({
                "task_title": "",
                "task_details": "",
                "start_date": "",
                "due_date": "",
                "task_priority": "",
                "members": "",
                "task_type": "",
                "assigned_to": "",
                "type": "new",
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TaskManagement(
                            taskdata: body.toString(),
                          )));
            },
            label: const Text('Create Task',style: TextStyle(
                fontFamily: 'Myriad',
                color: Colors.white),),
            icon: const Icon(Icons.add,color: Colors.white,),
            backgroundColor: Color(0xFF7d7d7d),
          ),
        ));
  }

  gettaskList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    role = prefs.getString("role").toString();
    ApiService.post('taskList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        taskList = jsonDecode(data)['tasksList'];
        if (taskList.length == 0) {
          isVisible = true;
        } else {
          listVisible = true;
        }
      });
    });
  }
}

class TaskManagementTile extends StatefulWidget {
  final String id;
  final String title;
  final String assigned_to;
  final String priority;
  final String start_date;
  final String due_date;
  final String status;
  final String task_type;

  const TaskManagementTile({
    Key key,
    this.id,
    this.title,
    this.assigned_to,
    this.priority,
    this.start_date,
    this.due_date,
    this.status,
    this.task_type,
  }) : super(key: key);

  @override
  _TaskManagementTileState createState() => _TaskManagementTileState();
}

class _TaskManagementTileState extends State<TaskManagementTile> {
  String statusName = '';
  String status_id = '';
  String assigntype = "";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.only(top: 16, right: 16, left: 16),
        child: Card(
          color: Color(0xfff1f3f6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Image.asset(
                  _setImage(),
                  height: 300,
                  alignment: Alignment.center,
                ),
                onTap: () {
                  final body = jsonEncode({
                    "title": widget.title,
                    "assigned_to": widget.assigned_to,
                    "priority": widget.priority,
                    "start_date": widget.start_date,
                    "due_date": widget.due_date,
                    "status": widget.status,
                    "type": "edit"
                  });
                  if (widget.status == 'New') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Taskmanagementnonedit(
                                  taskmanagement: widget.id,
                                  task_assignedto: widget.assigned_to,
                                  taskdata: '',
                                  task: '',
                                )));
                  } else {
                    if (widget.status == "New") {
                      setState(() {
                        status_id = '0';
                      });
                    } else if ((widget.status == 'Started')) {
                      setState(() {
                        status_id = '1';
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TaskWorkflow(taskmanagement: widget.id, task: status_id, assigned_to: widget.assigned_to)));
                    } else if (widget.status == 'work in progress') {
                      setState(() {
                        status_id = '2';
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TaskWorkflow(taskmanagement: widget.id, task: status_id, assigned_to: widget.assigned_to)));
                    } else if (widget.status == 'completed') {
                      setState(() {
                        status_id = '3';
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TaskWorkflow(taskmanagement: widget.id, task: status_id, assigned_to: widget.assigned_to)));
                    } else if (widget.status == 'closed') {
                      setState(() {
                        status_id = '4';
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TaskWorkflow(taskmanagement: widget.id, task: status_id, assigned_to: widget.assigned_to)));
                    }
                  }
                },
                title: Text(
                  "\n Job Title      :  ${widget.title}"
                  "\n\n Assigned To   : ${widget.assigned_to} "
                  " \n\n Priority         :  ${widget.priority} "
                  "\n\n Start Date     : ${widget.start_date}"
                  "\n\n Due Date       : ${widget.due_date} "
                  "\n\n Status           : ${widget.status} "
                  "\n\n",
                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Myriad', ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _setImage() {
    String statusState = widget.status;
    if (statusState == "New") {
      statusName = "New";
      return "assets/images/new.jpg";
    } else if (statusState == "closed") {
      statusName = "closed";
      return "assets/images/Closed.png";
    } else if (statusState == "Started") {
      statusName = "Started";
      return "assets/images/Started.png";
    } else if (statusState == "completed") {
      statusName = "completed";
      return "assets/images/completed.jpg";
    } else {
      statusName = "work in progress";
      return "assets/images/pending.png";
    }
  }
}
