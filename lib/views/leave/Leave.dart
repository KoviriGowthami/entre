import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';

class Leave extends StatefulWidget {
  @override
  _LeaveState createState() => _LeaveState();
}

class _LeaveState extends State<Leave> {

  bool isInternetAvailable = true;

  void initState() {
    super.initState();
    setDate();
    setNotification();
  }

  bool isVisible = false;
  String newLeaveCount = "";
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
    ):Scaffold(
        appBar: AppBar(
          leading: Container(
            margin: EdgeInsets.all(5),
            child: GestureDetector(
              child: Image.asset(
                "assets/images/back_btn3.png",
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Text(
            "Leave",
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
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/body_bg.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 20,),
              SizedBox(
                child: Container(
                  child: Visibility(
                      visible: !isVisible,
                      child: Container(
                          height: 200,
                          color: Colors.white30,
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            childAspectRatio: 1.0,
                            padding: const EdgeInsets.all(3.0),
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0,
                            children: [
                              gridTile(
                                1,
                                "apply_leave",
                                "Apply Leave",
                                  false,""
                              ),
                              gridTile(
                                3,
                                "my_leave",
                                "My Leave",
                                  false,""
                              ),
                            ],
                          ))),
                ),
              ),
              SizedBox(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Visibility(
                      visible: isVisible,
                      child: Container(
                          height: 200,
                          color: Colors.white30,
                          child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            childAspectRatio: 1.0,
                            padding: const EdgeInsets.all(3.0),
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0,
                            children: [
                              gridTile(
                                1,
                                "apply_leave",
                                "Apply Leave",
                                  false,""
                              ),
                              gridTile(
                                3,
                                "my_leave",
                                "My Leave",
                                false,""
                              ),
                              gridTile(
                                2,
                                "approve_leave",
                                "Approve Leave", newLeaveCount == "0" ? false : true, "$newLeaveCount"
                              ),
                              gridTile(
                                4,
                                "assign_leave",
                                "Assign Leave",
                                  false,""
                              ),
                            ],
                          ))),
                ),
              )
            ],
          ),
        ));
  }

  Widget gridTile(path, imgUrl, title,badgeshow, count) {
    return Row(
      children: [
        Expanded(
            child: InkWell(
                onTap: () async {
                  Utilities.navigateLeaveUrl(path, context);
                },
                child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/home_card.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: badgeshow,
                          child: Badge(
                            badgeColor: Colors.red,
                            position: BadgePosition.topEnd(top: -20, end: -5),
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
                        SizedBox(
                          height: 20,
                        ),
                        Text(title, style: TextStyle(color: Colors.white)),
                      ],
                    ))))
      ],
    );
  }

  setDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("role").toString();
    setState(() {
      if (id == "HiringManager" || id == "Supervisor") {
        return isVisible = true;
      } else {
        return isVisible = false;
      }
    });
  }

  setNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final body = jsonEncode({"user_id": prefs.getString('userId')});

    ApiService.post("appNewNotificationsCount",body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        newLeaveCount = jsonDecode(data)['leaves_count'].toString();
      });
    });
  }

}
