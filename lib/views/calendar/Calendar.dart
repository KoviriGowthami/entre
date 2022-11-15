import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/views/meetingroom/MeetingRoom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../helpers/Utilities.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key key}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  List eventList;
  String title;
  String sortBy = "All";
  int i;
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  bool isInternetAvailable = true;

  void initState() {
    super.initState();
    getEvent();
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
            "Calendar",
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
              child: Column(children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: ListTile(
                      onTap: () {
                        // _selectDate(context);
                      },
                      title: Text("Sort By",
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Color(0xFF000000))),
                      trailing: DropdownButton(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                        iconSize: 42,
                        items: <String>[
                          'All',
                          'Holidays',
                          'Booking',
                          'Leave',
                          'Course',
                          'Meeting',
                          'Tasks'
                        ].map((item) {
                          return new DropdownMenuItem(
                              child: new Text(
                                item,),
                              value: item
                                  .toString() //Id that has to be passed that the dropdown has.....
                          );
                        }).toList(),
                        onChanged: (String newVal) {
                          setState(() {
                            sortBy = newVal;
                            getEvent();
                          });
                        },
                        value: sortBy,
                      )),
                ),
                Container(
                    height: MediaQuery.of(context).size.height * 0.73,
                    child: SfCalendar(
                      view: CalendarView.schedule,
                      allowedViews: [
                        CalendarView.day,
                        CalendarView.week,
                        CalendarView.month,
                        CalendarView.workWeek,
                        CalendarView.timelineDay,
                        CalendarView.timelineWeek,
                        CalendarView.timelineWorkWeek,
                        CalendarView.schedule,
                      ],
                      showDatePickerButton: true,
                      allowViewNavigation: true,
                      dataSource: MeetingDataSource(_getDataSource()),
                      onTap: (CalendarTapDetails details) {
                        DateTime date = details.date;
                        Meeting appointmentDetails = details.appointments[0];
                        showAlert(appointmentDetails);
                      },
                      scheduleViewMonthHeaderBuilder: (BuildContext buildContext,
                          ScheduleViewMonthHeaderDetails details) {
                        //  var now = new DateTime.now();
                        String monthName = months[(details.date.month) - 1];
                        return Stack(
                          children: [
                            Image(
                                image: ExactAssetImage(
                                    'assets/images/' + monthName + '.png'),
                                fit: BoxFit.cover,
                                width: details.bounds.width,
                                height: details.bounds.height),
                            Positioned(
                              left: 55,
                              right: 0,
                              top: 20,
                              bottom: 0,
                              child: Text(
                                monthName + ' ' + details.date.year.toString(),
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          ],
                        );
                      },
                      monthViewSettings: const MonthViewSettings(
                          appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment),
                    ))
              ]),
            )));
  }

  void showAlert(Meeting appointmentDetails) {
    var string = appointmentDetails.eventName;
    String title = "";
    String body = "";
    List split = [];
    try {
      split = string.split(":");
    } catch (e) {}
    ;
    if (split.length > 0) {
      if (split.length == 1) {
        title = split[0];
        body = split[0];
      } else {
        title = split[0];
        body = split[1];
      }
    } else {
      title = string;
      body = string;
    }
    // }
    showDialog(
        barrierColor: Color(0xef2d324f),
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              title,
              style: TextStyle(
                  color: Color(0xff2d324f),
                  fontWeight: FontWeight.bold),
            ),
            content: Text(body,),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  getEvent() async {
    String filterId;
    if (sortBy == 'Course') {
      filterId = '4';
    } else if (sortBy == 'Holidays') {
      filterId = '1';
    } else if (sortBy == 'Booking') {
      filterId = '2';
    } else if (sortBy == 'Leave') {
      filterId = '3';
    } else if (sortBy == 'Meeting') {
      filterId = '5';
    }else if (sortBy == 'Tasks') {
      filterId = '6';
    }else{
      filterId = '0';
    }
    // else {
    //   filterId = '0';
    // }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode(
        {"user_id": prefs.getString('userId'), "filter_id": filterId});
    ApiService.post('getCalenderEventsList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        eventList = jsonDecode(data)['getCalenderEventsList'];
      });
    });
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    try {
      for (int i = 0; i < eventList.length; i++) {
        DateTime today = DateTime.parse(eventList[i]['start'] + ' 00:00:00');
        final DateTime startTime =
        DateTime(today.year, today.month, today.day, 9, 0, 0);
        final DateTime endTime = startTime.add(const Duration(hours: 12));
        meetings.add(Meeting(eventList[i]['title'], startTime, endTime,
            const Color(0xFF0F8644), false));
      }
      return meetings;
    } catch (e) {}
  }
}
