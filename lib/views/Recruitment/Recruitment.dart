import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/views/Recruitment/RequisitionDetails.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/Utilities.dart';

class Recruitment extends StatefulWidget {
  const Recruitment({Key key}) : super(key: key);

  @override
  _RecruitmentState createState() => _RecruitmentState();
}

class _RecruitmentState extends State<Recruitment> {
  bool isVisible = false;
  bool listVisible = false;
  List visitorList;
  bool isInternetAvailable = true;

  void initState() {
    super.initState();
    getvisitorList();
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
          "Requisition List",
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
          child: Column(
            children: [
              Visibility(
                visible: listVisible,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.88,
                  child: SafeArea(
                    bottom: true,
                    child: ListView.builder(
                      physics: ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: visitorList == null ? 0 : visitorList.length,
                        itemBuilder: (context, index) {
                          return VisitorsTile(
                              id: visitorList[index]['id'],
                              jobTitle: visitorList[index]['jobTitle'],
                              no_of_positions: visitorList[index]
                                  ['no_of_positions'],
                              required_by: visitorList[index]['required_by'],
                              qualifications: visitorList[index]['qualifications'],
                              action_status_name: visitorList[index]
                                  ['action_status_name']);
                        }),
                  ),
                ),
              ),
              Visibility(
                visible: isVisible,
                child: Center(
                  heightFactor: 1.5,
                  child: Container(
                    child: Lottie.network(
                          'https://assets10.lottiefiles.com/private_files/lf30_lkquf6qz.json',fit: BoxFit.fill,),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  getvisitorList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('viewManpowerRequisitionList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        visitorList = jsonDecode(data)['RequisitionList'];
        if (visitorList.length == 0) {
          isVisible = true;
        } else {
          listVisible = true;
        }
      });
    });
  }
}

class VisitorsTile extends StatefulWidget {
  final String id;
  final String jobTitle;
  final String no_of_positions;
  final String required_by;
  final String qualifications;
  final String action_status_name;

  const VisitorsTile({
    Key key,
    this.id,
    this.jobTitle,
    this.no_of_positions,
    this.required_by,
    this.qualifications,
    this.action_status_name,
  }) : super(key: key);

  @override
  _VisitorTileState createState() => _VisitorTileState();
}

class _VisitorTileState extends State<VisitorsTile> {
  String statusName = '';
  String action_status_name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(right: 16,left: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.only(top: 16, right: 16, left: 16),
        child: Card(
          color: Color(0xfff1f3f6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Image.asset(
                  _setImage(),
                  height: 250,
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RequisitionDetails(
                                details: widget.id,
                              )));
                },
                title: Text(
                  "\n Job Title               :  ${widget.jobTitle}"
                  "\n\n No of Positions   : ${widget.no_of_positions} "
                  " \n\n Required By         :  ${widget.required_by} "
                  "\n\n Qualification        : ${widget.qualifications}"
                  "\n\n Action Status      : ${widget.action_status_name} "
                  "\n\n",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'avenir',),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _setImage() {
    if (widget.action_status_name == "Accepted") {
      return "assets/images/approved.png";
    } else if (widget.action_status_name == "Rejected") {
      return "assets/images/reject.png";
    } else if (widget.action_status_name == "Submitted") {
      return "assets/images/pending.png";
    } else {
      return "assets/images/pending.png";
    }
  }
}
