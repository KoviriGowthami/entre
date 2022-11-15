import 'dart:async';
import 'dart:convert';
import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:entreplan_flutter/views/meetingroom/BookMeetingRoom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Employee extends StatefulWidget {
  const Employee({Key key}) : super(key: key);

  @override
  _EmployeeState createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  bool isChecked = false;
  List empList = [];
  String empName;
  List searchResult = [];
  String selectedemp = " ";
  String selectedempDept = " ";
  String selectedempid = "0";
  List selectedempList = [];
  final TextEditingController _typeAheadController = TextEditingController();
  bool loading = true;

  void startTimer() {
    Timer.periodic(const Duration(seconds: 3), (t) {
      setState(() {
        loading = false; //set loading to false
      });
      t.cancel(); //stops the timer
    });
  }

  void initState() {
    super.initState();
    getEmployeeList();
    selectedempList = [];
  }

  onSelectedRow(bool selected, emp) async {
    setState(() {
      if (selected == true) {
        selectedempList.add(emp);
      } else {
        selectedempList.remove(emp);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _typeAheadController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: " Search...",
                        suffixIcon: Icon(
                          Icons.search,
                          color: Colors.black,
                          size: 20.0,
                        ),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      return getfilteredLIst(pattern);
                    },
                    itemBuilder: (context, empList) {
                      return ListTile(
                        onTap: () {
                          this._typeAheadController.text = empList['emp_name'];
                          setState(() {
                            selectedempid = empList['emp_number'];
                            selectedemp = empList['emp_name'];
                            selectedempDept = empList['department_name'];
                          });

                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        leading: Icon(
                          Icons.person_add,
                          color: Colors.black,
                          size: 20.0,
                        ),
                        title: Text(empList['emp_name'] +
                            '  (${empList['emp_number']})'
                                '(${empList['department_name']})'),
                      );
                    },
                    onSuggestionSelected: (empList) {},
                  )),
              loading
                  ? Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    CircularProgressIndicator(
                      color: Color(0xff2d324f),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Text(
                        "Loading...wait...",
                        style: TextStyle(
                            color: Color(0xff2d324f),
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              )
                  : Padding(
                  padding: EdgeInsets.all(0),
                  child: Container(
                    child: DataTable(
                      onSelectAll: (b) {},
                      columnSpacing: 10,
                      columns: [
                        DataColumn(
                            label: Expanded(
                              child: Text(
                                'Employee Number',
                                softWrap: true,
                                overflow: TextOverflow.clip,
                              ),
                            )),
                        DataColumn(
                            label: Expanded(
                              child: Text(
                                'Employee Name',
                                softWrap: true,
                                overflow: TextOverflow.clip,
                              ),
                            )),
                        DataColumn(
                          label: Text(
                            'Department',
                          ),
                        ),
                      ],
                      rows: empList
                          .map(
                            (emp) => DataRow(
                            selected: selectedempList.contains(emp),
                            onSelectChanged: (b) {
                              onSelectedRow(b, emp);
                            },
                            cells: [
                              DataCell(
                                Text(emp['emp_number']),
                              ),
                              DataCell(
                                Text(emp['emp_name']),
                              ),
                              DataCell(
                                Text(emp['department_name']),
                              ),
                            ]),
                      )
                          .toList(),
                    ),
                  )),
            ],
          )),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: GestureDetector(
                    child: Image.asset('assets/images/savenew_btn.png',height: 30),
                    onTap: ()async{
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => BookMeetingRoom()));
                      Utilities.selectedempList = selectedempList;
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                ),
                Container(
                  child: GestureDetector(
                    child: Image.asset('assets/images/cancelnew_btn.png',height: 30),
                    onTap: ()async{
                      Navigator.pop(context);

                    }
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  getEmployeeList() async {
    startTimer();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('employeeDetailsAll',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        empList = jsonDecode(data)['employeeDetailsAll'];
        empName = jsonDecode(data)['emp_name'];
      }); // just printed length of data
    });
  }

  getfilteredLIst(pattern) {
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
}
