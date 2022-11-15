import 'package:entreplan_flutter/helpers/Utilities.dart';
import 'package:entreplan_flutter/views/attendance/PunchinOut.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeAndAttendance extends StatefulWidget {
   TimeAndAttendance({Key key}) : super(key: key);

  @override
  State<TimeAndAttendance> createState() => _TimeAndAttendanceState();
}

class _TimeAndAttendanceState extends State<TimeAndAttendance> {
  bool isInternetAvailable = true;
  bool isVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setData();
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
            "Time And Attendance",
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
                                  "My Records",
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
                                  "My Records",
                              ),
                              gridTile(
                                  2,
                                  "my_leave",
                                  "Employee Records",
                              ),
                            ],
                          ))),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: Container(
          width: 300,
          margin: EdgeInsets.only(right: 35),
          child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => PunchinOut()));
                // Add your onPressed code here!
              },
              label: const Text('Punch In/Out',style: TextStyle(fontFamily: 'Myriad',color: Colors.white),),
              icon: const Icon(Icons.add,color: Colors.white,),
              backgroundColor: Color(0xFF7d7d7d),
            ),
        ));
  }


  Widget gridTile(id, imgUrl, title) {
    return Row(
      children: [
        Expanded(
            child: InkWell(
                onTap: () async {
                  Utilities.navigateEmpPunchDetails(id, context);
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


  setData() async {
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

}
