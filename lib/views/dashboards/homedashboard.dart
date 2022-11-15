import 'dart:convert';

import 'package:entreplan_flutter/views/leave/DashboardLeaveDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../apiservice/rest_api.dart';
import '../attendance/PunchinEmployeedetails.dart';
import '../attendance/myrecords.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final List<Map> locale = [
    {"text": 'English', "locale": Locale('en')},
    {"text": 'తెలుగు', "locale": Locale("tel")},
    {"text": 'हिन्दी', "locale": Locale("hi")},
  ];
  updateLanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
  }

  bool isVisible = false;
  bool _Pressed = true;
  bool _Pressed1 = false;
  bool _Pressed2 = false;
  bool _Pressed3 = false;
  String leaveYear;
  double bottombarWidth;
  String empLeaveByYear;
  String plantName = "";
  String leaveMonth;
  String empSalMonth;
  String empSalYear;
  bool isSwitched = false;
  String _selectedFromDate = Jiffy(DateTime.now()).format('yyyy-MM-dd');
  String empLateInDate = Jiffy(DateTime.now()).format('dd-MM-yyyy');
  DateTime fromdate;
  DateTime latedate;
  List<StackedData> genderChartData = [];
  List<StackedData> leaveChartData = [];
  List<StackedData> empLeaveByYearChartData = [];
  List<StackedData> empAgeChartData = [];
  List<StackedData> empLateInChartData = [];
  List<StackedData> empExpChartData = [];
  List<ChartData1> empattendChartData = [];
  List<ChartData> empDeptChartData = [];
  List<StackedData> empSalaryChartData = [];
  List plantList = [];
  List deptList = [];
  int punchinEmpCount = 0;
  int empVisitorCount = 0;
  int empLeaveCount = 0;
  String plantValue;
  String deptValue;
  int totalSalGross;
  int totalSalNet;
  int totalSalPf;
  String plantId = "1";
  String deptId = "0";
  int allDeptId = 0;
  bool isgenderChart = false;
  bool isgenderMessage = false;
  bool isLeaveChart = false;
  bool isLeaveMessage = false;
  bool isLeaveByYearChart = false;
  bool isLeaveByYearMessage = false;
  bool isempLateInChart = false;
  bool isempLateInMessage = false;
  bool isempAgeChart = false;
  bool isempAgeMessage = false;
  bool isempExpChart = false;
  bool isempExpMessage = false;
  bool isempAttendChart = false;
  bool isempAttendMessage = false;
  bool isempbydeptChart = false;
  bool isempbydeptMessage = false;
  bool isHrDashBoard = true;
  bool isFinanceDashBoard = false;
  bool isSalesDashBoard = false;
  bool isInventoryDashBoard = false;
  bool isMyDashBoard = false;
  bool isAssetsDashBoard = false;
  bool isempSalChart = true;
  bool isempSalMessage = false;

  List hoursInOffice = [];
  var timeDiff;
  String durationInOffice = '';
  int totalHours=0;
  int totalMinutes=0;
  int totalSecs=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOfficehoursDetails();
    makePlantApicall();
    getEmpByDept();
    getPunchinEmp();
    getEmpLeaveByYear();
    setRoleData();
  }

  @override
  Alert(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            alignment: Alignment.center,
            elevation: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  alignment: Alignment.center,
                  color: Colors.greenAccent,
                  child: Text("choose".tr),
                ),
                list(),
                RaisedButton(
                    color: Colors.greenAccent,
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    child: Text("back".tr),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            ),
          );
        });
  }

  Widget list() {
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, int index) {
          return GestureDetector(
            onTap: () {
              updateLanguage(locale[index]["locale"]);
            },
            child: Container(
              padding:
                  EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
              child: Text(locale[index]["text"]),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Container(
            alignment: Alignment.center,
            child: const Divider(
              color: Colors.black,
              indent: 10,
              endIndent: 10,
              thickness: 0.5,
            ),
          );
        },
        itemCount: locale.length);
  }

  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    var format = NumberFormat.simpleCurrency(locale: locale.toString());
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyRecords()));
                      /* Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PunchinEmpDetails(type: "visitor")));*/
                    },
                    child: Column(
                      children: [
                        stepMeter(context),
                        Row(
                          children: [
                            Text('Hrs in Ofc :'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Myriad',
                                  color: Color(0xFF938A8A)
                                )),
                            Text((totalHours<=9?"0"+totalHours.toString():totalHours.toString())+":"+(totalMinutes<=9 ?"0"+totalMinutes.toString():totalMinutes.toString()),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Myriad',
                                  color: Colors.red
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PunchinEmpDetails(type: "employee")));
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/dashboard_employee_bg.png',
                          height: 50,
                          width: 50,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text('Employees: '.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Myriad',
                                )),
                            Text('$punchinEmpCount',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Myriad',
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DashBoardLeaveDetails()));
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/dashboard_leaves_bg.png',
                          height: 50,
                          width: 50,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text('Leaves'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Myriad',
                                )),
                            Text('$empLeaveCount',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Myriad',
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  child: GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/dashboard_male_icon.png',
                          height: 50,
                          width: 50,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text('Male'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Myriad',
                                )),
                            Text('46',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Myriad',
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  child: GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/dashboard_female_icon.png',
                          height: 50,
                          width: 50,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text('Female'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Myriad',
                                )),
                            Text('7',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Myriad',
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: 5,
                ),
                child: Text('Plant'.tr,
                    style: TextStyle(
                      fontFamily: 'Myriad',
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Container(
                width: 270,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage("assets/images/dashboard_dropdown_bg.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 10),
                    border: InputBorder.none,
                    hintText: '$plantName',
                    hintStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  isDense: true,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                  iconSize: 30,
                  items: plantList.map((item) {
                    return new DropdownMenuItem(
                      child: Text(item['plant_name'].toString(),
                          style: TextStyle(
                            color: Colors.black,
                          )),
                      value: item['plant_name'],
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      // plantValue = null;
                      plantValue = value.toString();
                      for (int i = 0; i < plantList.length; i++) {
                        if (value == plantList[i]['plant_name']) {
                          plantId = plantList[i]['id'].toString();
                        }
                      }
                    });
                  },
                  value: plantValue,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: 5,
                ),
                child: Text('Department'.tr,
                    style: TextStyle(
                      fontFamily: 'Myriad',
                      fontWeight: FontWeight.bold,
                    )),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                width: 240,
                margin: EdgeInsets.only(
                  right: 30,
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage("assets/images/dashboard_dropdown_bg.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 10),
                    border: InputBorder.none,
                    hintText: 'Select'.tr,
                    hintStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  isDense: true,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                  iconSize: 30,
                  items: deptList.map((item) {
                    return new DropdownMenuItem(
                      child: Text(item['Department'].toString(),
                          style: TextStyle(
                            color: Colors.black,
                          )),
                      value: item['Department'],
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      deptValue = value.toString();
                      for (int i = 0; i < deptList.length; i++) {
                        if (value == deptList[i]['Department']) {
                          deptId = deptList[i]['id'].toString();
                        }
                      }
                      _dashboardChanges();
                    });
                  },
                  value: deptValue,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          //Hr DashBoards
          Visibility(
            visible: isHrDashBoard,
            child: Column(
              children: [
                Center(
                    child: Column(
                  children: [
                    Visibility(
                      visible: isempbydeptMessage,
                      child: Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                        child: Text('No Data For This Dashboard'),
                      ),
                    ),
                    Visibility(
                      visible: isempbydeptChart,
                      child: Container(
                          height: 500,
                          margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/chart_bg.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: SfCircularChart(
                              title: ChartTitle(
                                  text: 'Employees in Department'.tr),
                              // Enable legend
                              legend: Legend(
                                  isVisible: true,
                                  height: '530%',
                                  position: LegendPosition.bottom,
                                  overflowMode: LegendItemOverflowMode.wrap),
                              // Enable tooltip
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <CircularSeries>[
                                PieSeries<ChartData, String>(
                                  dataSource: empDeptChartData,
                                  xValueMapper: (ChartData data, _) => data.x,
                                  yValueMapper: (ChartData data, _) => data.y,
                                  groupMode: CircularChartGroupMode.point,
                                  // dataLabelMapper: (ChartData data, _) => data.y.toString(),
                                  dataLabelSettings: DataLabelSettings(
                                      // Renders the data label
                                      isVisible: true,
                                      labelIntersectAction:
                                          LabelIntersectAction.shift,
                                      useSeriesColor: true,
                                      overflowMode: OverflowMode.trim,
                                      labelPosition:
                                          ChartDataLabelPosition.outside,
                                      connectorLineSettings:
                                          ConnectorLineSettings(
                                              type: ConnectorType.curve,
                                              length: '5%')),
                                )
                              ])),
                    ),
                  ],
                )),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/chart_bg.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      children: [
                        Visibility(
                          visible: isgenderMessage,
                          child: Text('No Data For This Dashboard'),
                        ),
                        Visibility(
                          visible: isgenderChart,
                          child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(
                                isInversed: true,
                                majorGridLines: MajorGridLines(width: 0),
                                axisLine: AxisLine(width: 0),
                              ),
                              primaryYAxis: NumericAxis(
                                majorGridLines: MajorGridLines(width: 0),
                                axisLine: AxisLine(width: 0),
                              ),
                              title: ChartTitle(text: 'Gender Report'.tr),
                              legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom),
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <ChartSeries>[
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group A',
                                    dataSource: genderChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y1,
                                    name: 'Male',
                                    color: Color(0xFF8ea7da),
                                    borderColor: Color(0xFF8ea7da)),
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group A',
                                    dataSource: genderChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y2,
                                    name: 'Female',
                                    color: Color(0xFFe2917d),
                                    borderColor: Color(0xFFe2917d)),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/chart_bg.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: 200,
                            margin: EdgeInsets.only(left: 20),
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    DropdownButton(
                                      hint: Text("${DateTime.now().year}"),
                                      isDense: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      iconSize: 30,
                                      items: <String>[
                                        '2022',
                                        '2021',
                                        '2020',
                                        '2019',
                                        '2018'
                                      ].map((item) {
                                        return new DropdownMenuItem(
                                            child: new Text(
                                              item,
                                            ),
                                            value: item
                                                .toString() //Id that has to be passed that the dropdown has.....
                                            );
                                      }).toList(),
                                      onChanged: (newVal) {
                                        setState(() {
                                          leaveYear = null;
                                          leaveYear = newVal;
                                        });
                                        getEmpLeave();
                                      },
                                      value: leaveYear,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    DropdownButton(
                                      hint: Text(
                                          Jiffy(DateTime.now()).format('MMM')),
                                      isDense: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      iconSize: 30,
                                      items: <String>[
                                        'Jan',
                                        'Feb',
                                        'Mar',
                                        'Apr',
                                        'May',
                                        'Jun',
                                        'Jul',
                                        'Aug',
                                        'Sep',
                                        'Oct',
                                        'Nov',
                                        'Dec',
                                      ].map((item) {
                                        return new DropdownMenuItem(
                                            child: new Text(
                                              item,
                                            ),
                                            value: item
                                                .toString() //Id that has to be passed that the dropdown has.....
                                            );
                                      }).toList(),
                                      onChanged: (Val) {
                                        setState(() {
                                          leaveMonth = null;
                                          leaveMonth = Val;
                                        });
                                        getEmpLeave();
                                      },
                                      value: leaveMonth,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isLeaveMessage,
                          child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            child: Text('No Data For This Dashboard'),
                          ),
                        ),
                        Visibility(
                          visible: isLeaveChart,
                          child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(
                                isInversed: true,
                                majorGridLines: MajorGridLines(width: 0),
                                axisLine: AxisLine(width: 0),
                              ),
                              primaryYAxis: NumericAxis(
                                majorGridLines: MajorGridLines(width: 0),
                                axisLine: AxisLine(width: 0),
                              ),
                              title: ChartTitle(text: 'Leave Report'.tr),
                              legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom),
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <ChartSeries>[
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group A',
                                    dataSource: leaveChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y1,
                                    name: 'Taken',
                                    color: Color(0xFF8ea7da),
                                    borderColor: Color(0xFF8ea7da)),
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group B',
                                    dataSource: leaveChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y2,
                                    name: 'Approved',
                                    color: Color(0xFFe2917d),
                                    borderColor: Color(0xFFe2917d)),
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group C',
                                    dataSource: leaveChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y3,
                                    name: 'Pending',
                                    color: Color(0xFFf4c174),
                                    borderColor: Color(0xFFf4c174)),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/chart_bg.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Center(
                        child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Text('Total Attendance'.tr),
                                Switch(
                                  value: isSwitched,
                                  onChanged: (value) {
                                    setState(() {
                                      isSwitched = value;
                                      if (isSwitched == true) {
                                        allDeptId = 1;
                                      } else {
                                        allDeptId = 0;
                                      }
                                      getEmpAttendance(allDeptId);
                                    });
                                  },
                                  activeTrackColor: Colors.green,
                                  activeColor: Colors.green,
                                ),
                                Text(_selectedFromDate),
                                IconButton(
                                    onPressed: () {
                                      _selectFromDate(context);
                                    },
                                    icon: Icon(
                                      Icons.calendar_month_outlined,
                                      size: 20,
                                    ))
                              ],
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Visibility(
                              visible: isempAttendMessage,
                              child: Padding(
                                padding: EdgeInsets.only(top: 20, bottom: 20),
                                child: Text('No Data For This Dashboard'),
                              ),
                            ),
                            Visibility(
                              visible: isempAttendChart,
                              child: Container(
                                height: 500,
                                child: SfCircularChart(
                                    title: ChartTitle(
                                        text: 'Attendance Report'.tr),
                                    // Enable legend
                                    legend: Legend(
                                        isVisible: true,
                                        height: '530%',
                                        position: LegendPosition.bottom,
                                        overflowMode:
                                            LegendItemOverflowMode.wrap),
                                    // Enable tooltip
                                    tooltipBehavior:
                                        TooltipBehavior(enable: true),
                                    series: <CircularSeries>[
                                      DoughnutSeries<ChartData1, String>(
                                          dataSource: empattendChartData,
                                          pointColorMapper:
                                              (ChartData1 data, _) =>
                                                  data.color,
                                          xValueMapper: (ChartData1 data, _) =>
                                              data.x,
                                          yValueMapper: (ChartData1 data, _) =>
                                              data.y,
                                          groupMode:
                                              CircularChartGroupMode.point,
                                          // As the grouping mode is point, 2 points will be grouped
                                          groupTo: empattendChartData.length
                                              .toDouble())
                                    ]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ))),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/chart_bg.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: 150,
                            child: Card(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(empLateInDate),
                                  IconButton(
                                      onPressed: () {
                                        _lateInDate(context);
                                      },
                                      icon: Icon(
                                        Icons.calendar_month_outlined,
                                        size: 20,
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isempLateInMessage,
                          child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            child: Text('No Data For This Dashboard'),
                          ),
                        ),
                        Visibility(
                          visible: isempLateInChart,
                          child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(
                                isInversed: true,
                                //Hide the gridlines of x-axis
                                majorGridLines: MajorGridLines(width: 0),
                                //Hide the axis line of x-axis
                                axisLine: AxisLine(width: 0),
                              ),
                              primaryYAxis: NumericAxis(
                                //Hide the gridlines of x-axis
                                majorGridLines: MajorGridLines(width: 0),
                                //Hide the axis line of x-axis
                                axisLine: AxisLine(width: 0),
                              ),
                              title:
                                  ChartTitle(text: 'Late in office Report'.tr),
                              legend: Legend(
                                  isVisible: true,
                                  height: '530%',
                                  position: LegendPosition.bottom,
                                  overflowMode: LegendItemOverflowMode.wrap),
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <ChartSeries>[
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group A',
                                    dataSource: empLateInChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y1,
                                    name: '5-15Mins',
                                    color: Color(0xFF8ea7da),
                                    borderColor: Color(0xFF8ea7da)),
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group B',
                                    dataSource: empLateInChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y2,
                                    name: '15-30Mins',
                                    color: Color(0xFFe2917d),
                                    borderColor: Color(0xFFe2917d)),
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group C',
                                    dataSource: empLateInChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y3,
                                    name: '30Mins-1Hr',
                                    color: Color(0xFFf4c174),
                                    borderColor: Color(0xFFf4c174)),
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group D',
                                    dataSource: empLateInChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y4,
                                    name: '1-2Hrs',
                                    color: Color(0xFF7cbf80),
                                    borderColor: Color(0xFF7cbf80)),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/chart_bg.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Visibility(
                          visible: isempAgeMessage,
                          child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            child: Text('No Data For This Dashboard'),
                          ),
                        ),
                        Visibility(
                          visible: isempAgeChart,
                          child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(
                                isInversed: true,
                                //Hide the gridlines of x-axis
                                majorGridLines: MajorGridLines(width: 0),
                                //Hide the axis line of x-axis
                                axisLine: AxisLine(width: 0),
                              ),
                              primaryYAxis: NumericAxis(
                                //Hide the gridlines of x-axis
                                majorGridLines: MajorGridLines(width: 0),
                                //Hide the axis line of x-axis
                                axisLine: AxisLine(width: 0),
                              ),
                              title:
                                  ChartTitle(text: 'Age of Employee Report'.tr),
                              legend: Legend(
                                  isVisible: true,
                                  height: '530%',
                                  position: LegendPosition.bottom,
                                  overflowMode: LegendItemOverflowMode.wrap),
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <ChartSeries>[
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group A',
                                    dataSource: empAgeChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y1,
                                    name: '20-30Yrs',
                                    color: Color(0xFF8ea7da),
                                    borderColor: Color(0xFF8ea7da)),
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group B',
                                    dataSource: empAgeChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y2,
                                    name: '31-40Yrs',
                                    color: Color(0xFFe2917d),
                                    borderColor: Color(0xFFe2917d)),
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group C',
                                    dataSource: empAgeChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y3,
                                    name: '41-50Yrs',
                                    color: Color(0xFFf4c174),
                                    borderColor: Color(0xFFf4c174)),
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group D',
                                    dataSource: empAgeChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y4,
                                    name: '51-60Yrs',
                                    color: Color(0xFF7cbf80),
                                    borderColor: Color(0xFF7cbf80)),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/chart_bg.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Visibility(
                          visible: isempExpMessage,
                          child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            child: Text('No Data For This Dashboard'),
                          ),
                        ),
                        Visibility(
                          visible: isempExpChart,
                          child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(
                                isInversed: true,
                                //Hide the gridlines of x-axis
                                majorGridLines: MajorGridLines(width: 0),
                                //Hide the axis line of x-axis
                                axisLine: AxisLine(width: 0),
                              ),
                              primaryYAxis: NumericAxis(
                                //Hide the gridlines of x-axis
                                majorGridLines: MajorGridLines(width: 0),
                                //Hide the axis line of x-axis
                                axisLine: AxisLine(width: 0),
                              ),
                              title:
                                  ChartTitle(text: 'Exp of Employee Report'.tr),
                              legend: Legend(
                                  isVisible: true,
                                  height: '530%',
                                  position: LegendPosition.bottom,
                                  overflowMode: LegendItemOverflowMode.wrap),
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <ChartSeries>[
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group A',
                                    dataSource: empExpChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y1,
                                    name: '1-<3Yrs',
                                    color: Color(0xFF8ea7da),
                                    borderColor: Color(0xFF8ea7da)),
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group B',
                                    dataSource: empExpChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y2,
                                    name: '3-<6Yrs',
                                    color: Color(0xFFe2917d),
                                    borderColor: Color(0xFFe2917d)),
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group C',
                                    dataSource: empExpChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y3,
                                    name: '6-<8Yrs',
                                    color: Color(0xFFf4c174),
                                    borderColor: Color(0xFFf4c174)),
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group D',
                                    dataSource: empExpChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y4,
                                    name: '8-<12Yrs',
                                    color: Color(0xFF7cbf80),
                                    borderColor: Color(0xFF7cbf80)),
                                StackedBarSeries<StackedData, String>(
                                    groupName: 'Group E',
                                    dataSource: empExpChartData,
                                    xValueMapper: (StackedData data, _) =>
                                        data.x,
                                    yValueMapper: (StackedData data, _) =>
                                        data.y5,
                                    name: '12-<18Yrs',
                                    color: Color(0xFF7c174c1),
                                    borderColor: Color(0xFF7c174c1)),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          //Finance Dashboard
          Visibility(
            visible: isFinanceDashBoard,
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/chart_bg.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.only(left: 20),
                            width: 200,
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    DropdownButton(
                                      hint: Text("${DateTime.now().year}"),
                                      isDense: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      iconSize: 30,
                                      items: <String>[
                                        '2022',
                                        '2021',
                                        '2020',
                                        '2019',
                                        '2018'
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
                                          empSalYear = newVal;
                                        });
                                        getEmpSal();
                                      },
                                      value: empSalYear,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    DropdownButton(
                                      hint: Text(
                                          Jiffy(DateTime.now()).format('MMM')),
                                      isDense: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      iconSize: 30,
                                      items: <String>[
                                        'Jan',
                                        'Feb',
                                        'Mar',
                                        'Apr',
                                        'May',
                                        'Jun',
                                        'Jul',
                                        'Aug',
                                        'Sep',
                                        'Oct',
                                        'Nov',
                                        'Dec',
                                      ].map((item) {
                                        return new DropdownMenuItem(
                                            child: new Text(
                                              item,
                                            ),
                                            value: item
                                                .toString() //Id that has to be passed that the dropdown has.....
                                        );
                                      }).toList(),
                                      onChanged: (Val) {
                                        setState(() {
                                          empSalMonth = Val;
                                        });
                                        getEmpSal();
                                      },
                                      value: empSalMonth,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isempSalMessage,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Text('No Data For This Dashboard'),
                          ),
                        ),
                        Visibility(
                          visible: isempSalChart,
                          child: Column(
                            children: [
                              SfCartesianChart(
                                  primaryXAxis: CategoryAxis(
                                    isInversed: true,
                                    //Hide the gridlines of x-axis
                                    majorGridLines: MajorGridLines(width: 0),
                                    //Hide the axis line of x-axis
                                    axisLine: AxisLine(width: 0),
                                  ),
                                  primaryYAxis: NumericAxis(
                                    //Hide the gridlines of x-axis
                                    majorGridLines: MajorGridLines(width: 0),
                                    //Hide the axis line of x-axis
                                    axisLine: AxisLine(width: 0),
                                  ),
                                  title:
                                  ChartTitle(text: 'Salary Report'.tr),
                                  legend: Legend(
                                      isVisible: true,
                                      position: LegendPosition.bottom),
                                  tooltipBehavior:
                                  TooltipBehavior(enable: true),
                                  series: <ChartSeries>[
                                    StackedBarSeries<StackedData, String>(
                                        groupName: 'Group A',
                                        dataSource: empSalaryChartData,
                                        xValueMapper: (StackedData data, _) =>
                                        data.x,
                                        yValueMapper: (StackedData data, _) =>
                                        data.y1,
                                        name: 'Gross',
                                        color: Color(0xFF8ea7da),
                                        borderColor: Color(0xFF8ea7da)),
                                    StackedBarSeries<StackedData, String>(
                                        groupName: 'Group B',
                                        dataSource: empSalaryChartData,
                                        xValueMapper: (StackedData data, _) =>
                                        data.x,
                                        yValueMapper: (StackedData data, _) =>
                                        data.y2,
                                        name: 'Net Salary',
                                        color: Color(0xFFe2917d),
                                        borderColor: Color(0xFFe2917d)),
                                    StackedBarSeries<StackedData, String>(
                                        groupName: 'Group C',
                                        dataSource: empSalaryChartData,
                                        xValueMapper: (StackedData data, _) =>
                                        data.x,
                                        yValueMapper: (StackedData data, _) =>
                                        data.y3,
                                        name: 'PF',
                                        color: Color(0xFFf4c174),
                                        borderColor: Color(0xFFf4c174)),
                                  ]),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total GrossSalary:  " +
                                            "$totalSalGross",
                                        style: TextStyle(
                                          color: Color(0xFF8ea7da),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Total NetSalary:  " + "$totalSalNet",
                                        style: TextStyle(
                                          color: Color(0xFFe2917d),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Total PF:  " + "$totalSalPf",
                                        style: TextStyle(
                                          color: Color(0xFFf4c174),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          //Sales Dashboard
         /* Visibility(
            visible: isSalesDashBoard,
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/chart_bg.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.only(left: 20),
                            width: 200,
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    DropdownButton(
                                      hint: Text("${DateTime.now().year}"),
                                      isDense: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      iconSize: 30,
                                      items: <String>[
                                        '2022',
                                        '2021',
                                        '2020',
                                        '2019',
                                        '2018'
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
                                          empSalYear = newVal;
                                        });
                                        getEmpSal();
                                      },
                                      value: empSalYear,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    DropdownButton(
                                      hint: Text(
                                          Jiffy(DateTime.now()).format('MMM')),
                                      isDense: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      iconSize: 30,
                                      items: <String>[
                                        'Jan',
                                        'Feb',
                                        'Mar',
                                        'Apr',
                                        'May',
                                        'Jun',
                                        'Jul',
                                        'Aug',
                                        'Sep',
                                        'Oct',
                                        'Nov',
                                        'Dec',
                                      ].map((item) {
                                        return new DropdownMenuItem(
                                            child: new Text(
                                              item,
                                            ),
                                            value: item
                                                .toString() //Id that has to be passed that the dropdown has.....
                                            );
                                      }).toList(),
                                      onChanged: (Val) {
                                        setState(() {
                                          empSalMonth = Val;
                                        });
                                        getEmpSal();
                                      },
                                      value: empSalMonth,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isempSalMessage,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Text('No Data For This Dashboard'),
                          ),
                        ),
                        Visibility(
                          visible: isempSalChart,
                          child: Column(
                            children: [
                              SfCartesianChart(
                                  primaryXAxis: CategoryAxis(
                                    //Hide the gridlines of x-axis
                                    majorGridLines: MajorGridLines(width: 0),
                                    //Hide the axis line of x-axis
                                    axisLine: AxisLine(width: 0),
                                  ),
                                  title: ChartTitle(text: 'Income Report'.tr),
                                  series: <ChartSeries>[
                                    LineSeries<LineChartData, String>(
                                        dataSource: [
                                          LineChartData(
                                              'Jan', 350000, Colors.red),
                                          LineChartData(
                                              'Feb', 280000, Colors.green),
                                          LineChartData(
                                              'Mar', 340000, Colors.blue),
                                          LineChartData(
                                              'Apr', 320000, Colors.pink),
                                          LineChartData(
                                              'May', 400000, Colors.black),
                                          LineChartData(
                                              'Jun', 250000, Colors.red),
                                          LineChartData(
                                              'Jul', 250000, Colors.red),
                                          LineChartData(
                                              'Aug', 750000, Colors.green),
                                          LineChartData(
                                              'Sep', 450000, Colors.red),
                                          LineChartData(
                                              'Oct', 50000, Colors.green),
                                          LineChartData(
                                              'Nov', 650000, Colors.green),
                                          LineChartData(
                                              'Dec', 550000, Colors.red),
                                        ],
                                        // Bind the color for all the data points from the data source
                                        pointColorMapper:
                                            (LineChartData data, _) =>
                                                data.color,
                                        xValueMapper: (LineChartData data, _) =>
                                            data.x,
                                        yValueMapper: (LineChartData data, _) =>
                                            data.y)
                                  ]),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: isempSalChart,
                          child: Column(
                            children: [
                              SfCartesianChart(
                                  primaryXAxis: CategoryAxis(
                                    //Hide the gridlines of x-axis
                                    majorGridLines: MajorGridLines(width: 0),
                                    //Hide the axis line of x-axis
                                    axisLine: AxisLine(width: 0),
                                  ),
                                  title:
                                      ChartTitle(text: 'Monthly Expenses'.tr),
                                  series: <ChartSeries>[
                                    LineSeries<LineChartData, String>(
                                        dataSource: [
                                          LineChartData(
                                              'Jan', 500000, Colors.blue),
                                          LineChartData(
                                              'Feb', 500000, Colors.blue),
                                          LineChartData(
                                              'Mar', 500000, Colors.blue),
                                          LineChartData(
                                              'Apr', 500000, Colors.blue),
                                          LineChartData(
                                              'May', 400000, Colors.blue),
                                          LineChartData(
                                              'Jun', 500000, Colors.blue),
                                          LineChartData(
                                              'Jul', 500000, Colors.blue),
                                          LineChartData(
                                              'Aug', 650000, Colors.blue),
                                          LineChartData(
                                              'Sep', 500000, Colors.blue),
                                          LineChartData(
                                              'Oct', 500000, Colors.blue),
                                          LineChartData(
                                              'Nov', 500000, Colors.blue),
                                          LineChartData(
                                              'Dec', 500000, Colors.blue),
                                        ],
                                        // Bind the color for all the data points from the data source
                                        pointColorMapper:
                                            (LineChartData data, _) =>
                                                data.color,
                                        xValueMapper: (LineChartData data, _) =>
                                            data.x,
                                        yValueMapper: (LineChartData data, _) =>
                                            data.y)
                                  ]),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: isempSalChart,
                          child: Column(
                            children: [
                              SfCartesianChart(
                                  primaryXAxis: CategoryAxis(
                                    //Hide the gridlines of x-axis
                                    majorGridLines: MajorGridLines(width: 0),
                                    //Hide the axis line of x-axis
                                    axisLine: AxisLine(width: 0),
                                  ),
                                  title: ChartTitle(text: 'Profit'.tr),
                                  series: <ChartSeries>[
                                    LineSeries<LineChartData, String>(
                                        dataSource: [
                                          LineChartData(
                                              'Jan', 350000, Colors.red),
                                          LineChartData(
                                              'Feb', 280000, Colors.green),
                                          LineChartData(
                                              'Mar', 340000, Colors.blue),
                                          LineChartData(
                                              'Apr', 320000, Colors.pink),
                                          LineChartData(
                                              'May', 400000, Colors.black),
                                          LineChartData(
                                              'Jun', 250000, Colors.red),
                                          LineChartData(
                                              'Jul', 250000, Colors.red),
                                          LineChartData(
                                              'Aug', 750000, Colors.green),
                                          LineChartData(
                                              'Sep', 450000, Colors.red),
                                          LineChartData(
                                              'Oct', 50000, Colors.green),
                                          LineChartData(
                                              'Nov', 650000, Colors.green),
                                          LineChartData(
                                              'Dec', 550000, Colors.red),
                                        ],
                                        // Bind the color for all the data points from the data source
                                        pointColorMapper:
                                            (LineChartData data, _) =>
                                                data.color,
                                        xValueMapper: (LineChartData data, _) =>
                                            data.x,
                                        yValueMapper: (LineChartData data, _) =>
                                            data.y)
                                  ]),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: isempSalChart,
                          child: Column(
                            children: [
                              SfCartesianChart(
                                  primaryXAxis: CategoryAxis(
                                    //Hide the gridlines of x-axis
                                    majorGridLines: MajorGridLines(width: 0),
                                    //Hide the axis line of x-axis
                                    axisLine: AxisLine(width: 0),
                                  ),
                                  title: ChartTitle(text: 'Payments'.tr),
                                  series: <ChartSeries>[
                                    LineSeries<LineChartData, String>(
                                        dataSource: [
                                          LineChartData(
                                              'Jan', 500000, Colors.red),
                                          LineChartData(
                                              'Feb', 500000, Colors.green),
                                          LineChartData(
                                              'Mar', 500000, Colors.blue),
                                          LineChartData(
                                              'Apr', 500000, Colors.pink),
                                          LineChartData(
                                              'May', 500000, Colors.black),
                                          LineChartData(
                                              'Jun', 500000, Colors.red),
                                          LineChartData(
                                              'Jul', 500000, Colors.red),
                                          LineChartData(
                                              'Aug', 500000, Colors.green),
                                          LineChartData(
                                              'Sep', 500000, Colors.red),
                                          LineChartData(
                                              'Oct', 500000, Colors.green),
                                          LineChartData(
                                              'Nov', 500000, Colors.green),
                                          LineChartData(
                                              'Dec', 500000, Colors.red),
                                        ],
                                        // Bind the color for all the data points from the data source
                                        pointColorMapper:
                                            (LineChartData data, _) =>
                                                data.color,
                                        xValueMapper: (LineChartData data, _) =>
                                            data.x,
                                        yValueMapper: (LineChartData data, _) =>
                                            data.y)
                                  ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),*/
          //Inventory Dashboard
         /* Visibility(
            visible: isInventoryDashBoard,
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/chart_bg.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.only(left: 20),
                            width: 200,
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    DropdownButton(
                                      hint: Text("${DateTime.now().year}"),
                                      isDense: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      iconSize: 30,
                                      items: <String>[
                                        '2022',
                                        '2021',
                                        '2020',
                                        '2019',
                                        '2018'
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
                                          empSalYear = newVal;
                                        });
                                        getEmpSal();
                                      },
                                      value: empSalYear,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    DropdownButton(
                                      hint: Text(
                                          Jiffy(DateTime.now()).format('MMM')),
                                      isDense: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                      iconSize: 30,
                                      items: <String>[
                                        'Jan',
                                        'Feb',
                                        'Mar',
                                        'Apr',
                                        'May',
                                        'Jun',
                                        'Jul',
                                        'Aug',
                                        'Sep',
                                        'Oct',
                                        'Nov',
                                        'Dec',
                                      ].map((item) {
                                        return new DropdownMenuItem(
                                            child: new Text(
                                              item,
                                            ),
                                            value: item
                                                .toString() //Id that has to be passed that the dropdown has.....
                                            );
                                      }).toList(),
                                      onChanged: (Val) {
                                        setState(() {
                                          empSalMonth = Val;
                                        });
                                        getEmpSal();
                                      },
                                      value: empSalMonth,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isempSalMessage,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Text('No Data For This Dashboard'),
                          ),
                        ),
                        Visibility(
                          visible: isempSalChart,
                          child: Column(
                            children: [
                              SfCartesianChart(
                                  primaryXAxis: CategoryAxis(
                                    isInversed: true,
                                    //Hide the gridlines of x-axis
                                    majorGridLines: MajorGridLines(width: 0),
                                    //Hide the axis line of x-axis
                                    axisLine: AxisLine(width: 0),
                                  ),
                                  primaryYAxis: NumericAxis(
                                    //Hide the gridlines of x-axis
                                    majorGridLines: MajorGridLines(width: 0),
                                    //Hide the axis line of x-axis
                                    axisLine: AxisLine(width: 0),
                                  ),
                                  title:
                                      ChartTitle(text: 'Inventory Report'.tr),
                                  legend: Legend(
                                      isVisible: true,
                                      position: LegendPosition.bottom),
                                  tooltipBehavior:
                                      TooltipBehavior(enable: true),
                                  series: <ChartSeries>[
                                    StackedBarSeries<StackedData, String>(
                                        groupName: 'Group A',
                                        dataSource: empSalaryChartData,
                                        xValueMapper: (StackedData data, _) =>
                                            data.x,
                                        yValueMapper: (StackedData data, _) =>
                                            data.y1,
                                        name: 'Gross',
                                        color: Color(0xFF8ea7da),
                                        borderColor: Color(0xFF8ea7da)),
                                    StackedBarSeries<StackedData, String>(
                                        groupName: 'Group B',
                                        dataSource: empSalaryChartData,
                                        xValueMapper: (StackedData data, _) =>
                                            data.x,
                                        yValueMapper: (StackedData data, _) =>
                                            data.y2,
                                        name: 'Net Salary',
                                        color: Color(0xFFe2917d),
                                        borderColor: Color(0xFFe2917d)),
                                    StackedBarSeries<StackedData, String>(
                                        groupName: 'Group C',
                                        dataSource: empSalaryChartData,
                                        xValueMapper: (StackedData data, _) =>
                                            data.x,
                                        yValueMapper: (StackedData data, _) =>
                                            data.y3,
                                        name: 'PF',
                                        color: Color(0xFFf4c174),
                                        borderColor: Color(0xFFf4c174)),
                                  ]),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total GrossSalary:  " +
                                            "$totalSalGross",
                                        style: TextStyle(
                                          color: Color(0xFF8ea7da),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Total NetSalary:  " + "$totalSalNet",
                                        style: TextStyle(
                                          color: Color(0xFFe2917d),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Total PF:  " + "$totalSalPf",
                                        style: TextStyle(
                                          color: Color(0xFFf4c174),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),*/
          //My dashboard
          Visibility(
              visible: isMyDashBoard,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/chart_bg.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              width: 100,
                              margin: EdgeInsets.only(left: 20),
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      DropdownButton(
                                        hint: Text("${DateTime.now().year}"),
                                        isDense: true,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black,
                                        ),
                                        iconSize: 30,
                                        items: <String>[
                                          '2022',
                                          '2021',
                                          '2020',
                                          '2019',
                                          '2018'
                                        ].map((item) {
                                          return new DropdownMenuItem(
                                              child: new Text(
                                                item,
                                              ),
                                              value: item
                                                  .toString() //Id that has to be passed that the dropdown has.....
                                              );
                                        }).toList(),
                                        onChanged: (newVal) {
                                          setState(() {
                                            empLeaveByYear = newVal;
                                          });
                                          getEmpLeaveByYear();
                                        },
                                        value: empLeaveByYear,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isLeaveByYearMessage,
                            child: Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 20),
                              child: Text('No Data For This Dashboard'),
                            ),
                          ),
                          Visibility(
                            visible: isLeaveByYearChart,
                            child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(
                                  isInversed: true,
                                  //Hide the gridlines of x-axis
                                  majorGridLines: MajorGridLines(width: 0),
                                  //Hide the axis line of x-axis
                                  axisLine: AxisLine(width: 0),
                                ),
                                primaryYAxis: NumericAxis(
                                  //Hide the gridlines of x-axis
                                  majorGridLines: MajorGridLines(width: 0),
                                  //Hide the axis line of x-axis
                                  axisLine: AxisLine(width: 0),
                                ),
                                title: ChartTitle(text: 'My Leave Report'.tr),
                                legend: Legend(
                                    isVisible: true,
                                    position: LegendPosition.bottom),
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: <ChartSeries>[
                                  StackedBarSeries<StackedData, String>(
                                      groupName: 'Group A',
                                      dataSource: empLeaveByYearChartData,
                                      xValueMapper: (StackedData data, _) =>
                                          data.x,
                                      yValueMapper: (StackedData data, _) =>
                                          data.y1,
                                      name: 'Annual Leave',
                                      color: Color(0xFF8ea7da),
                                      borderColor: Color(0xFF8ea7da)),
                                  StackedBarSeries<StackedData, String>(
                                      groupName: 'Group B',
                                      dataSource: empLeaveByYearChartData,
                                      xValueMapper: (StackedData data, _) =>
                                          data.x,
                                      yValueMapper: (StackedData data, _) =>
                                          data.y2,
                                      name: 'Sick Leave',
                                      color: Color(0xFFe2917d),
                                      borderColor: Color(0xFFe2917d)),
                                  StackedBarSeries<StackedData, String>(
                                      groupName: 'Group C',
                                      dataSource: empLeaveByYearChartData,
                                      xValueMapper: (StackedData data, _) =>
                                          data.x,
                                      yValueMapper: (StackedData data, _) =>
                                          data.y3,
                                      name: 'Assigned',
                                      color: Color(0xFFf4c174),
                                      borderColor: Color(0xFFf4c174)),
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ))
        ]),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/dashboard_bottombar_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: _Pressed == true ? Colors.teal : Colors.transparent,
              child: GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      scale: 2,
                      alignment: Alignment.topCenter,
                      image: AssetImage("assets/images/hr_img.png"),
                    ),
                  ),
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        _Pressed = true;
                        _Pressed1 = false;
                        _Pressed2 = false;
                        _Pressed3 = false;
                        isHrDashBoard = true;
                        isFinanceDashBoard = false;
                        isSalesDashBoard = false;
                        isInventoryDashBoard = false;
                        isMyDashBoard = false;
                      });
                    },
                    child: Text(
                      'HR'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Myriad',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isVisible,
              child: Container(
                color: _Pressed1 == true ? Colors.teal : Colors.transparent,
                child: GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        scale: 2,
                        alignment: Alignment.topCenter,
                        image: AssetImage("assets/images/finance_img.png"),
                      ),
                    ),
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          _Pressed1 = true;
                          _Pressed = false;
                          _Pressed2 = false;
                          _Pressed3 = false;
                          isHrDashBoard = false;
                          isFinanceDashBoard = true;
                          isSalesDashBoard = false;
                          isInventoryDashBoard = false;
                          isMyDashBoard = false;
                        });
                      },
                      child: Text(
                        'Finance'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Myriad',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            /*Visibility(
              visible: isVisible,
              child: Container(
                color: _Pressed2 == true ? Colors.teal : Colors.transparent,
                child: GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        scale: 2,
                        alignment: Alignment.topCenter,
                        image: AssetImage("assets/images/finance_img.png"),
                      ),
                    ),
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          _Pressed1 = false;
                          _Pressed = false;
                          _Pressed2 = true;
                          _Pressed3 = false;
                          isHrDashBoard = false;
                          isFinanceDashBoard = false;
                          isSalesDashBoard = true;
                          isInventoryDashBoard = false;
                          isMyDashBoard = false;
                        });
                      },
                      child: Text(
                        'Sales'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Myriad',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isVisible,
              child: Container(
                color: _Pressed3 == true ? Colors.teal : Colors.transparent,
                child: GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        scale: 2,
                        alignment: Alignment.topCenter,
                        image: AssetImage("assets/images/finance_img.png"),
                      ),
                    ),
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          _Pressed1 = false;
                          _Pressed2 = false;
                          _Pressed3 = true;
                          _Pressed = false;
                          isHrDashBoard = false;
                          isFinanceDashBoard = false;
                          isSalesDashBoard = false;
                          isInventoryDashBoard = true;
                          isMyDashBoard = false;
                        });
                      },
                      child: Text(
                        'Inventory'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Myriad',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }


  stepMeter(BuildContext context) {
    var hrs = (totalHours/8)*100;
    var hrspercent = 0;
    hrspercent= hrs.ceil();
    print(hrs);
    print(hrspercent/10);
    print("Gauge ########&&&&&&&&&&######");
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 60,
            height: 60,
            child: SfRadialGauge(axes: <RadialAxis>[
              RadialAxis(
                showLabels: false,
                showTicks: false,
                startAngle: 270,
                endAngle: 270,
                radiusFactor: 0.8,
                axisLineStyle: const AxisLineStyle(
                    thicknessUnit: GaugeSizeUnit.factor, thickness: 0.15),
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      angle: 180,
                      widget: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(hrspercent>100? "100%" : hrspercent.toString()+"%",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.red)),
                            ],
                          )),
                    ),
                  ],
                pointers: <GaugePointer>[
                  RangePointer(
                      value: double.parse(hrs.toString()),
                      gradient: SweepGradient(
                          colors: <Color>[Colors.green, Colors.green],
                          stops: <double>[0.25, 0.75]),
                      color: Colors.green,
                      width: 0.15,
                      enableAnimation: true,
                      animationDuration: 1200,
                      sizeUnit: GaugeSizeUnit.factor)
                ],
              )
            ])),
       /* Container(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hrs in Ofc',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black)),
            Text(totalHours.toString()+":"+totalMinutes.toString(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black)),
          ],
        ),)*/
      ],
    );
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
        _selectedFromDate = Jiffy(fromdate).format('yyyy-MM-dd');
        getEmpAttendance(allDeptId);
      });
  }

  Future<void> _lateInDate(BuildContext context) async {
    latedate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 60)),
      lastDate: DateTime(2100),
    );
    if (latedate != null) //if the user has selected a date
      setState(() {
        empLateInDate = Jiffy(latedate).format('dd-MM-yyyy');
        getEmpLateIn();
      });
  }

  makePlantApicall() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    plantName = prefs.getString('Plantname');
    final body =
        jsonEncode({"user_id": prefs.getString('userId'), "locationid": "1"});
    ApiService.post('plantlst', body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        plantList = jsonDecode(data)['plantlst'];
        for (int i = 0; i < plantList.length; i++) {
          plantName = jsonDecode(data)['plantlst'][i]['plant_name'].toString();
        }
      });
      makeDepartmentApicall();
    });
  }

  makeDepartmentApicall() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({
      "user_id": prefs.getString('userId'),
    });
    ApiService.post('departmentsList', body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        deptList = jsonDecode(data)['departmntdetails'];
      }); // just printed length of data
    });
  }

  getEmpByDept() async {
    final body = jsonEncode({
      "plantid": plantId,
      "departmentId": deptId,
    });
    ApiService.post('employeesinplant', body).then((success) {
      String data = success.body; //store response as string
      List empbyDeptList = jsonDecode(data)['emp_list'];
      empDeptChartData = [];
      setState(() {
        for (int i = 0; i < empbyDeptList.length; i++) {
          empDeptChartData.add(ChartData(empbyDeptList[i]['department'],
              double.parse(empbyDeptList[i]['empCount']), ''));
        }
        if (empbyDeptList.length == 0) {
          isempbydeptMessage = true;
          isempbydeptChart = false;
        } else {
          isempbydeptChart = true;
          isempbydeptMessage = false;
        }
      });
    });
    getEmpGender();
  }

  getEmpGender() async {
    final body = jsonEncode(
        {"plantid": plantId, "departmentId": deptId, "genderType": 0});
    ApiService.post('empGender', body).then((success) {
      String data = success.body; //store response as string
      List genderList = jsonDecode(data)['gender_list'];
      genderChartData = [];
      setState(() {
        for (int i = 0; i < genderList.length; i++) {
          genderChartData.add(StackedData(
              genderList[i]['department'],
              double.parse(genderList[i]['male']),
              double.parse(genderList[i]['female']),
              0,
              0,
              0));
        }
        if (genderList.length == 0) {
          isgenderMessage = true;
          isgenderChart = false;
        } else {
          isgenderChart = true;
          isgenderMessage = false;
        }
      });
    });
    getEmpLeave();
  }

  getEmpLeave() async {
    String MonthID;
    if (leaveMonth == "Jan") {
      MonthID = "1";
    } else if (leaveMonth == "Feb") {
      MonthID = "2";
    } else if (leaveMonth == "Mar") {
      MonthID = "3";
    } else if (leaveMonth == "Apr") {
      MonthID = "4";
    } else if (leaveMonth == "May") {
      MonthID = "5";
    } else if (leaveMonth == "Jun") {
      MonthID = "6";
    } else if (leaveMonth == "Jul") {
      MonthID = "7";
    } else if (leaveMonth == "Aug") {
      MonthID = "8";
    } else if (leaveMonth == "Sep") {
      MonthID = "9";
    } else if (leaveMonth == "Oct") {
      MonthID = "10";
    } else if (leaveMonth == "Nov") {
      MonthID = "11";
    } else if (leaveMonth == "Dec") {
      MonthID = "12";
    }

    String yearId;
    if (leaveYear == "2018") {
      yearId = "2018";
    } else if (leaveYear == "2019") {
      yearId = "2019";
    } else if (leaveYear == "2020") {
      yearId = "2020";
    } else if (leaveYear == "2021") {
      yearId = "2021";
    } else if (leaveYear == "2022") {
      yearId = "2022";
    }
    var Year = Jiffy(DateTime.now()).format('yyyy');
    var Month = Jiffy(DateTime.now()).format('MM');
    final body = jsonEncode({
      "plantid": plantId,
      "departmentId": deptId,
      "year": leaveYear == null ? Year : yearId,
      "month": leaveMonth == null ? Month : MonthID
    });
    ApiService.post('empLeave', body).then((success) {
      String data = success.body; //store response as string
      List leaveList = jsonDecode(data)['empLeaveList'];
      leaveChartData = [];

      setState(() {
        for (int i = 0; i < leaveList.length; i++) {
          print(leaveList[i]);
          leaveChartData.add(StackedData(
              leaveList[i]['department'],
              double.parse(leaveList[i]['taken']),
              double.parse(leaveList[i]['schedule']),
              double.parse(leaveList[i]['pending']),
              0,
              0));
        }
        if (leaveList.length == 0) {
          isLeaveMessage = true;
          isLeaveChart = false;
        } else {
          isLeaveChart = true;
          isLeaveMessage = false;
        }
      });
    });
    getEmpAttendance(allDeptId);
  }

  getEmpLeaveByYear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String yearId;
    if (empLeaveByYear == "2018") {
      yearId = "2018";
    } else if (empLeaveByYear == "2019") {
      yearId = "2019";
    } else if (empLeaveByYear == "2020") {
      yearId = "2020";
    } else if (empLeaveByYear == "2021") {
      yearId = "2021";
    } else if (empLeaveByYear == "2022") {
      yearId = "2022";
    }

    var Year = Jiffy(DateTime.now()).format('yyyy');
    final body = jsonEncode({
      "empNumber": int.parse(prefs.getString('empNumber')),
      "year": empLeaveByYear == null ? Year : yearId
    });
    ApiService.post('lginEmpLvbyYr', body).then((success) {
      String data = success.body; //store response as string
      List leaveList = jsonDecode(data)['empLeaveList'];
      empLeaveByYearChartData = [];
      setState(() {
        for (int i = 0; i < leaveList.length; i++) {
          empLeaveByYearChartData.add(StackedData(
              leaveList[i]['lvMonth'],
              double.parse(leaveList[i]['annualLeave']),
              double.parse(leaveList[i]['sickLeave']),
              0,
              0,
              0));
        }
        if (leaveList.length == 0) {
          isLeaveByYearMessage = true;
          isLeaveByYearChart = false;
        } else {
          isLeaveByYearChart = true;
          isLeaveByYearMessage = false;
        }
      });
    });
  }

  getEmpAttendance(val) async {
    var leaveDate = Jiffy(DateTime.now()).format('yyyy-MM-dd');
    final body = jsonEncode({
      "plantid": plantId,
      "punchDate":
          _selectedFromDate == Jiffy(DateTime.now()).format('yyyy-MM-dd')
              ? leaveDate
              : _selectedFromDate,
      "departmentId": deptId,
      "isAllDept": val
    });
    ApiService.post('empAttendance', body).then((success) {
      String data = success.body; //store response as string
      List empAttendanceList = jsonDecode(data)['empAttdList'];
      empattendChartData = [];
      setState(() {
        for (int i = 0; i < empAttendanceList.length; i++) {
          empattendChartData.add(ChartData1(
            empAttendanceList[i]['department'],
            double.parse(empAttendanceList[i]['empCount']),
          ));
        }
        if (empAttendanceList.length == 0) {
          isempAttendMessage = true;
          isempAttendChart = false;
        } else {
          isempAttendChart = true;
          isempAttendMessage = false;
        }
      });
    });
    getEmpLateIn();
  }

  getEmpLateIn() async {
    var leaveDate = Jiffy(DateTime.now()).format('dd-MM-yyyy');
    final body = jsonEncode({
      "plantid": plantId,
      "departmentId": deptId,
      "reqdate": empLateInDate == Jiffy(DateTime.now()).format('yyyy-MM-dd')
          ? leaveDate
          : empLateInDate
    });
    ApiService.post('empLateIn', body).then((success) {
      String data = success.body; //store response as string
      List empLateInList = jsonDecode(data)['empLateInList'];
      empLateInChartData = [];
      setState(() {
        for (int i = 0; i < empLateInList.length; i++) {
          empLateInChartData.add(StackedData(
              empLateInList[i]['department'],
              double.parse(empLateInList[i]['15mns']),
              double.parse(empLateInList[i]['30mns']),
              double.parse(empLateInList[i]['1hr']),
              double.parse(empLateInList[i]['2hrs']),
              0));
        }
        if (empLateInList.length == 0) {
          isempLateInMessage = true;
          isempLateInChart = false;
        } else {
          isempLateInChart = true;
          isempLateInMessage = false;
        }
      });
    });
    getEmpAge();
  }

  getEmpAge() async {
    final body = jsonEncode({
      "plantid": plantId,
      "departmentId": deptId,
    });
    ApiService.post('empAge', body).then((success) {
      String data = success.body;
      List empAgeList = jsonDecode(data)['empAgeList'];
      empAgeChartData = [];
      setState(() {
        for (int i = 0; i < empAgeList.length; i++) {
          empAgeChartData.add(StackedData(
              empAgeList[i]['department'],
              double.parse(empAgeList[i]['20_30']),
              double.parse(empAgeList[i]['30_40']),
              double.parse(empAgeList[i]['40_50']),
              double.parse(empAgeList[i]['50_60']),
              0));
        }
        if (empAgeList.length == 0) {
          isempAgeMessage = true;
          isempAgeChart = false;
        } else {
          isempAgeChart = true;
          isempAgeMessage = false;
        }
      });
    });
    getEmpExp();
  }

  getEmpExp() async {
    final body = jsonEncode({
      "plantid": plantId,
      "departmentId": deptId,
    });
    ApiService.post('empExp', body).then((success) {
      String data = success.body; //store response as string
      List empExpList = jsonDecode(data)['empExpList'];
      empExpChartData = [];
      setState(() {
        for (int i = 0; i < empExpList.length; i++) {
          empExpChartData.add(StackedData(
            empExpList[i]['department'],
            double.parse(empExpList[i]['1_3']),
            double.parse(empExpList[i]['3_6']),
            double.parse(empExpList[i]['6_8']),
            double.parse(empExpList[i]['8_12']),
            double.parse(empExpList[i]['12_18']),
          ));
        }
        if (empExpList.length == 0) {
          isempExpMessage = true;
          isempExpChart = false;
        } else {
          isempExpChart = true;
          isempExpMessage = false;
        }
      });
    });
    getEmpSal();
  }

  getEmpSal() async {
    var Year = Jiffy(DateTime.now()).format('yyyy');
    var Month = Jiffy(DateTime.now()).format('MM');
    String MonthID;
    if (empSalMonth == "Jan") {
      MonthID = "1";
    } else if (empSalMonth == "Feb") {
      MonthID = "2";
    } else if (empSalMonth == "Mar") {
      MonthID = "3";
    } else if (empSalMonth == "Apr") {
      MonthID = "4";
    } else if (empSalMonth == "May") {
      MonthID = "5";
    } else if (empSalMonth == "Jun") {
      MonthID = "6";
    } else if (empSalMonth == "Jul") {
      MonthID = "7";
    } else if (empSalMonth == "Aug") {
      MonthID = "8";
    } else if (empSalMonth == "Sep") {
      MonthID = "9";
    } else if (empSalMonth == "Oct") {
      MonthID = "10";
    } else if (empSalMonth == "Nov") {
      MonthID = "11";
    } else if (empSalMonth == "Dec") {
      MonthID = "12";
    }

    String yearId;
    if (empSalYear == "2018") {
      yearId = "2018";
    } else if (empSalYear == "2019") {
      yearId = "2019";
    } else if (empSalYear == "2020") {
      yearId = "2020";
    } else if (empSalYear == "2021") {
      yearId = "2021";
    } else if (empSalYear == "2022") {
      yearId = "2022";
    }
    final body = jsonEncode({
      "plantId": plantId,
      "departmentId": deptId,
      "year": empSalYear == null ? Year : yearId,
      "month": empSalMonth == null ? Month : MonthID
    });
    ApiService.post('empSalByMonth', body).then((success) {
      String data = success.body; //store response as string
      List empSalList = jsonDecode(data)['empSalList'];
      empSalaryChartData = [];
      setState(() {
        for (int i = 0; i < empSalList.length; i++) {
          empSalaryChartData.add(StackedData(
              empSalList[i]['department'],
              double.parse(empSalList[i]['gross']),
              double.parse(empSalList[i]['netsalary']),
              double.parse(empSalList[i]['pf']),
              0,
              0));
        }
        if (empSalList.length == 0) {
          isempSalMessage = true;
          isempSalChart = false;
        } else {
          isempSalChart = true;
          isempSalMessage = false;
        }
        totalSalGross = jsonDecode(data)['totalSal'][0]['grossTotal'];
        totalSalNet = jsonDecode(data)['totalSal'][0]['netTotal'];
        totalSalPf = jsonDecode(data)['totalSal'][0]['PFTotal'];
      });
    });
  }

  getPunchinEmp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"departmentId":prefs.getString("deptId"),"cdate":Jiffy(DateTime.now()).format('yyyy-MM-dd')});
    ApiService.post('empPunchIn', body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        List punchInList = jsonDecode(data)['empPunchInList'];
        if (punchinEmpCount == null ||
            punchInList.isEmpty ||
            punchInList == null) {
          setState(() {
            punchinEmpCount = 0;
          });
        } else {
          punchinEmpCount = jsonDecode(data)['count'];
        }
        print(punchinEmpCount);
        print(punchInList);
        print('punchInList');
      });
      getVisitorEmp();
    });
  }

  getVisitorEmp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({
      "user_id": prefs.getString('userId'),
    });
    ApiService.post('visitorInPlantCountAndList', body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        empVisitorCount = jsonDecode(data)['visitorsCount'];
      });
      getEmpLeaveCount();
    });
  }

  getEmpLeaveCount() async {
    print('leaveeeeeeeee');
    var leaveDate = Jiffy(DateTime.now()).format('yyyy-MM-dd');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body =
        jsonEncode({"plantId": prefs.getString("PlantId"),"date":leaveDate});
    print(body);
    ApiService.post("empLeavesbyDt", body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        List empLeaveList = jsonDecode(data)['empLeaveList'];
        if (empLeaveCount == null ||
            empLeaveList.isEmpty ||
            empLeaveList == null) {
          empLeaveCount = 0;
        } else {
          empLeaveCount = jsonDecode(data)['count'];
        }
        print(empLeaveCount);
        print(empLeaveList);
        print('empLeaveList');
      });
    });
  }

  _dashboardChanges() async {
    getEmpGender();
    getEmpLeave();
    getEmpAge();
    getEmpExp();
    getEmpByDept();
    getEmpLateIn();
    getEmpSal();
  }

  setRoleData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("roleName").toString();
    setState(() {
      if (id == "FinanceManager") {
        setState(() {
          isVisible = true;
          bottombarWidth = 50;
        });
      } else {
        setState(() {
          isVisible = false;
          bottombarWidth = 50;
        });
      }
    });
  }

  getOfficehoursDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"empNumber": prefs.getString('empNumber'),"frmdate":Jiffy(DateTime.now()).format('yyyy-MM-dd'),"todate":Jiffy(DateTime.now()).format('yyyy-MM-dd')});
    print(body);
    ApiService.post('lginEmpHrsinOfc',body).then((success) {
      print(success.body);
      var body = jsonDecode(success.body);

      print(body['empHrsList']);
      getTimeDiff(body['empHrsList']);
    });
  }



  getTimeDiff(empHrsList){
    totalHours = 0;
    totalMinutes = 0;
    totalSecs = 0;
    hoursInOffice=[];
    for(int i=0;i<empHrsList.length;i++) {
      var punchInDateTime = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(empHrsList[i]['punchin']);
      var punchOutDateTime;
      if(empHrsList[i]['punchout'] == null){
        DateTime now = DateTime.now(); // March 2022
        punchOutDateTime = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(now.toString());
      }else{
        punchOutDateTime = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(empHrsList[i]['punchout']);
      }
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

        if(totalSecs > 60){
          totalMinutes += 1;
          totalSecs -= 60;
        }
        if(totalMinutes>60){
          totalHours += 1;
          totalMinutes -=60;
        }
      });
      print("Time    #######@@@@@@######"+totalHours.toString()+"  hr "+totalMinutes.toString()+" mins  "+totalSecs.toString()+" secs");
    }
  }
}

class ChartData {
  ChartData(this.x, this.y, this.size);
  final String x;
  final double y;
  final String size;
}

class ChartData1 {
  ChartData1(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color color;
}

class SalesData {
  SalesData(this.year, this.sales);

  final String year;
  final double sales;
}

class StackedData {
  StackedData(this.x, this.y1, this.y2, this.y3, this.y4, this.y5);

  final String x;
  final double y1;
  final double y2;
  final double y3;
  final double y4;
  final double y5;
}

class LineChartData {
  LineChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}

class RangeChartData {
  RangeChartData(this.x, this.y, this.z,this.color);
  final String x;
  final double y;
  final double z;
  final Color color;
}
