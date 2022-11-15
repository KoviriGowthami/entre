import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:entreplan_flutter/views/Notifications/notification_service.dart';
import 'package:entreplan_flutter/views/attendance/PunchinEmployeedetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../Pedometer/StepsTracking.dart';

class ListViewHome extends StatefulWidget {
  _ListViewHomeState createState() => _ListViewHomeState();
}

class _ListViewHomeState extends State<ListViewHome> {
  final List<Map> locale = [
    {"text": 'English', "locale": Locale('en')},
    {"text": 'తెలుగు', "locale": Locale("tel")},
    {"text": 'हिन्दी', "locale": Locale("hi")},
  ];
  updateLanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Stream<StepCount> _stepCountStream;
  Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '0', stepCount = '0';
  var stepData;
  String employeeData = "";
  String punchInOut = "";
  String deptcount = "";
  String visitorsCountDepartment = "";
  bool isVisible = false;
  String newLeaveCount = "0";
  String newPermissionsCount = "0";
  String newOtCount = "0";
  String newRequisitionCount = "0";
  List birthdaysList;
  String stepCountList;
  String birthdaywishes = " ";
  String profileImg = " ";
  String empName = " ";


  void initState() {
    super.initState();
    // setStepcount();
    WidgetsFlutterBinding.ensureInitialized();
    NotificationService().init();
    setData();
    setGridData();
    getBirthdaywish();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    setState(() {
      stepCountList = event.steps.toString();
      stepCount = stepCountList;
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    setState(() {
      _status = 'Pedestrian Status not available';
    });
  }

  void onStepCountError(error) {
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: DoubleBackToCloseApp(
            snackBar: const SnackBar(
              backgroundColor: Color(0xFF5ad6a6),
              content: Text(
                'Tap back again to exit',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/body_bg.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Container(
                  child: SafeArea(
                    bottom: true,
                    child: ListView(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height,
                          child: Visibility(
                              visible: !isVisible,
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                crossAxisCount: 3,
                                childAspectRatio: 1.0,
                                padding: const EdgeInsets.all(3.0),
                                mainAxisSpacing: 4.0,
                                crossAxisSpacing: 4.0,
                                children: [
                                  gridTile(
                                      2,
                                      "leave",
                                      "Leave".tr,
                                      newLeaveCount == "0" ? false : true,
                                      "$newLeaveCount"),
                                  gridTile(
                                      3,
                                      "permission",
                                      "Permission".tr,
                                      newPermissionsCount == "0" ? false : true,
                                      "$newPermissionsCount"),
                                  gridTile(4, "meeting_room", "Meeting Room".tr,
                                      false, ""),
                                  gridTile(
                                      6,
                                      "overtime",
                                      "Overtime(OT)".tr,
                                      newOtCount == "0" ? false : true,
                                      "$newOtCount"),
                                  gridTile(8, "punchin", "Attendance".tr, false, ""),
                                  gridTile(
                                      10, "payslip", "Payslip".tr, false, ""),
                                  gridTile(
                                      9,
                                      "requisition",
                                      "Requisition".tr,
                                      newRequisitionCount == "0" ? false : true,
                                      "$newRequisitionCount"),
                                  gridTile(11, "task_mgt", "Task Management".tr,
                                      false, ""),
                                  gridTile(
                                      12, "calender", "Calendar".tr, false, ""),
                                  gridTile(
                                      13, "induction", "Induction".tr, false, ""),
                                ],
                              )),
                        ),
                        Container(
                          height: 20,
                          width: 20,
                          child: Visibility(
                              visible: isVisible,
                              child: GridView.count(
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: 3,
                                childAspectRatio: 1.0,
                                padding: const EdgeInsets.all(3.0),
                                mainAxisSpacing: 4.0,
                                crossAxisSpacing: 4.0,
                                children: [
                                  gridTile(
                                      2,
                                      "leave",
                                      "Leave".tr,
                                      newLeaveCount == "0" ? false : true,
                                      "$newLeaveCount"),
                                  gridTile(
                                      3,
                                      "permission",
                                      "Permission".tr,
                                      newPermissionsCount == "0" ? false : true,
                                      "$newPermissionsCount"),
                                  gridTile(7, "myinfo", "Visitor".tr, false, ""),
                                  gridTile(8, "punchin", "Attendance".tr, false, ""),
                                  gridTile(
                                      10, "payslip", "Payslip".tr, false, ""),
                                  gridTile(11, "task_mgt", "Task Management".tr,
                                      false, ""),
                                  gridTile(
                                      12, "calender", "Calendar".tr, false, ""),
                                  gridTile(
                                      13, "induction", "Induction".tr, false, ""),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget gridTile(path, imgUrl, title, badgeshow, count) {
    return Container(
      child: InkWell(
          onTap: () async {
            Utilities.navigateUrl(path, context);
          },
          child: Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/home_card.png",
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Visibility(
                    visible: badgeshow,
                    child: Badge(
                      badgeColor: Colors.red,
                      position: BadgePosition.topEnd(top: -18, end: -5),
                      badgeContent: Container(
                        width: 20,
                        height: 15,
                        alignment: Alignment.center,
                        child: Text(
                          '$count',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      child: Container(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      'assets/images/$imgUrl.png',
                      fit: BoxFit.fill,
                      color: Colors.white,
                      height: 40,
                    ),
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Myriad',
                    ),
                    softWrap: true,
                    overflow: TextOverflow.fade,
                  ),
                ],
              ))),
    );
  }

  setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('visitorInPlantCountAndList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        employeeData = jsonDecode(data)['visitorsCount'].toString();
        visitorsCountDepartment =
            jsonDecode(data)['visitorsCountDepartment'].toString();
      }); // just printed length of data
    });

    ApiService.post('membersInPlantCountAndList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        punchInOut = jsonDecode(data)['membersCount'].toString();
        deptcount = jsonDecode(data)['departCount'].toString();
      }); // just printed length of data
    });
  }

  setNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post("appNewNotificationsCount",body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        newLeaveCount = jsonDecode(data)['leaves_count'].toString();
        print(newLeaveCount);
        newPermissionsCount = jsonDecode(data)['permissions_count'].toString();
        print(newPermissionsCount);
        newOtCount = jsonDecode(data)['ot_count'].toString();
        print(newOtCount);
        newRequisitionCount = jsonDecode(data)['requisition_count'].toString();
        print(newRequisitionCount);
        if (newLeaveCount != "0") {
          showNotifications();
        }
        if (newPermissionsCount != "0") {
          showNotifications1();
        }
        if (newOtCount != "0") {
          showNotifications2();
        }
        if (newRequisitionCount != "0") {
          showNotifications3();
        }
      });
    });
  }

  setBirthday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('birthdaysList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        birthdaysList = jsonDecode(data)['birthList'];
        birthdaywishes = jsonDecode(data)['birthList'][0]["wishes"];
        if (birthdaysList.length != 0) {
          showAlert(context);
        }
      });
      showAlert(context);
    });
  }

  void showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 5), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            title: Text(
              '$birthdaywishes',
              style: TextStyle(color: Color(0xff2d324f)),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
          );
        });
  }

  setGridData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("role").toString();
    setState(() {
      profileImg = prefs.getString("Proimage").toString();
      empName = prefs.getString("empName").toString();
      if (id == "Security") {
        return isVisible = true;
      } else {
        return isVisible = false;
      }
    });
  }

  AndroidNotificationDetails _androidNotificationDetails =
      AndroidNotificationDetails(
    'channel ID',
    'channel name',
    'channel description',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );

  Future<void> showNotifications() async {
    await flutterLocalNotificationsPlugin.show(
      0,
      "Leave Pending Approvals",
      "Count : $newLeaveCount",
      NotificationDetails(android: _androidNotificationDetails),
    );
  }

  Future<void> showNotifications1() async {
    await flutterLocalNotificationsPlugin.show(
      1,
      "Permission Pending Approvals",
      "Count :$newPermissionsCount ",
      NotificationDetails(android: _androidNotificationDetails),
    );
  }

  Future<void> showNotifications2() async {
    await flutterLocalNotificationsPlugin.show(
      2,
      "OT Pending Approvals",
      "Count : $newOtCount",
      NotificationDetails(android: _androidNotificationDetails),
    );
  }

  Future<void> showNotifications3() async {
    await flutterLocalNotificationsPlugin.show(
      3,
      "Requesition Pending Approvals",
      "Count : $newRequisitionCount",
      NotificationDetails(android: _androidNotificationDetails),
    );
  }

  stepDetail(stepcount) async {
    saveStepcount(_steps);
  }

  setStepcount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('getStepCount',body).then((success) {
      setState(() {
        stepData = jsonDecode(success.body);
        stepCount = stepData['step_count'].toString();
      });
    });
  }

  saveStepcount(stepcount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode(
        {"user_id": prefs.getString('userId'), "step_count": stepcount});
    ApiService.post('stepCount',body).then((success) {
//store response as string
      setStepcount();
    });
  }

  setAnimation() {
    TweenAnimationBuilder<Duration>(
        duration: Duration(minutes: 3),
        tween: Tween(begin: Duration(minutes: 3), end: Duration.zero),
        onEnd: () {
        },
        builder: (BuildContext context, Duration value, Widget child) {
          final minutes = value.inMinutes;
          final seconds = value.inSeconds % 60;
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text('$_steps',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  )));
        });
  }

  updateAlert() async {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('date', date.toString());
  }

  getBirthdaywish() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String date = prefs.getString("date").toString();
    DateTime now = new DateTime.now();
    DateTime currentDate = new DateTime(now.year, now.month, now.day);
    if (date != currentDate.toString()) {
      setBirthday();
      updateAlert();
      setNotification();
    } else {
    }
  }

  stepMeter(BuildContext context) {
    return Container(
        width: 180,
        height: 180,
        child: SfRadialGauge(axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 10000,
            labelsPosition: ElementsPosition.inside,
            axisLabelStyle:
                GaugeTextStyle(fontWeight: FontWeight.w500, fontSize: 8),
            ranges: <GaugeRange>[
              GaugeRange(
                startValue: 0,
                endValue: 10000,
                color: Colors.white,
              ),
            ],
            pointers: <GaugePointer>[
              RangePointer(
                  value: double.parse(stepCount),
                  width: 0.1,
                  color: Colors.indigo,
                  sizeUnit: GaugeSizeUnit.factor)
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Container(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_walk,
                      color: Colors.black,
                    ),
                    Text('Steps',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black)),
                    Text(stepCount.isEmpty ? 0 : stepCount,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black)),
                  ],
                )),
                angle: 90,
              ),
            ],
          )
        ]));
  }
}
