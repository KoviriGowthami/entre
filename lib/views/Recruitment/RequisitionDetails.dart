import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:entreplan_flutter/views/Recruitment/Recruitment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/Utilities.dart';
import '../home/HomeTabs.dart';

class RequisitionDetails extends StatefulWidget {
  final String details;
  const RequisitionDetails({Key key, @required this.details}) : super(key: key);

  @override
  _RequisitionDetailsState createState() => _RequisitionDetailsState();
}

class _RequisitionDetailsState extends State<RequisitionDetails> {
  int id = 0;
  bool isAcceptVisible = false;
  bool isApproveVisible = false;
  bool isCancelVisible = false;
  bool isRejectVisible = false;
  bool value = false;
  DateTime now = new DateTime.now();
  String reqid="";
  String jobTitle="";
  String job_title_id="";
  String locationName="";
  String locname_id="";
  String departmentName="";
  String department_id="";
  String reportToName="";
  String report_to_id="";
  String no_of_positions="";
  String job_description="";
  String required_by="";
  String qualifications="";
  String skill_experience="";
  String min_eperience="";
  String min_salary="";
  String max_salary="";
  String requested_budgeted="";
  String req_submitted_by="";
  String requested_budgeted_name="";
  String reason_for_requirement="";
  String reason_for_requirement_name="";
  String replace_for="";
  String comments="";
  String status="";
  String status_name="";
  String requisition_type="";
  String requisition_type_name="";
  String action_status_id="";
  String action_status_name="";
  List buttonsList;
  String reject,approve,accept;
  bool isInternetAvailable = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    makeDetailsApi();
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
            "Manpower Requisition",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Myriad',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body:Container(
          height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/body_bg.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      color: Colors.transparent,
                        child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text('Requisition Type*'),
                                    SizedBox(
                                      width: 70,
                                    ),
                                    Text('$requisition_type_name')
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Job Title*',
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(
                                      width: 115,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '$jobTitle',
                                        maxLines: null,
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Location*',
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(
                                      width: 115,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '$locationName',
                                        maxLines: null,
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Department*',
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(
                                      width: 100,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '$departmentName',
                                        maxLines: null,
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(children: [
                                  Text(
                                    'Request By',
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(
                                    width: 110,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '$reportToName',
                                      maxLines: null,
                                      softWrap: true,
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ]),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text('No of Vacancies'),
                                    SizedBox(
                                      width: 80,
                                    ),
                                    Text(
                                      '$no_of_positions',
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Job Description',
                                  ),
                                ),
                                Column(children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black, spreadRadius: 0.3),
                                      ],
                                    ),
                                    child: Html(
                                      data: job_description,
                                    ),
                                  ),
                                ]),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text('Qualification'),
                                    SizedBox(
                                      width: 115,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '$qualifications',
                                        maxLines: null,
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(children: [
                                  Text('Minimum \nExperience(years)'),
                                  SizedBox(
                                    width: 85,
                                  ),
                                  Text('$min_eperience'),
                                ]),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text('Proposed Salary/\nCTC(per annum)'),
                                    SizedBox(
                                      width: 90,
                                    ),
                                    Text('$min_salary\n$max_salary'),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text('Required By*'),
                                    SizedBox(
                                      width: 118,
                                    ),
                      Expanded(
                        child: Text(
                          '$required_by',
                          maxLines: null,
                          softWrap: true,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text('Reason for requirement'),
                                    SizedBox(
                                      width: 60,
                                    ),
                                    Text('$reason_for_requirement'),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(children: [
                                  Text('Request Budgeted'),
                                  SizedBox(
                                    width: 90,
                                  ),
                                  Text('$requested_budgeted')
                                ]),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text('Notes/Comments'),
                                    SizedBox(
                                      width: 90,
                                    ),
                      Expanded(
                        child: Text(
                          '$comments',
                          maxLines: null,
                          softWrap: true,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text('Status'),
                                    SizedBox(
                                      width: 160,
                                    ),
                                    Text('$status_name'),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                    child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                    ),
                                    labelText: 'Comment',
                                    labelStyle: TextStyle(color: Colors.black),
                                    hintText: 'Please Enter Comment',
                                  ),
                                )),
                                SizedBox(
                                  height: 15,
                                ),
                                Card(
                                  color: Color(0xFF5ad6a6).withOpacity(0.4),
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Visibility(
                                        visible: isAcceptVisible, child: buildAccept(context)),
                                    Visibility(
                                        visible: isApproveVisible, child: buildApprove(context)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Visibility(
                                        visible: isRejectVisible, child: buildReject(context)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Visibility(
                                        visible: isCancelVisible, child: buildCancel(context)),
                                  ],
                                )),
                              ],
                            ))),
                  ],
                ),
              ),
            ));
  }

  makeDetailsApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode(
        {"user_id": prefs.getString('userId'), "req_id": widget.details});
    ApiService.post('saveManpowerRequisition',body).then((success) {
      String data = success.body; //store response as string
      Map results = json.decode(data)['Requisition'];
      setState(() {
        buttonsList = json.decode(data)['Action_Perform'];
        for (int i = 0; i < buttonsList.length; i++) {
          if (buttonsList[i]['name'] == "Cancel") {
            isCancelVisible = true;
          }
          if (buttonsList[i]['name'] == "Reject") {
            isRejectVisible = true;
            reject = buttonsList[i]['id'];

          }
          if (buttonsList[i]['name'] == "Approve") {
            isApproveVisible = true;
            approve = buttonsList[i]['id'];

          }
          if (buttonsList[i]['name'] == "Accept") {
            isAcceptVisible = true;
            accept = buttonsList[i]['id'];

          }
        }
        reqid = results['id'];
        jobTitle = results['jobTitle'];
        job_title_id = results['job_title_id'];
        locationName = results['locationName'];
        locname_id = results['locname_id'];
        departmentName = results['departmentName'];
        department_id = results['department_id'];
        reportToName = results['reportToName'];
        report_to_id = results['report_to_id'];
        no_of_positions = results['no_of_positions'];
        job_description = results['job_description'];
        required_by = results['required_by'];
        qualifications = results['qualifications'];
        skill_experience = results['skill_experience'];
        min_eperience = results['min_eperience'];
        min_salary = results['min_salary'];
        max_salary = results['max_salary'];
        requested_budgeted = results['requested_budgeted'];
        req_submitted_by = results['req_submitted_by'];
        requested_budgeted_name = results['requested_budgeted_name'];
        reason_for_requirement = results['reason_for_requirement'];
        reason_for_requirement_name = results['reason_for_requirement_name'];
        replace_for = results['replace_for'];
        comments = results['comments'];
        status = results['status'];
        status_name = results['status_name'];
        requisition_type = results['requisition_type'];
        requisition_type_name = results['requisition_type_name'];
        action_status_id = results['action_status_id'];
        action_status_name = results['action_status_name'];
      });
    });
  }

  @override
  Widget buildApprove(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () {
          makeApiCall(widget.details,approve);
          approvebar(context);
        },
        child: Container(
          child:Image.asset('assets/images/approvenew_btn.png',height: 30,)
        ),
      ),
    );
  }

  @override
  Widget buildAccept(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () {
          makeApiCall(widget.details,accept);
          acceptbar(context);
        },
        child: Container(
          child: Image.asset('assets/images/ACCEPTnew.png',height: 30,)
        ),
      ),
    );
  }

  @override
  Widget buildReject(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () {
          makeApiCall(widget.details,reject);
          rejectbar(context);

        },
        child: Container(
          child: Image.asset('assets/images/reject_btnnew.png',height: 30,)
        ),
      ),
    );

}

  @override
  Widget buildCancel(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () =>
        {                  Navigator.pop(
        context,
        MaterialPageRoute(
        builder: (context) => Recruitment()))
        },

        child: Container(
          child: Image.asset('assets/images/cancelnew_btn.png',height: 30),
          ),
      )
    );
  }

  makeApiCall(String id,String Buttonid)  async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId'), "req_id": reqid.toString(),"action_perform":Buttonid,"comment":""});ApiService.post('requisitionActionPerform',body).then((success) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeTabs()));
    });
  }

  void approvebar(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Approved Successfully'),
        action: SnackBarAction(label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
  void rejectbar(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Rejected Successfully'),
        action: SnackBarAction(label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }void acceptbar(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Accepted Successfully'),
        action: SnackBarAction(label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}

