import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class EmpRecords extends StatefulWidget {
  const EmpRecords({Key key}) : super(key: key);

  @override
  State<EmpRecords> createState() => _EmpRecordsState();
}

class _EmpRecordsState extends State<EmpRecords> {
  DateTime fromdate;
  final TextEditingController _typeAheadController = TextEditingController();
  String selectedemp = " ";
  String selectedempid = "0";
  List empList;
  List searchResult = [];
  String _selectedFromDate = 'From Date';
  String _selectedToDate = 'To Date';
  bool isInternetAvailable = true;
  List officeWorkingHours = [];
  List empBreaksInOffice = [];
  List hoursInOffice = [];
  List breaksInOffice = [];
  var timeDiff;
  String durationInOffice = '';
  int totalHours = 0;
  int totalMinutes = 0;
  int totalSecs = 0;
  int totalBreakHours = 0;
  int totalBreakMinutes = 0;
  int totalBreakSecs = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEmployeeList();
  }

  @override
  Widget build(BuildContext context) {
    if (Utilities.dataState == "Connection lost") {
      setState(() {
        isInternetAvailable = true;
      });
    } else {
      setState(() {
        isInternetAvailable = false;
      });
    }
    return isInternetAvailable
        ? Scaffold(
            body: Center(
                heightFactor: 1,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                  child: // Load a Lottie file from your assets
                      Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          child: Lottie.asset('assets/json/nointernet.json',
                              fit: BoxFit.contain, height: 200, width: 200)),
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
                )),
          )
        : Scaffold(
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
                "View Attendance Record",
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                          margin: EdgeInsets.all(10),
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
                                leading: empList['emp_name'] == null
                                    ? Container()
                                    : Icon(
                                        Icons.person_add,
                                        color: Colors.black,
                                        size: 20.0,
                                      ),
                                title: empList['emp_name'] == null
                                    ? Text(
                                        'No Users Found',
                                        style: TextStyle(color: Colors.black),
                                      )
                                    : Text(empList['emp_name']),
                              );
                            },
                            onSuggestionSelected: (empList) {},
                          )),
                      Card(
                          margin: EdgeInsets.all(10),
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
                                  color: Color(0xFF000000),
                                  fontFamily: 'Myriad',
                                )),
                          )),
                      Card(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            onTap: () {
                              _selectDate(context);
                            },
                            trailing: IconButton(
                              icon: Image.asset(
                                "assets/images/cal_icon2.png",
                              ),
                              onPressed: () {
                                _selectDate(context);
                              },
                            ),
                            title: Text(_selectedToDate,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontFamily: 'Myriad',
                                )),
                          )),
                      Padding(padding: EdgeInsets.all(10),
                      child: Container(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: (){
                            if(_typeAheadController.text.isEmpty){
                              Utilities.showAlert(context, 'Select Employee');
                            }else if(_selectedFromDate == 'From Date'){
                              Utilities.showAlert(context, 'Select From Date');
                            }else if(_selectedToDate == 'To Date'){
                              Utilities.showAlert(context, 'Select From Date');
                            }else{
                              getOfficehoursDetails();
                            }
                          },
                          child: Text('View',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Myriad',
                              )),
                        ),
                      ),),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "In Office",
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF1b421a),
                              fontFamily: 'Myriad',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Color(0xFF1b421a)),
                          columns: const <DataColumn>[
                            DataColumn(
                              label: Text(
                                'Punch In',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'Myriad',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Punch Out',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Myriad',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Duration',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Myriad',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            officeWorkingHours.length,
                            (int index) => DataRow(
                              color: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                // All rows will have the same selected color.
                                if (states.contains(MaterialState.selected)) {
                                  return Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.08);
                                }
                                // Even rows will have a grey color.
                                if (index.isEven) {
                                  return Colors.grey.withOpacity(0.3);
                                }
                                return null; // Use default value for other states and odd rows.
                              }),
                              cells: <DataCell>[
                                DataCell(Text(
                                  officeWorkingHours[index]["punchin"]
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Myriad',
                                  ),
                                )),
                                DataCell(Text(
                                  officeWorkingHours[index]["punchout"]
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Myriad',
                                  ),
                                )),
                                DataCell(Text(
                                  officeWorkingHours[index]["duration"]
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Myriad',
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        child: Card(
                            color: Color(0xFF555657),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(
                                    "Total",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontFamily: 'Myriad',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Text(
                                    (totalHours < 10
                                            ? "0" + totalHours.toString()
                                            : totalHours.toString()) +
                                        ":" +
                                        (totalMinutes < 10
                                            ? "0" + totalMinutes.toString()
                                            : totalMinutes.toString()) +
                                        ":" +
                                        (totalSecs < 10
                                            ? "0" + totalSecs.toString()
                                            : totalSecs.toString()),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Myriad',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Breaks",
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF1b421a),
                              fontFamily: 'Myriad',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Color(0xFF1b421a)),
                          columns: const <DataColumn>[
                            DataColumn(
                              label: Text(
                                'Punch out',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Myriad',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Punch in',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Myriad',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Duration',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Myriad',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            empBreaksInOffice.length,
                            (int index) => DataRow(
                              color: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                // All rows will have the same selected color.
                                if (states.contains(MaterialState.selected)) {
                                  return Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.08);
                                }
                                // Even rows will have a grey color.
                                if (index.isEven) {
                                  return Colors.grey.withOpacity(0.3);
                                }
                                return null; // Use default value for other states and odd rows.
                              }),
                              cells: <DataCell>[
                                DataCell(Text(
                                  empBreaksInOffice[index]["punchout"]
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Myriad',
                                  ),
                                )),
                                DataCell(Text(
                                  empBreaksInOffice[index]["punchin"]
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Myriad',
                                  ),
                                )),
                                DataCell(Text(
                                  empBreaksInOffice[index]["duration"]
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Myriad',
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        child: Card(
                            color: Color(0xFF555657),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(
                                    "Total",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontFamily: 'Myriad',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Text(
                                    (totalBreakHours < 10
                                            ? "0" + totalBreakHours.toString()
                                            : totalBreakHours.toString()) +
                                        ":" +
                                        (totalBreakMinutes < 10
                                            ? "0" + totalBreakMinutes.toString()
                                            : totalBreakMinutes.toString()) +
                                        ":" +
                                        (totalBreakSecs < 10
                                            ? "0" + totalBreakSecs.toString()
                                            : totalBreakSecs.toString()),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Myriad',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                )));
  }

  getOfficehoursDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode(
        {"empNumber": selectedempid, "frmdate": _selectedFromDate, "todate": _selectedToDate});
    // final body = jsonEncode({"empNumber": prefs.getString('empNumber'),"date":'2022-08-10'});
    ApiService.post('lginEmpHrsinOfc', body).then((success) {
      var body = jsonDecode(success.body);
      print(body['empHrsList']);
      getTimeDiff(body['empHrsList']);
      getBreakTimes(body['empHrsList']);
    });
  }

  getTimeDiff(empHrsList) {
    totalHours = 0;
    totalMinutes = 0;
    totalSecs = 0;
    // print("EMPL LIST SIZE "+empHrsList.length.toString());
    hoursInOffice = [];
    for (int i = 0; i < empHrsList.length; i++) {
      var punchInDateTime =
          new DateFormat("yyyy-MM-dd HH:mm:ss").parse(empHrsList[i]['punchin']);
      var punchOutDateTime;
      if (empHrsList[i]['punchout'] != null) {
        punchOutDateTime = new DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(empHrsList[i]['punchout']);
        var formatter = new DateFormat('kk:mm:ss');
        var formattedDate = formatter.format(punchInDateTime);
        var formattedDate1 = formatter.format(punchOutDateTime);
        var punchIn = formatter.parse(formattedDate);
        var punchOut = formatter.parse(formattedDate1);
        timeDiff = punchOut.difference(punchIn);
        // print(timeDiff);
        var formatter1 = new DateFormat('HH:mm:ss');
        var formattedDate2 = formatter1.parse(timeDiff.toString());
        String time = DateFormat('HH:mm:ss').format(formattedDate2);
        // print(time);
        var timeHours = time.split(':');
        // print(timeHours[0]+" -- "+timeHours[1]+" ----"+timeHours[2]);
        setState(() {
          totalHours += int.parse(timeHours[0]);
          totalMinutes += int.parse(timeHours[1]);
          totalSecs += int.parse(timeHours[2]);

          if (totalSecs > 60) {
            totalMinutes += 1;
            totalSecs -= 60;
          }
          if (totalMinutes > 60) {
            totalHours += 1;
            totalMinutes -= 60;
          }
          hoursInOffice.add(jsonEncode({
            "punchin": empHrsList[i]['punchin'],
            "punchout": empHrsList[i]['punchout'],
            "duration": time.toString()
          }));
        });
        // print(timeDiff);
        // print("<><<>>>>>>><@@@@@@sarma@@@@@@@@>>>>>>>>>>>>>>>>>>>");
      } else {
        totalHours = 00;
        totalMinutes = 00;
        totalSecs = 00;
        setState(() {
          hoursInOffice.add(jsonEncode({
            "punchin": empHrsList[i]['punchin'],
            "punchout": "",
            "duration": "00:00:00"
          }));
        });
      }
    }

    setState(() {
      var body = jsonDecode(hoursInOffice.toString());
      officeWorkingHours = body;
    });
    for (int i = 0; i < officeWorkingHours.length; i++) {
      print(officeWorkingHours[i]);
      print(officeWorkingHours[i]["punchin"].toString());
      print(officeWorkingHours[i]["punchout"].toString());
      print(officeWorkingHours[i]["duration"].toString());
    }
    print("Time   #######@@@@@@######" +
        totalHours.toString() +
        "  hr " +
        totalMinutes.toString() +
        " mins  " +
        totalSecs.toString() +
        " secs");
  }

  getBreakTimes(empHrsList) {
    totalBreakHours = 0;
    totalBreakMinutes = 0;
    totalBreakSecs = 0;
    breaksInOffice = [];
    for (int i = 1; i < empHrsList.length; i++) {

      if (empHrsList[i - 1]['punchout'] != null) {
        var punchInDateTime = new DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(empHrsList[i - 1]['punchout']);
        String outformattedDate = DateFormat('yyyy-MM-dd').format(punchInDateTime);
       /* print(formattedDate);
        print("@############@@@@@@@@@@@%%%%%%%%^^^^^^^^^^");*/
        // print(punchInDateTime);
        var punchOutDateTime;
        if (empHrsList[i]['punchin'] != null) {
          punchOutDateTime = new DateFormat("yyyy-MM-dd HH:mm:ss")
              .parse(empHrsList[i]['punchin']);
          String informattedDate = DateFormat('yyyy-MM-dd').format(punchInDateTime);

          print(outformattedDate);
          print(informattedDate);
          print("<<<<<<<<<<<<<<<<<<<<<<<<=========================>>>>>>>>>>>>>>>>>>>>%^^^^^^^^^^");

          if(outformattedDate == informattedDate){
           print("ifddsfds");
           try {
             print("Entered date comaprison");
             print("@############@@@@@@@@@@@%%%%%%%%^^^^^^^^^^");
             var formatter = new DateFormat('kk:mm:ss');
             var formattedDate = formatter.format(punchInDateTime);
             var formattedDate1 = formatter.format(punchOutDateTime);
             var punchIn = formatter.parse(formattedDate);
             var punchOut = formatter.parse(formattedDate1);
             timeDiff = punchOut.difference(punchIn);
             print(timeDiff);
             var formatter1 = new DateFormat('HH:mm:ss');
             var formattedDate2 = formatter1.parse(timeDiff.toString());
             String time = DateFormat('HH:mm:ss').format(formattedDate2);
             print(time);
             var timeHours = time.split(':');
             print(
                 timeHours[0] + " -- " + timeHours[1] + " ----" + timeHours[2]);
             setState(() {
               totalBreakHours += int.parse(timeHours[0]);
               totalBreakMinutes += int.parse(timeHours[1]);
               totalBreakSecs += int.parse(timeHours[2]);

               if (totalBreakSecs > 60) {
                 totalBreakMinutes += 1;
                 totalBreakSecs -= 60;
               }
               if (totalBreakMinutes > 60) {
                 totalBreakHours += 1;
                 totalBreakMinutes -= 60;
               }

               print("punchout ---" +
                   empHrsList[i - 1]['punchout'] +
                   "    punchin  -----" +
                   empHrsList[i]['punchin'] +
                   "    duration ----  " +
                   time.toString());
               breaksInOffice.add(jsonEncode({
                 "punchout": empHrsList[i - 1]['punchout'],
                 "punchin": empHrsList[i]['punchin'],
                 "duration": time.toString()
               }));
             });
             // print(timeDiff);
             // print("<><<>>>>>>><@@@@@@sarma@@@@@@@@>>>>>>>>>>>>>>>>>>>");
           }catch(e){
             print(e.toString());
             setState(() {
               breaksInOffice.add(jsonEncode({
                 "punchout": (empHrsList[i-1]['punchout'] == null
                     ? ""
                     : empHrsList[i-1]['punchout']),
                 "punchin": "",
                 "duration": "00:00:00"
               }));
             });
           }
          }else{
            print("else sdsdsds");
            setState(() {
              breaksInOffice.add(jsonEncode({
                "punchout": (empHrsList[i-1]['punchout'] == null
                    ? ""
                    : empHrsList[i-1]['punchout']),
                "punchin": "",
                "duration": "00:00:00"
              }));
            });
          }


        } else {
          totalBreakHours = 00;
          totalBreakMinutes = 00;
          totalBreakSecs = 00;
        }
      }
    }
    setState(() {
      breaksInOffice.add(jsonEncode({
        "punchout": (empHrsList[empHrsList.length - 1]['punchout'] == null
            ? ""
            : empHrsList[empHrsList.length - 1]['punchout']),
        "punchin": "",
        "duration": "00:00:00"
      }));

      var body = jsonDecode(breaksInOffice.toString());
      empBreaksInOffice = body;
    });
    for (int i = 0; i < empBreaksInOffice.length; i++) {
      print(empBreaksInOffice[i]);
      print(empBreaksInOffice[i]["punchout"].toString());
      print(empBreaksInOffice[i]["punchin"].toString());
      print(empBreaksInOffice[i]["duration"].toString());
    }

    print("Break  <<<< ---  >>>>  Time   #######@@@@@@######" +
        totalBreakHours.toString() +
        "  hr " +
        totalBreakMinutes.toString() +
        " mins  " +
        totalBreakSecs.toString() +
        " secs");
  }

  Future<void> _selectFromDate(BuildContext context) async {
    fromdate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 60)),
      lastDate: DateTime.now(),
    );
    if (fromdate != null) //if the user has selected a date
      setState(() {
        _selectedFromDate = Jiffy(fromdate).format('dd-MM-yyyy');
      });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 60)),
      lastDate: DateTime.now(),
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
    ApiService.post('subOrdinateEmployees', body).then((success) {
      String data = success.body; //store response as string

      setState(() {
        empList = jsonDecode(data)['subOrdinateEmployees'];
        if (empList.isEmpty) {}
      }); // just printed length of data
    });
  }

}
