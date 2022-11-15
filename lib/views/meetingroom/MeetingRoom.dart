import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../helpers/Utilities.dart';

class MeetingRoomScreen extends StatefulWidget {
  @override
  _MeetingRoomScreenState createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  List eventList;
  String title;
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
          title: Text('Meeting Room'),
          titleSpacing: 00.0,
          centerTitle: true,
          toolbarHeight: 60.2,
          elevation: 0.00,
          backgroundColor: Color(0xff2d324f),
        ),
        body: Container(
            child: SfCalendar(
              view: CalendarView.month,
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
                String monthName = months[(details.date.month) - 1];
                return Stack(
                  children: [
                    Positioned(
                      left: 55,
                      right: 0,
                      top: 20,
                      bottom: 0,
                      child: Text(
                        monthName + ' ' + details.date.year.toString(),
                        style: TextStyle( color: Colors.black),
                      ),
                    )
                  ],
                );
              },
              monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
            )));



  }

  void showAlert(Meeting appointmentDetails) {
    var string = appointmentDetails.eventName;
    String title = "";
    String body = "";
    List split = [];
    try {
      split = string.split(":");
    } catch (e) {};
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
    showDialog(
        barrierColor: Color(0xef2d324f),
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              title,
              style: TextStyle(color: Color(0xff2d324f),fontWeight: FontWeight.bold),
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('getCalenderEventsList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        eventList = jsonDecode(data)['getCalenderEventsList'];
      });
    });
  }

  List<Meeting> _getDataSource() {
    var i;
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
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final DateTime today = DateTime.now();
    final DateTime startTime = DateTime(today.year, today.month, today.day, 9, 0, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 2));

    final dynamic meeting = appointments[index];
    Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;

  DateTime from;

  DateTime to;

  Color background;

  bool isAllDay;
}
