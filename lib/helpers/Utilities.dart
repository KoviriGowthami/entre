import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:entreplan_flutter/helpers/network.dart';
import 'package:entreplan_flutter/views/Pedometer/StepsTracking.dart';
import 'package:entreplan_flutter/views/Recruitment/Recruitment.dart';
import 'package:entreplan_flutter/views/Salary/PaySlip.dart';
import 'package:entreplan_flutter/views/TaskManagement/ViewTaskManagement.dart';
import 'package:entreplan_flutter/views/assettracking/QrCode.dart';
import 'package:entreplan_flutter/views/attendance/PunchinOut.dart';
import 'package:entreplan_flutter/views/attendance/emprecords.dart';
import 'package:entreplan_flutter/views/attendance/myrecords.dart';
import 'package:entreplan_flutter/views/attendance/timeandattendance.dart';
import 'package:entreplan_flutter/views/calendar/Calendar.dart';
import 'package:entreplan_flutter/views/induction/Induction.dart';
import 'package:entreplan_flutter/views/leave/ApplyLeave.dart';
import 'package:entreplan_flutter/views/leave/ApproveLeave.dart';
import 'package:entreplan_flutter/views/leave/Assignleave.dart';
import 'package:entreplan_flutter/views/leave/Leave.dart';
import 'package:entreplan_flutter/views/leave/MyLeaveLIst.dart';
import 'package:entreplan_flutter/views/meetingroom/BookMeetingRoom.dart';
import 'package:entreplan_flutter/views/myinfo/ContactDetails.dart';
import 'package:entreplan_flutter/views/ot/OT.dart';
import 'package:entreplan_flutter/views/permission/ApprovePermissionList.dart';
import 'package:entreplan_flutter/views/permission/AssingPermission.dart';
import 'package:entreplan_flutter/views/permission/MyPermissionList.dart';
import 'package:entreplan_flutter/views/permission/Permission.dart';
import 'package:entreplan_flutter/views/permission/PermissionForm.dart';
import 'package:entreplan_flutter/views/visitor/ViewVisitorList.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ConnectivityResult connectivityResult;

class Utilities {

  static List selectedempList = [];
  static List selectedcustomerList = [];
  static List selectedvendorList = [];
  static String dataState="";


  static Future<bool> checkConnection() async {
    connectivityResult = await (new Connectivity().checkConnectivity());
    if ((connectivityResult == ConnectivityResult.mobile) || (connectivityResult == ConnectivityResult.wifi)) {
      return true;
    } else {
      return false;
    }
  }

  static getSharedPreference(String value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(value);
    } catch (e) {
      return e;
    }
  }

  static void showAlert(
    BuildContext context,
    String text,
  ) {
    var alert = new AlertDialog(
      content: Container(
        child: Row(
          children: <Widget>[Text(text)],
        ),
      ),
      actions: <Widget>[
        // ignore: deprecated_member_use
        new FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(color: Colors.black),
            ))
      ],
    );

    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  static void navigateUrl(id, context) {
    var navigate;
    if (id == 1) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalInfo()));

      return navigate;
    } else if (id == 2) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => Leave()));

      return navigate;
    } else if (id == 3) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => Permission()));

      return navigate;
    } else if (id == 4) {
      Utilities.selectedempList = [];
      Utilities.selectedcustomerList = [];
      Utilities.selectedvendorList = [];
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) =>  BookMeetingRoom()));

      return navigate;
    } else if (id == 5) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => QrCode()));

      return navigate;
    } else if (id == 6) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => OT()));

      return navigate;
    } else if (id == 7) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => Visitor()));

      return navigate;
    } else if (id == 8) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => TimeAndAttendance()));

      return navigate;
    } else if (id == 9) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => Recruitment()));

      return navigate;
    } else if (id == 10) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => PaySlip()));

      return navigate;
    } else if (id == 11) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => ViewTaskManagement()));
      return navigate;
    } else if (id == 12) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => Calendar()));
      return navigate;
    } else if (id == 13) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => Induction()));
      return navigate;
    } else if (id == 14) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => StepsTracking()));
      return navigate;
    }
  }

  static void navigateLeaveUrl(id, context) {
    var navigate;
    if (id == 1) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => ApplyLeave()));

      return navigate;
    } else if (id == 2) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => ApproveLeave()));

      return navigate;
    } else if (id == 3) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => MyLeaveList()));

      return navigate;
    }else if (id == 4){
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => Assignleave()));
      return navigate;
    }
  }

  static void navigateEmpPunchDetails(id, context) {
    var navigate;
    if (id == 1) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => MyRecords()));
      return navigate;
    } else if (id == 2) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => EmpRecords()));
      return navigate;
    }
  }

  static void navigatePermissionUrl(id, context) {
    var navigate;
    if (id == 1) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => PermissionForm()));

      return navigate;
    } else if (id == 3) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => MypermissionList()));

      return navigate;
    } else if (id == 2) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => ApprovePermission()));

      return navigate;
    } else if (id == 4) {
      navigate = Navigator.push(context, MaterialPageRoute(builder: (context) => AssignPermission()));

      return navigate;
    }
  }

}
