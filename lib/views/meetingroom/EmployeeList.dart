import 'package:entreplan_flutter/views/meetingroom/Customerlist.dart';
import 'package:entreplan_flutter/views/meetingroom/Employee.dart';
import 'package:flutter/material.dart';

import 'Vendorlist.dart';

class Employeelist extends StatefulWidget {
  const Employeelist({Key key}) : super(key: key);

  @override
  _EmployeelistState createState() => _EmployeelistState();
}

class _EmployeelistState extends State<Employeelist> {
  bool isInternetAvailable = true;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
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
              "Employee List",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontFamily: 'Myriad',
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            bottom: TabBar(
              isScrollable: false,
              tabs: <Widget>[
                Tab(
                    child: Text(
                  'Employee',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Myriad',
                    fontWeight: FontWeight.bold,
                  ),
                )),
                Tab(
                    child: Text(
                  'Vendor',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Myriad',
                    fontWeight: FontWeight.bold,
                  ),
                )),
                Tab(
                    child: Text(
                  'Customer',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Myriad',
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ],
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              Employee(),
              Vendorlist(),
              Customerlist(),
            ],
          ),
        ));
  }
}
