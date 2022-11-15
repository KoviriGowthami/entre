import 'dart:convert';

import 'package:entreplan_flutter/apiservice/rest_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/Utilities.dart';

class Induction extends StatefulWidget {
  const Induction({Key key}) : super(key: key);

  @override
  _InductionState createState() => _InductionState();
}

class _InductionState extends State<Induction> {
  List questionsList = [];
  bool listVisible = false;
  bool isVisible = false;
  var indQueId;
  int indStatusId;
  bool isInternetAvailable = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getQuestionsist();
  }

  getQuestionsist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({"user_id": prefs.getString('userId')});
    ApiService.post('inductionQuestionsList',body).then((success) {
      String data = success.body; //store response as string
      setState(() {
        questionsList = jsonDecode(data)['induction_list'];
        if (questionsList.length == 0) {
          isVisible = true;
        } else {
          listVisible = true;
        }
      }); // just printed length of data
    });
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
          "Induction",
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
          child: SingleChildScrollView(
            child: Column(children: [
                    Column(
                      children: [
                        Visibility(
                            visible: listVisible,
                            child: SafeArea(
                              bottom: true,
                              child: Container(
                                  child: ListView.builder(
                                    physics: ScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: questionsList == null ? 0 : questionsList.length,
                                    itemBuilder: (context, index) {
                                      return QuestionListTile(
                                        question: questionsList[index]['question'],
                                        terms_conditions: questionsList[index]
                                        ['terms_conditions'],
                                        id: questionsList[index]['id'],
                                        index: index,
                                        indStatusId: questionsList[index]['ind_status'],
                                      );
                                    },
                                  )),
                            )),
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
          ),
        ));
  }
}

class QuestionListTile extends StatefulWidget {
  final String question;
  final String terms_conditions;
  final String id;
  final int index;
  final int indStatusId;

  QuestionListTile({this.question, this.terms_conditions, this.id, this.index,this.indStatusId});

  @override
  _QuestionListTileState createState() => _QuestionListTileState();
}

class _QuestionListTileState extends State<QuestionListTile> {
  int id;
  List selectedid = [];
  String radioItemHolder = '';
  List<NumberList> nList = [
    NumberList(
      index: 1,
      number: "Yes",
    ),
    NumberList(
      index: 0,
      number: "No",
    ),
  ];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.indStatusId == 1){
      setState(() {
        id = 1;
      });
    }
    selectedid.add(-1);
  }

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
                    title: Column(
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "\n${widget.question}\n",
                            style: TextStyle(
                                fontFamily: 'avenir',
                                color: Colors.black),
                          ),
                        ),
                        Column(
                          children: nList
                              .map((data) => RadioListTile(
                            title: Text("${data.number}"),
                            groupValue: selectedid.length > 0
                                ? id
                                : selectedid[widget.index],
                            value: data.index,
                            onChanged: (val) {
                              setState(() {
                                radioItemHolder = data.number;
                                id = data.index;
                                if (id == 0) {
                                  showAlert(
                                      widget.terms_conditions, widget.index);
                                }
                              });
                              getInductionIdStatusApi();
                            },
                          ))
                              .toList(),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ));
  }

  void showAlert(termsConditions, index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terms & Conditions:',
                    style: TextStyle(color: Color(0xff2d324f)),
                  ),
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        id = 1;
                      });
                      Navigator.of(context).pop(true);
                    },
                    child: const Text(
                      '        X',
                      style:
                      TextStyle( fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        child: Html(
                          data: termsConditions,
                        ),
                      ),
                      RaisedButton(
                          color: Color(0xff2d324f),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9.0)),
                          textColor: Colors.white,
                          child: Text(
                            'OK',
                          ),
                          onPressed: () async {
                            setState(() {
                              id = 1;
                            });
                            Navigator.of(context).pop(true);
                          }),
                    ],
                  )));
        });
  }

  getInductionIdStatusApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final body = jsonEncode({
      "user_id": prefs.getString('userId'),
      "induction_qns_id": widget.id,
      "induction_emp_status": "1"
    });

    ApiService.post('inductionEmpStatusUpdate',body).then((success) {
      String data = success.body; //store response as string
    });
  }
}

class NumberList {
  String number;
  int index;
  NumberList({this.number, this.index});
}
