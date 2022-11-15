import 'dart:convert';
import 'dart:io';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:entreplan_flutter/views/home/HomeTabs.dart';
import 'package:entreplan_flutter/views/home/ListViewHome.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskWorkflow extends StatefulWidget {
  final String taskmanagement;
  final String task;
  final String assigned_to;

  const TaskWorkflow(
      {Key key, @required this.taskmanagement, this.task, this.assigned_to})
      : super(key: key);

  @override
  _TaskWorkflowState createState() => _TaskWorkflowState();
}

class _TaskWorkflowState extends State<TaskWorkflow> {
  File file;
  int completed;
  String fileName = "";
  var created_by_name;
  String _compeletion = "0";
  String _notes = "";
  String statud_id = "";
  String status_name = '';
  String status = '';
  List taskWorkHistoryDataList = [];
  bool isVisible = false;
  bool buttonVisible = false;
  String assigned;
  String assigned_status = "";
  String fromViewTask;
  String fromViewAssigned;
  List percentageCompl = [];
  List Date;
  var compeletion = TextEditingController();
  var notes = TextEditingController();
  var attachment;
  bool isEnabled = true;

  enableButton() {
    setState(() {
      isEnabled = true;
    });
  }

  disableButton() async {
    setState(() {
      isEnabled = false;
    });

    if (_compeletion == "0" || _compeletion == null || _compeletion == "") {
      Utilities.showAlert(context, "Please fill %completion");
      enableButton();
    } else if (int.parse(_compeletion) <= 99) {
      statusTaskPrograss();
    } else if (_compeletion == "100") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeTabs(),
        ),
      );
      statusTaskPrograss();
      final snackBar = SnackBar(
        content: Text('Task Completed'),
        action: SnackBarAction(
          label: 'ok',
          onPressed: () {
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void initState() {
    super.initState();
    taskWorkHistoryData();
  }
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
            "TaskWorkflow",
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Visibility(
                    visible: isVisible,
                    child: Column(
                      children: [
                        Card(
                            color: Color(0xfff1f3f6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Column(
                              children: [
                                Text(
                                  "Task Attachments",
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Form(
                                    child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: compeletion,
                                        onChanged: (String val) {
                                          enableButton();
                                          if (val == "") {
                                            enableButton();
                                          } else {
                                            enableButton();
                                          }
                                          setState(() {
                                            _compeletion = val;
                                          });
                                        },
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "% Compeletion",
                                            labelStyle:
                                                TextStyle(color: Colors.black)),
                                        textAlign: TextAlign.start,
                                        validator: (input) {
                                          final isDigitsOnly =
                                              int.tryParse(input);
                                          return isDigitsOnly == null ? 'Input needs to be digits only'
                                              : null;
                                        }),
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.all(10),
                                    child: Form(
                                      child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        controller: notes,
                                        onChanged: (String val) {
                                          setState(() {
                                            _notes = val;
                                          });
                                        },
                                        maxLines: null,
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "Notes or feedback",
                                            labelStyle:
                                                TextStyle(color: Colors.black)),
                                        textAlign: TextAlign.start,
                                      ),
                                    )),
                                Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: GestureDetector(
                                              child: Image.asset('assets/images/ADDnew.png',height: 30,),
                                              onTap: isEnabled
                                                  ? () => disableButton()
                                                  : null),
                                        ),
                                        SizedBox(
                                          width: 25,
                                        ),
                                        Container(
                                          child: GestureDetector(
                                            child: Image.asset('assets/images/cancelnew_btn.png',height: 30,),
                                            onTap: () async {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          HomeTabs()));
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            )
                            )
                      ],
                    )),
                SizedBox(
                  height: 30,
                ),
                Card(
                  color: Color(0xfff1f3f6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          child: Text(
                        "Task Completion Progress",
                        textAlign: TextAlign.center,
                      )),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const <DataColumn>[
                            DataColumn(
                                label: Center(
                              child: Text(
                                '% Completion',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                            DataColumn(
                                label: Center(
                              child: Text('As on date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center),
                            )),
                            DataColumn(
                              label: Text(
                                'notes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                          rows: taskWorkHistoryDataList
                              .map(
                                (emp) => DataRow(cells: [
                                  DataCell(
                                    Text(emp['completion']),
                                  ),
                                  DataCell(
                                    Text(emp['created_on']),
                                  ),
                                  DataCell(
                                    Text(emp['notes']),
                                  ),
                                ]),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                    visible: buttonVisible,
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage(
                                "assets/images/cancel_btn.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: RaisedButton(
                            onPressed: () async {
                              status = '4';
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              final body = jsonEncode({
                                "user_id": prefs.getString('userId'),
                                "task_id": widget.taskmanagement,
                                "status_id": status
                              });
                              ApiService.post('startTaskPrograss',body).then((success) {
//store response as string
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeTabs()));
                              });
                            },
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Task Close',
                              style: TextStyle(fontFamily:'Myriad',color: Colors.white),
                            ))))
              ],
            ),
          ),
        ));
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

  statusTaskPrograss() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (percentageCompl.length > 0) {
      if (int.parse(compeletion.text) <= int.parse(percentageCompl[0])) {
        enableButton();
        Utilities.showAlert(context, "Completion Over");
      } else if (percentageCompl.contains(compeletion.text)) {
        enableButton();
        Utilities.showAlert(context, "Completion Over");
      } else {
        if (compeletion.text == '100') {
          statud_id = '3';
        } else {
          statud_id = '2';
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        final String body = jsonEncode({
          "user_id": prefs.getString('userId'),
          "task_id": widget.taskmanagement,
          "completion": compeletion.text.toString(),
          "notes": notes.text.toString(),
          "attachment": attachment.toString(),
          "status_id": statud_id,
        });
         ApiService.post('statusTaskPrograss',body).then((success) {
          String data = success.body;
          compeletion.text = "";
          notes.text = "";
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeTabs()));
          final snackBar = SnackBar(
            content: Text('Completion Added Successfully'),
            action: SnackBarAction(
              label: 'ok',
              textColor: Colors.white,
              onPressed: () {
              },
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      }
    } else {
      if (compeletion.text == '100') {
        statud_id = '3';
      } else {
        statud_id = '2';
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String body = jsonEncode({
        "user_id": prefs.getString('userId'),
        "task_id": widget.taskmanagement,
        "completion": compeletion.text.toString(),
        "notes": notes.text.toString(),
        "attachment": attachment.toString(),
        "status_id": statud_id,
      });
      ApiService.post('statusTaskPrograss',body).then((success) {
        String data = success.body;
        compeletion.text = "";
        notes.text = "";
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeTabs()));
        final snackBar = SnackBar(
          content: Text('Completion Added Successfully'),
          action: SnackBarAction(
            label: 'ok',
            textColor: Colors.white,
            onPressed: () {
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    }
  }

  setVisibility(role) {
    if (widget.assigned_to == "To Employee") {
      if (widget.task == '3') {
        setState(() {
          isVisible = false;
          buttonVisible = false;
        });
      } else if (widget.task == '4' || widget.task == '1') {
        setState(() {
          isVisible = false;
          buttonVisible = false;
        });
      }
    } else {
      if (widget.task == '4' || widget.task == '3') {
        setState(() {
          isVisible = false;
        });
      } else {
        setState(() {
          isVisible = true;
        });
      }
    }
  }

  setButtonVisibility() {
    if (widget.task == '4') {
      setState(() {
        buttonVisible = false;
      });
    }
  }

  setTaskVisibility() {
    if (widget.task != '3') {
      setState(() {
        buttonVisible = false;
      });
    }
  }

  taskWorkHistoryData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({
      "user_id": prefs.getString('userId'),
      "task_id": widget.taskmanagement
    });
    ApiService.post('taskWorkHistoryData',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        taskWorkHistoryDataList = jsonDecode(data)['task_data'];
        for (int i = 0; i < taskWorkHistoryDataList.length; i++) {
          percentageCompl.add(taskWorkHistoryDataList[i]['completion']);
        }
        completed = jsonDecode(data)['completion'];

        taskData();
      });
    });
  }

  setEditCancelVisibility() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString("role").toString();
    if (role == "Supervisor" ||
        role == "DepartmentManager" ||
        role == "HiringManager" ||
        role == "HOD") {
      if (assigned == "1") {
        if (widget.task == '3') {
          setState(() {
            isVisible = false;
            buttonVisible = true;
          });
        } else if (widget.task == '4') {
          setState(() {
            isVisible = false;
            buttonVisible = false;
          });
        } else if (widget.task == '1') {
          setState(() {
            isVisible = false;
            buttonVisible = false;
          });
        }
      } else if (assigned == "0") {
        if (widget.task == '3') {
          setState(() {
            isVisible = false;
            buttonVisible = true;
          });
        } else if (widget.task == '4') {
          setState(() {
            isVisible = false;
            buttonVisible = false;
          });
        } else if (widget.task == '1') {
          setState(() {
            isVisible = true;
            buttonVisible = false;
          });
        } else if (widget.task == '2') {
          setState(() {
            isVisible = true;
            buttonVisible = false;
          });
        }
      }
    } else {
      if (assigned == "1") {
        if (widget.task == '3') {
          setState(() {
            isVisible = false;
            buttonVisible = false;
          });
        } else if (widget.task == '4') {
          setState(() {
            isVisible = false;
            buttonVisible = false;
          });
        } else if (widget.task == '1') {
          setState(() {
            isVisible = true;
            buttonVisible = false;
          });
        } else if (widget.task == '2') {
          setState(() {
            isVisible = true;
            buttonVisible = false;
          });
        }
      } else {
        if (widget.task == '3') {
          setState(() {
            isVisible = false;
            buttonVisible = true;
          });
        } else if (widget.task == '4') {
          setState(() {
            isVisible = false;
            buttonVisible = false;
          });
        } else if (widget.task == '1') {
          setState(() {
            isVisible = true;
            buttonVisible = false;
          });
        } else if (widget.task == '2') {
          setState(() {
            isVisible = true;
            buttonVisible = false;
          });
        }
      }
    }
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
      Map results = json.decode(data)['task_data'];
      setState(() {
        assigned_status = results['assigned_status'];
        assigned = results['assigned'];
        setEditCancelVisibility();
      });
    });
  }
}
