import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../helpers/Utilities.dart';

class MeetingRoom extends StatefulWidget {
  @override
  _MeetingRoomState createState() => _MeetingRoomState();
}

class _MeetingRoomState extends State<MeetingRoom> {
  final green = const Color(0xff57BE6C);
  final white = const Color(0xffFAFCFE);
  bool isInternetAvailable = true;
  List selectedempList = [];
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
        title: Text(
          'Meeting Room',
        ),
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 50.2,
        elevation: 0.00,
        backgroundColor: Color(0xff2d324f),
      ),
      backgroundColor: white,
      body: Column(
        children: [
          SizedBox(
            height: 200,
          ),
          GestureDetector(
            onTap: () {
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
              alignment: Alignment.center,
              height: 90,
              decoration: BoxDecoration(
                color: Color(0xff2d324f),
                borderRadius: BorderRadius.circular(55),
              ),
              child: Hero(
                  tag: "Book Meeting",
                  child: Text("Book Meeting",
                      style: TextStyle(color: Colors.white,))),
            ),
          ),
        ],
      ),
    );
  }
}
