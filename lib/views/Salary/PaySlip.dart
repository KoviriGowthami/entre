import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/Utilities.dart';

class PaySlip extends StatefulWidget {
  const PaySlip({Key key}) : super(key: key);

  @override
  _PaySlipState createState() => _PaySlipState();
}

class _PaySlipState extends State<PaySlip> {
  bool listVisible = false;
  bool isVisible = false;
  void initState() {
    getPayRolList();
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.green, // navigation bar color
      statusBarColor: Colors.green, // status bar color
    ));
  }

  List payrol_list;
  bool isInternetAvailable = true;


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
          "Payroll List",
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
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/body_bg.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(children: [
              Column(
                children: [
                  Visibility(
                    visible: listVisible,
                    child: Container(
                      child: SafeArea(
                        bottom: true,
                        child: ListView.builder(
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: payrol_list == null ? 0 : payrol_list.length,
                            itemBuilder: (context, index) {
                              return MyPayRolListTile(
                                pay_month_name: payrol_list[index]['pay_month_name'],
                                pay_year: payrol_list[index]['pay_year'],
                                salary5: payrol_list[index]['salary5'],
                                salary8: payrol_list[index]['salary8'],
                                payslipurl: payrol_list[index]['payslip_path'],
                              );
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
                  ),
                ],
              )
            ]),
          )),
    );
  }

  getPayRolList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('employeePayrolList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        payrol_list = jsonDecode(data)['payrol_list'];
        if (payrol_list.length == 0) {
          setState(() {
            isVisible = true;
            listVisible = false;
          });
        } else {
          setState(() {
            listVisible = true;
            isVisible = false;
          });
        }
      }); // just printed length of data
    });
  }
}

class MyPayRolListTile extends StatefulWidget {
  final String pay_month_name;
  final String pay_year;
  final String salary5;
  final String salary8;
  final String payslipurl;

  MyPayRolListTile(
      {this.pay_month_name,
        this.pay_year,
        this.salary5,
        this.salary8,
        this.payslipurl});
  @override
  _MyPayRolListTileState createState() => _MyPayRolListTileState();
}

class _MyPayRolListTileState extends State<MyPayRolListTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _launchURL(widget.payslipurl);
        },
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(right: 16,left: 16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
              padding: EdgeInsets.only(top: 16, right: 16, left: 16),
              child: Card(
                color: Color(0xfff1f3f6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Image.asset(
                        "assets/images/pdf.png",
                        height: double.infinity,
                      ),
                      title: Text(
                        "\n\nPay_month : ${widget.pay_month_name}" +
                            "\n\nPay_year :  ${widget.pay_year}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'avenir',),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
          ],
        ));
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
