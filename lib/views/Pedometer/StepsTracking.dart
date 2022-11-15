import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/rest_api.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

class StepsTracking extends StatefulWidget {
  const StepsTracking({Key key}) : super(key: key);

  @override
  _StepsTrackingState createState() => _StepsTrackingState();
}

class _StepsTrackingState extends State<StepsTracking> {
  Stream<StepCount> _stepCountStream;
  Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '0';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    setStepcount();
  }

  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps.toString();
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
    _pedestrianStatusStream.listen(onPedestrianStatusChanged).onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Step Count",
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
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/body_bg.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Steps taken:',style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:16,
                    color: Colors.white),
                ),
                Text(
                  _steps,style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white),
                ),
                Divider(
                  height: 100,
                  thickness: 0,
                  color: Colors.white,
                ),
                Text(
                  'Pedestrian status:',style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,),
                ),
                Icon(
                  _status == 'walking'
                      ? Icons.directions_walk
                      : _status == 'stopped'
                          ? Icons.accessibility_new
                          : Icons.error,
                  size: 100,
                ),
                Center(
                  child: Text(
                    _status,
                    style: _status == 'walking' || _status == 'stopped' ? "" : TextStyle( color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      );
  }

  setStepcount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('getStepCount',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        _steps = jsonDecode(data)['step_count'].toString();
      });
    });
  }

}
